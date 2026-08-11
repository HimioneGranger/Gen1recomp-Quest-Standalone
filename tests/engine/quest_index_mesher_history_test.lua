-- The Quest source adapter must add one narrow lifecycle seam to the exact
-- Dramaless mesher and remain idempotent across hot reload/repackaging.
--   luajit tests/engine/quest_index_mesher_history_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
local Patch = require("src.quest.dramaless.IndexMesherPatch")

-- All older adapter markers are present so this fixture isolates the new
-- insertion without copying the independently distributed Dramaless source.
local source = [[
-- quest indexed FFI sink
-- quest transition mesh trace
-- quest Route 2 mesh phase trace
-- quest Route 2 geometry section trace
-- quest startup warm live set
-- quest promoted body release
local ChunkMesher = {}
local cache = { OLD = true }
local prevLive = { OLD = true }
function ChunkMesher.setLive(live)
  for id in pairs(cache) do
    if not live[id] and not prevLive[id] then cache[id] = nil end
  end
  prevLive = live
end
function ChunkMesher.has(id) return cache[id] ~= nil end
return ChunkMesher
]]

local patched, note = Patch.apply(source)
check(type(patched) == "string", "history seam patch applies")
check(note:find("route%-history bounded") ~= nil,
  "adapter reports the bounded-history policy")
local markerCount, at = 0, 1
while true do
  local first, last = patched:find(Patch.HISTORY_DROP_MARKER, at, true)
  if not first then break end
  markerCount, at = markerCount + 1, last + 1
end
eq(markerCount, 1, "history seam marker appears exactly once")

local again = assert(Patch.apply(patched))
eq(again, patched, "history seam patch is idempotent")

local mesher = assert(loadstring(patched))()
check(mesher.has("OLD"), "previous generation starts retained")
mesher.dropPrevious()
mesher.setLive({ NEW = true })
check(not mesher.has("OLD"), "cleared history evicts an old non-live map")

T.finish("Quest indexed mesher history")
