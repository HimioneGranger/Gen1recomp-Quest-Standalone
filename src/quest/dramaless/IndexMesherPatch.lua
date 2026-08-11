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
Patch.PHASE_MARKER = "quest Route 2 mesh phase trace"
Patch.GEOMETRY_PHASE_MARKER = "quest Route 2 geometry section trace"
Patch.WARM_LIVE_MARKER = "quest startup warm live set"
Patch.PACING_MARKER = "quest paced neighbour meshing"
Patch.REJECTED_CACHE_MARKER = "quest persistent indexed mesh cache"

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
  local alreadyPhased = source:find(Patch.PHASE_MARKER, 1, true) ~= nil
  local alreadyGeometryPhased = source:find(Patch.GEOMETRY_PHASE_MARKER, 1, true) ~= nil
  local alreadyWarmLive = source:find(Patch.WARM_LIVE_MARKER, 1, true) ~= nil
  local alreadyPaced = source:find(Patch.PACING_MARKER, 1, true) ~= nil
  local rejectedCache = source:find(Patch.REJECTED_CACHE_MARKER, 1, true) ~= nil
  local cacheRemoved = false
  if rejectedCache then
    local restored, restoreErr = replaceOnce(source, [=[
      return ok and mesh or nil
    end,
    payload = function()
      return { vertices = buf, n = n, indices = indexBuf, ni = ni }
    end,
  }
]=], [=[
      return ok and mesh or nil
    end,
  }
]=], "rejected persistent cache payload")
    if not restored then return nil, restoreErr end
    source = restored

    restored, restoreErr = replaceOnce(source, [=[
local jobs = {}       -- FIFO of pending jobs
local jobIndex = {}   -- "id:slot" -> job

-- quest persistent indexed mesh cache: raw GPU-neutral buffers only.
local QuestMeshCache = require("src.quest.dramaless.MeshCache")
]=], [=[
local jobs = {}       -- FIFO of pending jobs
local jobIndex = {}   -- "id:slot" -> job
]=], "rejected persistent cache declaration")
    if not restored then return nil, restoreErr end
    source = restored

    restored, restoreErr = replaceOnce(source, [=[
  local hit, mesh, water = QuestMeshCache.load(
    map, job.slot, job.masks, Voxel3D.FORMAT, Budget.check)
  if not hit then
    local sink = newSink()
    local waterSink = newSink()
    runGeometry(map, job.slot == "body", job.masks, sink, waterSink)
    mesh = sink.finish()
    water = waterSink.finish()
    if sink.payload and waterSink.payload then
      QuestMeshCache.save(map, job.slot, job.masks,
        sink.payload(), waterSink.payload(), Budget.check)
    end
  end
]=], [=[
  local sink = newSink()
  local waterSink = newSink()
  runGeometry(map, job.slot == "body", job.masks, sink, waterSink)
  local mesh = sink.finish()
  local water = waterSink.finish()
]=], "rejected persistent cache build")
    if not restored then return nil, restoreErr end
    source, cacheRemoved = restored, true
  end
  if alreadyPaced then
    local restored, restoreErr = replaceOnce(source, [=[
-- quest paced neighbour meshing: preserve every requested map, but keep
-- cooperative mesh construction inside a VR-safe share of each frame.
-- Optional neighbours are deliberately slow; the visible current map wins.
local URGENT_SLICE = 0.006
local IDLE_SLICE = 0.001
local COVERED_SLICE = 0.010
]=], [=[
-- quest rejected pacing restored: smaller nominal slices did not improve the
-- measured transition because individual meshing operations yield coarsely.
local URGENT_SLICE = 0.012
local IDLE_SLICE = 0.005
local COVERED_SLICE = 0.030
]=], "rejected Quest mesh pacing")
    if not restored then return nil, restoreErr end
    source, alreadyPaced = restored, false
  end
  if alreadyIndexed and alreadyTraced and alreadyPhased and alreadyGeometryPhased
     and alreadyWarmLive then
    return source, cacheRemoved and "indexed and traced; rejected persistent cache removed"
      or "indexed, traced, and phase-profiled"
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

  if not alreadyPhased then
    source, err = replaceOnce(source, [=[
local function runJob(job)
  local map = job.map
  local c = entry(job.id)
]=], [=[
local function runJob(job)
  local map = job.map
  local c = entry(job.id)
  -- quest Route 2 mesh phase trace: diagnostics only.
  local questPhaseStart = clock()
]=], "phase start")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
    if c.stale then c.stale.aux = nil end
  end
  local sink = newSink()
]=], [=[
    if c.stale then c.stale.aux = nil end
  end
  local questAuxDone = clock()
  local sink = newSink()
]=], "phase auxiliary boundary")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
  local sink = newSink()
  local waterSink = newSink()
  runGeometry(map, job.slot == "body", job.masks, sink, waterSink)
  local mesh = sink.finish()
  local water = waterSink.finish()
]=], [=[
  local sink = newSink()
  local waterSink = newSink()
  local questGeometryStart = clock()
  runGeometry(map, job.slot == "body", job.masks, sink, waterSink)
  local questGeometryDone = clock()
  local mesh = sink.finish()
  local questTerrainUploadDone = clock()
  local water = waterSink.finish()
  local questWaterUploadDone = clock()
  if job.id == "ROUTE_2" then
    local questLog = rawget(_G, "QUEST_XR_LOG")
    if questLog then
      questLog(("MESHPHASE id=%s slot=%s aux=%.2fms geometry=%.2fms "
          .. "terrainUpload=%.2fms waterUpload=%.2fms total=%.2fms")
        :format(tostring(job.id), tostring(job.slot),
          (questAuxDone - questPhaseStart) * 1000,
          (questGeometryDone - questGeometryStart) * 1000,
          (questTerrainUploadDone - questGeometryDone) * 1000,
          (questWaterUploadDone - questTerrainUploadDone) * 1000,
          (questWaterUploadDone - questPhaseStart) * 1000))
    end
  end
]=], "phase geometry and upload boundaries")
    if not source then return nil, err end
  end

  if not alreadyGeometryPhased then
    source, err = replaceOnce(source, [=[
local function runGeometry(map, bodyOnly, masks, sink, waterSink)
  local push = sink.push
]=], [=[
local function runGeometry(map, bodyOnly, masks, sink, waterSink)
  local push = sink.push
  -- quest Route 2 geometry section trace: diagnostics only.
  local questGeoClock = (love and love.timer and love.timer.getTime) or os.clock
  local questTilesStart = questGeoClock()
]=], "geometry section start")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
  for _, q in ipairs(S.objectQuads) do
]=], [=[
  local questTilesDone = questGeoClock()
  for _, q in ipairs(S.objectQuads) do
]=], "geometry object boundary")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
  -- true when the rect sits entirely inside one neighbour-body rect
]=], [=[
  local questObjectsDone = questGeoClock()
  -- true when the rect sits entirely inside one neighbour-body rect
]=], "geometry stamp preparation boundary")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
    end
  end
