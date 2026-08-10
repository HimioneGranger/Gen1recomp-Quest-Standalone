-- Quest-only, source-guarded Dramaless ChunkMesher optimization.
--
-- Dramaless 1.6.4's fast FFI sink expands every quad into six complete
-- vertices.  The GPU sees two triangles, but two corners are duplicated in
-- native memory, upload traffic and vertex-shader work.  Preserve the table
-- sink used by tests and alter only the FFI/GPU sink: four vertices per quad
-- plus the conventional 0,1,2,0,2,3 uint32 index sequence.
--
-- This is a textual adapter because Dramaless is an independently installed
-- mod. Every replacement is exact and single-use. A different release or an
-- already modified sink is refused instead of guessed at.

local Patch = {}

Patch.MARKER = "quest indexed FFI sink"
Patch.TRACE_MARKER = "quest transition mesh trace"

local function replaceOnce(source, before, after, label)
  local first, last = source:find(before, 1, true)
  if not first then return nil, label .. " anchor not found" end
  if source:find(before, last + 1, true) then
    return nil, label .. " anchor is ambiguous"
  end
  return source:sub(1, first - 1) .. after .. source:sub(last + 1)
end

function Patch.apply(source)
  if type(source) ~= "string" then return nil, "mesher source is not text" end
  source = source:gsub("\r\n", "\n")
  local alreadyIndexed = source:find(Patch.MARKER, 1, true) ~= nil
  local alreadyTraced = source:find(Patch.TRACE_MARKER, 1, true) ~= nil
  if alreadyIndexed and alreadyTraced then
    return source, "already indexed and traced"
  end
  if source:find("setVertexMap", 1, true) and not alreadyIndexed then
    return source, "foreign indexed sink preserved"
  end

  local err
  if not alreadyIndexed then
    source, err = replaceOnce(source, [=[
local TRI_ORDER = { 1, 2, 3, 1, 3, 4 }

local function newFfiSink()
  local cap = 4096 * 6
  local buf = ffi.new("float[?]", cap * 6)
  local n = 0
]=], [=[
local function newFfiSink()
  -- quest indexed FFI sink: four unique corners and six uint32 indices.
  local cap = 4096 * 4
  local buf = ffi.new("float[?]", cap * 6)
  local indexCap = 4096 * 6
  local indexBuf = ffi.new("uint32_t[?]", indexCap)
  local n, ni = 0, 0
]=], "sink declaration")
  if not source then return nil, err end

  source, err = replaceOnce(source, [=[
    push = function(c, uv, shade)
      if n + 6 > cap then
        local grown = ffi.new("float[?]", cap * 2 * 6)
        ffi.copy(grown, buf, n * 6 * 4)
        buf, cap = grown, cap * 2
      end
      local flat = type(shade) ~= "table"
      local base = n * 6
      for k = 1, 6 do
        local i = TRI_ORDER[k]
        local cc, t = c[i], uv[i]
        buf[base] = cc[1]
        buf[base + 1] = cc[2]
        buf[base + 2] = cc[3]
        buf[base + 3] = t[1]
        buf[base + 4] = t[2]
        buf[base + 5] = flat and shade or shade[i]
        base = base + 6
      end
      n = n + 6
    end,
]=], [=[
    push = function(c, uv, shade)
      if n + 4 > cap then
        local grown = ffi.new("float[?]", cap * 2 * 6)
        ffi.copy(grown, buf, n * 6 * 4)
        buf, cap = grown, cap * 2
      end
      if ni + 6 > indexCap then
        local grown = ffi.new("uint32_t[?]", indexCap * 2)
        ffi.copy(grown, indexBuf, ni * 4)
        indexBuf, indexCap = grown, indexCap * 2
      end
      local flat = type(shade) ~= "table"
      local base = n * 6
      for i = 1, 4 do
        local cc, t = c[i], uv[i]
        buf[base] = cc[1]
        buf[base + 1] = cc[2]
        buf[base + 2] = cc[3]
        buf[base + 3] = t[1]
        buf[base + 4] = t[2]
        buf[base + 5] = flat and shade or shade[i]
        base = base + 6
      end
      indexBuf[ni] = n
      indexBuf[ni + 1] = n + 1
      indexBuf[ni + 2] = n + 2
      indexBuf[ni + 3] = n
      indexBuf[ni + 4] = n + 2
      indexBuf[ni + 5] = n + 3
      n, ni = n + 4, ni + 6
    end,
]=], "quad writer")
  if not source then return nil, err end

  source, err = replaceOnce(source, [=[
          Budget.check()
        end
        return m
]=], [=[
          Budget.check()
        end
        local indexData = love.data.newByteData(ni * 4)
        ffi.copy(indexData:getFFIPointer(), indexBuf, ni * 4)
        m:setVertexMap(indexData, "uint32", ni)
        indexData:release()
        local questLog = rawget(_G, "QUEST_XR_LOG")
        if questLog then
          questLog(("Indexed terrain mesh vertices=%d indices=%d saved=%d")
            :format(n, ni, ni - n))
        end
        return m
]=], "indexed upload")
    if not source then return nil, err end
  end

  if not alreadyTraced then
    source, err = replaceOnce(source, [=[
local jobs = {}       -- FIFO of pending jobs
local jobIndex = {}   -- "id:slot" -> job

local clock = (love and love.timer and love.timer.getTime) or os.clock
]=], [=[
local jobs = {}       -- FIFO of pending jobs
local jobIndex = {}   -- "id:slot" -> job

local clock = (love and love.timer and love.timer.getTime) or os.clock

-- quest transition mesh trace: diagnostics only; scheduling is unchanged.
local function traceJob(event, job, ok, err)
  local questLog = rawget(_G, "QUEST_XR_LOG")
  if not questLog then return end
  local now = clock()
  local queued = job.queuedAt or now
  local started = job.startedAt or now
  questLog(("MESHJOB event=%s id=%s slot=%s urgent=%s pending=%d "
      .. "wait=%.2fms active=%.2fms resumes=%d ok=%s err=%s")
    :format(event, tostring(job.id), tostring(job.slot),
      tostring(job.urgent == true), #jobs,
      math.max(0, started - queued) * 1000,
      math.max(0, now - started) * 1000, job.resumes or 0,
      tostring(ok ~= false), err and tostring(err) or "-"))
end
]=], "trace declaration")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
local function finishJob(job, ok, err)
  jobIndex[jobKey(job.id, job.slot)] = nil
]=], [=[
local function finishJob(job, ok, err)
  traceJob("finish", job, ok, err)
  jobIndex[jobKey(job.id, job.slot)] = nil
]=], "trace finish")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
    job = { id = map.id, map = map, slot = slot, masks = masks,
            urgent = urgent or false, gen = gen[map.id] or 0 }
    jobIndex[key] = job
    jobs[#jobs + 1] = job
]=], [=[
    job = { id = map.id, map = map, slot = slot, masks = masks,
            urgent = urgent or false, gen = gen[map.id] or 0,
            queuedAt = clock(), resumes = 0 }
    jobIndex[key] = job
    jobs[#jobs + 1] = job
    traceJob("queue", job, true)
]=], "trace queue")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
    if not pick.co then
      pick.co = coroutine.create(runJob)
    end
    Budget.begin(pick.co, deadline - clock())
    local ok, err = coroutine.resume(pick.co, pick)
]=], [=[
    if not pick.co then
      pick.startedAt = clock()
      pick.co = coroutine.create(runJob)
      traceJob("start", pick, true)
    end
    pick.resumes = (pick.resumes or 0) + 1
    Budget.begin(pick.co, deadline - clock())
    local ok, err = coroutine.resume(pick.co, pick)
]=], "trace resume")
    if not source then return nil, err end
  end

  if alreadyIndexed then return source, "indexed and traced" end
  return source, "indexed and traced"
end

return Patch
