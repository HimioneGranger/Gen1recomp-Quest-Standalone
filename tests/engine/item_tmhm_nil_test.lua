-- ItemEffects.use crashed instead of refusing when a species record carried
-- no tmhm list at all (ipairs(nil)), which is a different situation from a
-- species whose list simply does not name the move being taught -- that
-- case already refuses cleanly with MonCannotLearnMachineMoveText.  A mod
-- species missing the field entirely took the whole game down on the very
-- first TM/HM use rather than reaching that refusal.

package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local T = require("tests.harness").suite("item effects tmhm nil")
local Fixtures = require("tests.modkit.fixtures")
local ItemEffects = require("src.inventory.ItemEffects")
local Pokemon = require("src.pokemon.Pokemon")

local Data = Fixtures.fresh()
Data.pokemon.FIXMON_A.tmhm = nil

local mon = Pokemon.new(Data, "FIXMON_A", 10)
local save = { player = { name = "RED" } }

local ok, result, payload = pcall(ItemEffects.use, Data, save, "FIX_TM", mon)
T.check(ok, "using a TM on a species with no tmhm list does not crash: "
  .. tostring(result))
if ok then
  T.eq(result, "failed", "the species refuses the move instead of crashing into it")
  T.check(type(payload) == "table" and payload[1] ~= nil,
    "a refusal message is still returned")
end

T.finish()
