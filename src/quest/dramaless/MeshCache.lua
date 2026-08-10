-- Versioned persistent indexed terrain cache for the Quest Dramaless adapter.
-- Stores only GPU-neutral vertex/index bytes. Unknown/corrupt entries miss.

local ffi = require("ffi")
local bit = require("bit")

local Cache = {}
local DIR = "quest_mesh_cache_v1"
local MAGIC = "QMC1"
local VERTEX_BYTES = 6 * 4

local function hashStep(h, byte)
  return bit.tobit(bit.bxor(h, byte) * 16777619)
end

local function hashText(h, value)
  local s = tostring(value or "")
  for i = 1, #s do h = hashStep(h, s:byte(i)) end
  return hashStep(h, 255)
end

local function keyFor(map, slot, masks)
  local h = -2128831035
  h = hashText(h, "qmc1-indexed-v1")
  h = hashText(h, map.id)
  h = hashText(h, slot)
  local def = map.def or {}
  h = hashText(h, def.width)
  h = hashText(h, def.height)
  h = hashText(h, def.borderBlock)
  h = hashText(h, def.tileset)
  for i, block in ipairs(def.blocks or {}) do
    h = hashText(h, i)
    h = hashText(h, block)
  end
  for i, rect in ipairs(masks or {}) do
    h = hashText(h, i)
    for j = 1, 4 do h = hashText(h, rect[j]) end
  end
  h = bit.tobit(h)
  if h < 0 then h = h + 4294967296 end
  return ("%08x"):format(h)
end

local function safeId(id)
  return tostring(id or "map"):gsub("[^%w_.-]", "_")
end

local function pathFor(map, slot, masks)
  return ("%s/%s-%s-%s.qmc"):format(
    DIR, safeId(map.id), slot, keyFor(map, slot, masks))
end

local function u32(value)
  value = value or 0
  return string.char(value % 256, math.floor(value / 256) % 256,
    math.floor(value / 65536) % 256, math.floor(value / 16777216) % 256)
end

local function readU32(data, at)
  local a, b, c, d = data:byte(at, at + 3)
  if not d then return nil end
  return a + b * 256 + c * 65536 + d * 16777216
end

local function log(message)
  local logger = rawget(_G, "QUEST_XR_LOG")
  if logger then logger(message) end
end

local function upload(raw, offset, vertices, indices, format, budget)
  if vertices == 0 then return nil, offset end
  local mesh = love.graphics.newMesh(format, vertices, "triangles", "static")
  local ptr = ffi.cast("const uint8_t *", raw)
  local first, chunk = 0, 65536
  while first < vertices do
    local count = math.min(chunk, vertices - first)
    local bytes = count * VERTEX_BYTES
    local data = love.data.newByteData(bytes)
    ffi.copy(data:getFFIPointer(), ptr + offset + first * VERTEX_BYTES, bytes)
    mesh:setVertices(data, first + 1)
    data:release()
    first = first + count
    if budget then budget() end
  end
  offset = offset + vertices * VERTEX_BYTES
  local indexBytes = indices * 4
  local indexData = love.data.newByteData(indexBytes)
  ffi.copy(indexData:getFFIPointer(), ptr + offset, indexBytes)
  mesh:setVertexMap(indexData, "uint32", indices)
  indexData:release()
  return mesh, offset + indexBytes
end

function Cache.load(map, slot, masks, format, budget)
  local path = pathFor(map, slot, masks)
  local raw = love.filesystem.read(path)
  if type(raw) ~= "string" or #raw < 20 or raw:sub(1, 4) ~= MAGIC then
    log(("MESHCACHE event=miss id=%s slot=%s"):format(map.id, slot))
    return false
  end
  local tv, ti = readU32(raw, 5), readU32(raw, 9)
  local wv, wi = readU32(raw, 13), readU32(raw, 17)
  if not (tv and ti and wv and wi) then return false end
  local expected = 20 + (tv + wv) * VERTEX_BYTES + (ti + wi) * 4
  if expected ~= #raw or ti > tv * 2 or wi > wv * 2
      or (wv == 0 and wi ~= 0) then
    log(("MESHCACHE event=reject id=%s slot=%s bytes=%d expected=%d")
      :format(map.id, slot, #raw, expected))
    return false
  end
  local ok, terrain, water = pcall(function()
    local at = 20
    local m
    m, at = upload(raw, at, tv, ti, format, budget)
    local w
    if wv > 0 then w, at = upload(raw, at, wv, wi, format, budget) end
    return m, w
  end)
  if not ok or not terrain then
    if terrain and terrain.release then pcall(terrain.release, terrain) end
    if water and water.release then pcall(water.release, water) end
    log(("MESHCACHE event=reject id=%s slot=%s upload=true")
      :format(map.id, slot))
    return false
  end
  log(("MESHCACHE event=hit id=%s slot=%s vertices=%d indices=%d")
    :format(map.id, slot, tv + wv, ti + wi))
  return true, terrain, water
end

local function writeBuffer(file, ptr, bytes, budget)
  local at, chunk = 0, 1024 * 1024
  while at < bytes do
    local count = math.min(chunk, bytes - at)
    assert(file:write(ffi.string(ptr + at, count)))
    at = at + count
    if budget then budget() end
  end
end

function Cache.save(map, slot, masks, terrain, water, budget)
  if not terrain or terrain.n == 0 then return false end
  local path = pathFor(map, slot, masks)
  love.filesystem.createDirectory(DIR)
  local file = love.filesystem.newFile(path)
  local ok, err = pcall(function()
    assert(file:open("w"))
    local wv, wi = water and water.n or 0, water and water.ni or 0
    assert(file:write(MAGIC .. u32(terrain.n) .. u32(terrain.ni)
      .. u32(wv) .. u32(wi)))
    writeBuffer(file, ffi.cast("const uint8_t *", terrain.vertices),
      terrain.n * VERTEX_BYTES, budget)
    writeBuffer(file, ffi.cast("const uint8_t *", terrain.indices),
      terrain.ni * 4, budget)
    if water then
      writeBuffer(file, ffi.cast("const uint8_t *", water.vertices),
        water.n * VERTEX_BYTES, budget)
      writeBuffer(file, ffi.cast("const uint8_t *", water.indices),
        water.ni * 4, budget)
    end
    file:close()
  end)
  if not ok then pcall(file.close, file) end
  log(("MESHCACHE event=%s id=%s slot=%s err=%s")
    :format(ok and "store" or "store_fail", map.id, slot,
      ok and "-" or tostring(err)))
  return ok
end

return Cache
