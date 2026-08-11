-- The command queue, on the map that needs it.
--
-- `writecmdqueue` / `delcmdqueue` were no-ops because there was no wCmdQueue
-- engine (engine/overworld/cmd_queue.asm, polled once a frame).  Ice Path B1F
-- is one of the two maps that use CMDQUEUE_STONETABLE, and it is the one that
-- matters: the queue is what makes a pushed boulder fall through the hole, Ice
-- Path gates Blackthorn, and Blackthorn is the eighth badge.
--
-- This pushes ICEPATHB1F_BOULDER1 north onto warp 3 at (11,2) with STRENGTH
-- active, and asserts the boulder falls and its twin one floor down appears.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_icepath_boulder.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
local SHOT_DIR = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-icepath"

return function(game)
  local w = game.world
  local fails = 0

  local function wait(n) for _ = 1, n do coroutine.yield() end end

  local function ok(cond, msg)
    if cond then print("[icepath] ok   " .. msg)
    else fails = fails + 1 print("[icepath] FAIL " .. msg) end
    return cond
  end

  local function clearDirs()
    game.input.pressQueue = {}
    for _, d in ipairs({ "up", "down", "left", "right" }) do
      game.input.state[d] = false
      game.input.sources[d] = nil
    end
  end

  local function hold(dir, frames)
    clearDirs()
    for _ = 1, frames do
      table.insert(game.input.pressQueue, dir)
      game.input.state[dir] = true
      coroutine.yield()
    end
    clearDirs()
    coroutine.yield()
  end

  local function boulder()
    for _, npc in ipairs(w.npcs) do
      if npc.def and npc.def.index == 1 then return npc end
    end
    return nil
  end

  os.execute('mkdir -p "' .. SHOT_DIR .. '" 2>/dev/null')
  wait(45)

  -- ICEPATHB1F_BOULDER1's hole is warp 3 at (11,2), and (11,4) is wall, so the
  -- boulder reaches it from the WEST: the last push of the puzzle is the player
  -- at (9,2) walking right into a boulder on (10,2).
  --
  -- The boulder starts the map at (11,7) and the route between is most of the
  -- floor's maze.  This driver is about the queue, not about the maze, so it
  -- parks the boulder on the cell the maze delivers it to and performs the LAST
  -- push for real.  Nothing else is faked: the push is a walk, the fall is the
  -- queue noticing, and the script is the map's own.
  w:setMap("ICE_PATH_B1F", 9, 2, "right")
  wait(20)
  ok(w.map.id == "ICE_PATH_B1F", "on Ice Path B1F")

  local CmdQueue = require("src.world.gen2.CmdQueue")
  ok(CmdQueue.count(w.cmdQueue) == 1,
    "the map load wrote its MAPCALLBACK_CMDQUEUE entry ("
      .. CmdQueue.count(w.cmdQueue) .. " slot(s) used)")

  local b = boulder()
  ok(b ~= nil, "boulder 1 is on the map")
  ok(b and b.cellX == 11 and b.cellY == 7,
    ("at its spawn (11,7), got (%s,%s)"):format(tostring(b and b.cellX),
      tostring(b and b.cellY)))
  ok(w.map:cellCollision(11, 2) == 0x60,
    "and the tile at its hole is COLL_PIT")

  -- One cell west of the hole, which is where the maze push route ends.
  b.cellX, b.cellY = 10, 2
  b.homeX, b.homeY = 10, 2
  b.px, b.py = 10 * 16, 2 * 16
  ok(w.map:isWalkable(10, 2), "the cell it is pushed from is floor")

  -- BIKEFLAGS_STRENGTH_ACTIVE, which .CheckStrengthBoulder reads.  Getting it
  -- the honest way needs a party with STRENGTH and the RISING BADGE; this
  -- driver is about the queue, not about the field move.
  w.strengthActive = true

  game.capturePath = SHOT_DIR .. "/before.png"
  wait(2)

  -- The push: walking into an occupied cell with STRENGTH active is what
  -- .CheckStrengthBoulder turns into a step for the boulder instead.
  for i = 1, 3 do
    hold("right", 40)
    local bb = boulder()
    print(("[icepath] push %d: player (%d,%d) boulder (%s,%s)"):format(
      i, w.player.cellX, w.player.cellY,
      tostring(bb and bb.cellX), tostring(bb and bb.cellY)))
    if w:busy() or bb == nil then break end
  end

  -- The queue drops it on the first frame it is standing on the pit, and the
  -- script that runs is pause 30 / SFX_STRENGTH / earthquake 80 / the line.
  local fell = false
  for _ = 1, 400 do
    if w:busy() then fell = true break end
    wait(2)
  end
  ok(fell, "something started once the boulder reached the hole")
  game.capturePath = SHOT_DIR .. "/falling.png"
  wait(4)

  for _ = 1, 400 do
    if not w:busy() then break end
    table.insert(game.input.pressQueue, "a")
    wait(3)
  end
  wait(20)

  ok(boulder() == nil, "the boulder is gone from B1F")
  -- EVENT_BOULDER_IN_ICE_PATH_1A (1805) hides the twin on the floor below; the
  -- script CLEARS it, which is what puts the fallen boulder down there.
  ok(w.events:get(1805) == false,
    "and EVENT_BOULDER_IN_ICE_PATH_1A is clear, so it is on B2F now")
  game.capturePath = SHOT_DIR .. "/after.png"
  wait(4)

  -- Follow it down and look.
  w:setMap("ICE_PATH_B2F_MAHOGANY_SIDE", 11, 5, "up")
  wait(30)
  local below = nil
  for _, npc in ipairs(w.npcs) do
    if npc.def and npc.def.index == 1 then below = npc end
  end
  ok(below ~= nil and below.cellX == 11 and below.cellY == 3,
    "the boulder is standing on B2F at (11,3)")
  game.capturePath = SHOT_DIR .. "/below.png"
  wait(30)

  if fails > 0 then
    error(("gold ice path: %d assertion(s) failed"):format(fails))
  end
  print("[driver] PASS gold command queue: the boulder fell through")
end
