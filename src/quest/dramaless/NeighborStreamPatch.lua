-- One-time rollback for the rejected Quest neighbour-stream experiment.
-- The experiment's marker is ours, so removal is limited to that marked
-- helper and its exact request-loop edit. Unmodified/foreign sources pass.

local Patch = {}

local MARKER = "quest first-person neighbour stream"

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
  if not marker then return source, "standard neighbour policy preserved" end

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
  return restored, "rejected neighbour stream restored"
end

return Patch
