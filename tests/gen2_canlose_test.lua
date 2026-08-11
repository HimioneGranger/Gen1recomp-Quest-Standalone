-- BATTLETYPE_CANLOSE: losing the Cherrygrove rival battle must NOT whiteout.
--
--   GOLD_CACHE=".../gold" luajit tests/gen2_canlose_test.lua
--
-- maps/CherrygroveCity.asm arms all three rival arms with
--
--   loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE
--   startbattle
--   dontrestartmapmusic
--   reloadmap
--   iftrue .AfterYourDefeat
--
-- and the type changes what a loss MEANS.  LostBattle (engine/battle/
-- core.asm) answers BATTLETYPE_CANLOSE by sliding the winner's pic in and
-- printing the loss text, then RETURNS: no grayscale, no whiteout script, no
-- money halved.  The script continues at the battle site -- `reloadmap`, not
-- `reloadmapafterbattle`, so Script_BattleWhiteout is unreachable -- and its
-- .AfterYourDefeat arm plays the "you lost" line, the shove and the rival's
-- walk-off along his own scripted path, ending on `special HealParty`.
--
-- The port warped every loss to the spawn point and then let the script
-- resume, so the rival's exit movement replayed at the Pokemon Center door,
-- walking him through the trees that stand there.  What is asserted here is
-- the loss arm of the REAL World:startScriptedBattle -> World:startBattle
-- chain, with the type armed the way Script_loadvar arms it.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 canlose")
local check, eq = S.check, S.eq

local World = require("src.world.gen2.World")
local Map = require("src.world.gen2.Map")
local Mon = require("src.battle.gen2.Mon")

local cache = os.getenv("GOLD_CACHE")
if not cache then
  local home = os.getenv("HOME") or ""
  cache = home .. "/Library/Application Support/LOVE/gold-dev/gold"
end
local probe = io.open(cache .. "/data/generated/maps.lua", "r")
if not probe then
  check(true, "gold cache absent (SKIP)")
  S.finish()
  return
end
probe:close()

local function loadLua(rel) return assert(loadfile(cache .. "/" .. rel))() end
local maps = loadLua("data/generated/maps.lua")
local tilesets = loadLua("data/generated/tilesets.lua")
local pokemon = loadLua("data/generated/pokemon.lua")
local moves = loadLua("data/generated/moves.lua")

-- constants/battle_constants.asm / engine/overworld/variables.asm.
local VAR_BATTLETYPE = 0x03
local BATTLETYPE_CANLOSE = 1

-- The two battle screens as registry fakes: the transition hands off
-- immediately, the battle parks its onDone for the test to lose with.
local battleDone
local registry = {
  Gen2BattleTransition = { new = function(_g, opts)
    opts.onDone()
    return { screenId = "Gen2BattleTransition" }
  end },
  Gen2BattleState = { new = function(_g, opts)
    battleDone = opts.onDone
    return { screenId = "Gen2BattleState" }
  end },
}

