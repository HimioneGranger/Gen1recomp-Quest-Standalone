-- Probe: the PACK opened from a real Gold battle menu, on a real overworld.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_battle_pack_probe.lua love .
--
-- BattlePack (engine/items/pack.asm) is a different jumptable from the field
-- PACK's, and its first four entries are .Oak: a key item picked mid-fight
-- prints OakThisIsntTheTimeText inside the pack.  Nothing here may reach the
-- field jumptable, whose ITEMFINDER arm quits the PACK -- over a battle that
-- takes the battle off the stack with it.
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")
local PackMenu = require("src.ui.gen2.PackMenu")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-battle-pack"

  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 6)
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local player = Mon.new(game.data, "CYNDAQUIL", 12)
  game.save.party = { player }
  game.save.inventory = { POKE_BALL = 5, POTION = 3, ITEMFINDER = 1,
    NORMAL_BOX = 1 }

  local wild = Mon.new(game.data, "PIDGEY", 4)
  assert(world:startBattle({ wild = wild }), "startBattle failed")

  -- DoBattleTransition owns the screen first; wBattleMode is only set when the
  -- battle screen itself goes on the stack.
  local battle
  for _ = 1, 600 do
    local top = game.stack:top()
    if top and top.battle then battle = top break end
    U.wait(1)
  end
  assert(battle, "battle screen never came up")
  assert(world.battleActive, "the world is not marked as in a battle")
  for _ = 1, 240 do
    if battle.phase == "menu" then break end
    tap("a", 3)
  end
  assert(battle.phase == "menu", "never reached the battle menu")

  -- The 2x2 grid: DOWN puts the cursor on PACK.
  tap("down")
  tap("a")
  local pack = game.stack:top()
  assert(getmetatable(pack) == PackMenu, "PACK did not open the pack")
  assert(pack:inBattle(), "the battle pack is not flagged as BattlePack")

  -- KEY ITEMS, then A on the ITEMFINDER.
  tap("right")
  tap("right")
  assert(pack:pocket().id == "KEY_ITEM",
    "did not reach the KEY ITEMS pocket: " .. tostring(pack:pocket().id))
  assert(pack.rows[1], "the key items pocket is empty")
  print("[driver] key item row 1 " .. tostring(pack.rows[1].id))
  tap("a")
  U.wait(4)
  U.shot(game, out .. "/00-battle-pack-oak.png")

  assert(pack.message and pack.message[1] == "OAK: {PLAYER}!",
    "the ITEMFINDER did not print OakThisIsntTheTimeText")
  assert(game.stack:top() == pack, "the pack left the stack")
  assert(world.battleActive, "battleActive was cleared by a field effect")
  assert(world.queuedScript == nil, "a field script was queued from a battle")
  assert(game.save.inventory.ITEMFINDER == 1, "the key item was spent")

  -- B clears the message, B again closes the pack, and the battle is still
  -- there underneath with its menu.
  tap("b")
  tap("b")
  for _ = 1, 120 do
    if battle.phase == "menu" then break end
    U.wait(1)
  end
  assert(game.stack:top() == battle, "the battle is not back on top")
  assert(battle.phase == "menu", "the battle menu did not come back")
  U.shot(game, out .. "/01-battle-menu-back.png")

  print("[driver] PASS gold battle pack in " .. out)
end
