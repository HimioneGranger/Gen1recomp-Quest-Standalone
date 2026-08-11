-- Quest-only lifecycle seam for independently installed Dramaless Shape.
--
-- Keep this separate from the indexed-vertex optimization: a changed or
-- already-indexed FFI sink must not prevent the small public lifecycle API
-- from being installed. Every edit remains exact, source-guarded and
-- idempotent.

local Patch = {}

Patch.WARM_LIVE_MARKER = "quest startup warm live set"
Patch.BODY_DROP_MARKER = "quest promoted body release"
Patch.HISTORY_DROP_MARKER = "quest seamless previous-set release"

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

  local warm = source:find(Patch.WARM_LIVE_MARKER, 1, true) ~= nil
  local body = source:find(Patch.BODY_DROP_MARKER, 1, true) ~= nil
  local history = source:find(Patch.HISTORY_DROP_MARKER, 1, true) ~= nil
  if warm and body and history then
    return source, "warm-live, body-drop, and route-history lifecycle ready"
  end

  local err
  if not warm then
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

  if not body then
    source, err = replaceOnce(source, [=[
function ChunkMesher.setLive(live)
]=], [=[
-- quest promoted body release: once a prebuilt full destination becomes the
-- current map, its neighbour-only body variant is redundant. Release just
-- that GPU pair; shared Structures analysis and the full mesh stay live.
function ChunkMesher.dropBody(mapId)
  local c = cache[mapId]
  if not c then return false end
  local key = jobKey(mapId, "body")
  local job = jobIndex[key]
  if job then
    jobIndex[key] = nil
    for i = #jobs, 1, -1 do
      if jobs[i] == job then table.remove(jobs, i) break end
    end
  end
  swapSlot(c, "body", nil)
  swapSlot(c, waterSlot("body"), nil)
  if c.stale then c.stale.body = nil end
  return true
end

function ChunkMesher.setLive(live)
]=], "promoted body release API")
    if not source then return nil, err end
  end

  if not history then
    source, err = replaceOnce(source, [=[
function ChunkMesher.setLive(live)
]=], [=[
-- quest seamless previous-set release: connected-map crossings already keep
-- the map behind the player in the new live set. Door warps deliberately do
-- not call this API, preserving their warm return path.
function ChunkMesher.dropPrevious()
  prevLive = {}
end

function ChunkMesher.setLive(live)
]=], "seamless previous-set release API")
    if not source then return nil, err end
  end

  return source, "warm-live, body-drop, and route-history lifecycle ready"
end

return Patch