end

-- The raw geometry for `map`: (vertex list, triangle index list, quad
]=], [=[
    end
  end
  local questStampsDone = questGeoClock()
  if map.id == "ROUTE_2" then
    local questLog = rawget(_G, "QUEST_XR_LOG")
    if questLog then
      questLog(("MESHGEOMETRY id=%s body=%s tiles=%.2fms objects=%.2fms "
          .. "stamps=%.2fms total=%.2fms objectQuads=%d roundStamps=%d")
        :format(tostring(map.id), tostring(bodyOnly == true),
          (questTilesDone - questTilesStart) * 1000,
          (questObjectsDone - questTilesDone) * 1000,
          (questStampsDone - questObjectsDone) * 1000,
          (questStampsDone - questTilesStart) * 1000,
          #(S.objectQuads or {}), #(S.roundStamps or {})))
    end
  end
end

-- The raw geometry for `map`: (vertex list, triangle index list, quad
]=], "geometry section finish")
    if not source then return nil, err end
  end

  if not alreadyWarmLive then
    source, err = replaceOnce(source, [=[
local prevLive = {}

function ChunkMesher.setLive(live)
]=], [=[
local prevLive = {}

-- quest startup warm live set: retain a bounded location-derived corridor
-- while the native launch handoff prepares it.
local questWarmLive = {}

function ChunkMesher.setWarmLive(live)
  questWarmLive = live or {}
end

function ChunkMesher.setLive(live)
]=], "startup warm-live API")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
    if not live[id] and not prevLive[id] then
]=], [=[
    if not live[id] and not prevLive[id] and not questWarmLive[id] then
]=], "startup warm-live cache retention")
    if not source then return nil, err end

    source, err = replaceOnce(source, [=[
    if not live[job.id] and not prevLive[job.id] then
]=], [=[
    if not live[job.id] and not prevLive[job.id]
       and not questWarmLive[job.id] then
]=], "startup warm-live job retention")
    if not source then return nil, err end
  end

  return source, "indexed, traced, phase-profiled, and startup-warm"
end

return Patch
