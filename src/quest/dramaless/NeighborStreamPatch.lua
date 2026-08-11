-- One-time rollback for the rejected Quest neighbour-stream experiment.
-- The experiment's marker is ours, so removal is limited to that marked
-- helper and its exact request-loop edit. Unmodified/foreign sources pass.

local Patch = {}

local MARKER = "quest first-person neighbour stream"
local PRIORITY_MARKER = "quest Route 2 neighbour priority"

local function replaceOnce(source, before, after, label)
  local first, last = source:find(before, 1, true)
  if not first then return nil, label .. " anchor not found" end
  if source:find(before, last + 1, true) then
    return nil, label .. " anchor is ambiguous"
  end
  return source:sub(1, first - 1) .. after .. source:sub(last + 1)
end

function Patch.apply(source)
  if type(source) ~= "string" then return nil, "VoxelScene source is not text" end
  source = source:gsub("\r\n", "\n")
  local marker = source:find("-- " .. MARKER, 1, true)
  if marker then
    local declaration = source:find("function VoxelScene.prefetch(state)",
      marker, true)
    if not declaration then return nil, "stream rollback declaration missing" end
    source = source:sub(1, marker - 1) .. source:sub(declaration)

    local restored, err = replaceOnce(source, [=[
  for i, nb in ipairs(state.neighbors or {}) do
    local near = questNearPlayer(state, nb)
    questTraceStream(nb.map.id, near)
    if near then ChunkMesher.request(nb.map, true) end
    nbMesh[i], nbWater[i] = ChunkMesher.pair(nb.map, true)
]=], [=[
  for i, nb in ipairs(state.neighbors or {}) do
    ChunkMesher.request(nb.map, true)
    nbMesh[i], nbWater[i] = ChunkMesher.pair(nb.map, true)
]=], "stream rollback request")
    if not restored then return nil, err end
    source = restored
  end

  if source:find(PRIORITY_MARKER, 1, true) then
    return source, "Route 2 priority preserved"
  end

  local prioritized, err = replaceOnce(source, [=[
  for i, nb in ipairs(state.neighbors or {}) do
    ChunkMesher.request(nb.map, true)
    nbMesh[i], nbWater[i] = ChunkMesher.pair(nb.map, true)
]=], [=[
  -- quest Route 2 neighbour priority: at the Viridian junction, start the
  -- northbound scenery before the costly westbound Indigo Plateau road.
  -- The standard loop below still requests and retains every neighbour.
  for _, nb in ipairs(state.neighbors or {}) do
    if nb.map.id == "ROUTE_2" then
      ChunkMesher.request(nb.map, true)
      break
    end
  end
  for i, nb in ipairs(state.neighbors or {}) do
    ChunkMesher.request(nb.map, true)
    nbMesh[i], nbWater[i] = ChunkMesher.pair(nb.map, true)
]=], "Route 2 priority request")
  if not prioritized then return nil, err end
  return prioritized, marker and "rejected stream restored; Route 2 prioritized"
    or "Route 2 prioritized"
end

return Patch