local function makeStack()
  local stack = { items = {} }
  function stack:push(inst) self.items[#self.items + 1] = inst end
  function stack:pop()
    local top = self.items[#self.items]
    self.items[#self.items] = nil
    return top
  end
  return stack
end

-- The rival's record, in the shape World:trainerParty answers `loadtrainer`
-- with: a roster Trainers.party builds real mons from.
local function rivalRecord()
  return {
    class = "RIVAL1", classId = 9, id = 1,
    name = "?", className = "RIVAL", trainerName = "?",
    roster = { { species = "TOTODILE", level = 5 } },
    baseMoney = 35,
  }
end

local function makeWorld()
  battleDone = nil
  local game = {
    data = { audio = {}, screens = registry, pokemon = pokemon,
      moves = moves },
    save = {
      player = { name = "GOLD", money = 3000 },
      -- The loser's party: wiped, the way a lost battle leaves it.
      party = {},
      -- Walking into the Cherrygrove centre banked the respawn there, so a
      -- whiteout that DOES fire has somewhere deterministic to land.
      blackoutMap = "CHERRYGROVE_POKECENTER_1F",
    },
    stack = makeStack(),
  }
  local mon = Mon.new(game.data, "CYNDAQUIL", 5)
  check(mon ~= nil, "the cache can build the player's starter")
  mon.hp = 0
  game.save.party[1] = mon
  local w = World.new(game)
  w.maps, w.tilesets = maps, tilesets
  w.map = Map.new(maps.CHERRYGROVE_CITY, tilesets[maps.CHERRYGROVE_CITY.tileset])
  w.player = { cellX = 39, cellY = 7, facing = "right", moving = false }
  w.loaded = nil
  w.setMap = function(self, id, x, y, facing)
    self.loaded = { id = id, x = x, y = y, facing = facing }
    return true
  end
  return w, game
end

-- ---- the rival's loss: armed CANLOSE, no whiteout -------------------------
do
  local w, game = makeWorld()
  -- Script_loadvar's write, exactly as the extracted script runs it.
  w:writeVar(VAR_BATTLETYPE, BATTLETYPE_CANLOSE)
  eq(w:battleType(), BATTLETYPE_CANLOSE, "the type is armed")

  local outcome
  check(w:startScriptedBattle(rivalRecord(), nil, function(result)
    outcome = result
  end), "the scripted battle starts")
  check(battleDone ~= nil, "the battle screen is up")
  battleDone("lose")

  eq(outcome, "lose",
    "the script resumes with LOSE, so `iftrue` takes .AfterYourDefeat")
  check(w.loaded == nil,
    "no warp: the loser is still standing at the battle site")
  eq(game.save.player.money, 3000, "no HalveMoney either")
  eq(game.save.party[1].hp, 0,
    "and no engine heal -- .FinishRival's `special HealParty` owns that")
end

-- ---- the same loss without CANLOSE whiteouts as before --------------------
do
  local w, game = makeWorld()
  eq(w:battleType(), 0, "no type armed: an ordinary trainer loss")

  local outcome
  check(w:startScriptedBattle(rivalRecord(), nil, function(result)
    outcome = result
  end), "the battle starts")
  battleDone("lose")

  eq(outcome, "lose", "the resume still reports the loss")
  check(w.loaded ~= nil, "Script_BattleWhiteout warps home")
  eq(w.loaded.id, "CHERRYGROVE_POKECENTER_1F", "to the banked centre")
  eq(game.save.player.money, 1500, "with the wallet halved")
  check(game.save.party[1].hp > 0, "and the party healed")
end

-- ---- the type is a one-shot, as BattleStart resets wBattleType ------------
do
  local w = makeWorld()
  w:writeVar(VAR_BATTLETYPE, BATTLETYPE_CANLOSE)
  check(w:startScriptedBattle(rivalRecord(), nil, function() end),
    "a CANLOSE battle starts")
  eq(w:battleType(), 0, "and consumes the type on the way in")
  battleDone("win")
end

-- ---- the premise, pinned against the cache --------------------------------
-- The extracted rival scene really is the cart's shape: `loadvar 3, 1` (VAR_
-- BATTLETYPE, BATTLETYPE_CANLOSE), `startbattle`, then a bare `reloadmap` --
-- never `reloadmapafterbattle` -- and a loss arm whose walk-off movements and
-- `special` HealParty run at the battle site.  A re-import that lost any of
-- this would green the units above while the game diverged.
do
  local scripts = loadLua("data/generated/scripts.lua")
  local seen = 0
  for _, ev in ipairs(maps.CHERRYGROVE_CITY.coordEvents or {}) do
    local body = scripts[ev.scriptKey]
    if body then
      seen = seen + 1
      local armed, battled, reloaded, afterBattle
      for index, cmd in ipairs(body) do
        if cmd.op == "loadvar" and cmd.args and cmd.args[1] == VAR_BATTLETYPE
        then
          eq(cmd.args[2], BATTLETYPE_CANLOSE,
            ev.scriptKey .. " arms BATTLETYPE_CANLOSE")
          armed = index
        elseif cmd.op == "startbattle" then
          battled = index
        elseif cmd.op == "reloadmap" then
          reloaded = index
        elseif cmd.op == "reloadmapafterbattle" then
          afterBattle = index
        end
      end
      check(armed and battled and reloaded and armed < battled
        and battled < reloaded,
        ev.scriptKey .. ": loadvar before startbattle before reloadmap")
      check(afterBattle == nil,
        ev.scriptKey .. " never runs reloadmapafterbattle")
    end
  end
  check(seen >= 2, "both rival coord events carry extracted bodies")
end

S.finish()
