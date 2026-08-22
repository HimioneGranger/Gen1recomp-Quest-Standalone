-- ROM-free entry point for the upstream hostile-link corpus.
-- It seeds the Data singleton from tests/fixture_data and supplies aliases for
-- the five canonical species names used only to make representative packets.
--   luajit tests/engine/link_hostile_fixture.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

love = require("tests.love_stub")

local Data = require("src.core.Data")
local fixture = require("tests.fixture_data").load()
for key, value in pairs(fixture) do Data[key] = value end

local aliases = {
  PIKACHU = "FIXMON_A",
  KADABRA = "FIXMON_A",
  MACHOKE = "FIXMON_B",
  CHARIZARD = "FIXMON_B",
  BLASTOISE = "FIXMON_C",
  RATTATA = "FIXMON_C",
}
for name, source in pairs(aliases) do
  Data.pokemon[name] = Data.pokemon[source]
end

assert(dofile("tests/link_hostile.lua"))
