-- The lifecycle seam must install independently of the indexed FFI adapter
-- and remain idempotent on the independently installed Dramaless source.
--   luajit tests/engine/quest_mesher_lifetime_patch_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
local Patch = require("src.quest.dramaless.MesherLifetimePatch")

local source = [[
local ChunkMesher = {}
local cache = { OLD = {}, WARM = {} }
local jobs = {}
local jobIndex = {}
local function jobKey(id, slot) return id .. ":" .. slot end
local function swapSlot() end
local function waterSlot(slot) return slot .. "Water" end
local prevLive = {}

function ChunkMesher.setLive(live)
  for id, c in pairs(cache) do
    if not live[id] and not prevLive[id] then
      cache[id] = nil
    end
  end
  for i = #jobs, 1, -1 do
    local job = jobs[i]
    if not live[job.id] and not prevLive[job.id] then
      jobIndex[jobKey(job.id, job.slot)] = nil
      table.remove(jobs, i)
    end
  end
  prevLive = live
end

function ChunkMesher.has(id) return cache[id] ~= nil end
return ChunkMesher
]]

local patched, note = Patch.apply(source)
check(type(patched) == "string", "independent lifecycle patch applies")
check(note:find("route%-history lifecycle ready") ~= nil,
  "adapter reports all lifecycle APIs ready")

local again = assert(Patch.apply(patched))
eq(again, patched, "independent lifecycle patch is idempotent")

local mesher = assert(loadstring(patched))()
check(type(mesher.dropPrevious) == "function", "history API is exported")
check(type(mesher.dropBody) == "function", "body API is exported")
check(type(mesher.setWarmLive) == "function", "warm-live API is exported")

mesher.setWarmLive({ WARM = true })
mesher.dropPrevious()
mesher.setLive({ NEW = true })
check(not mesher.has("OLD"), "old non-live map evicts after history drop")
check(mesher.has("WARM"), "bounded startup warm map remains retained")

T.finish("Quest mesher lifetime patch")
