-- Smoke: Gold bedroom → downstairs → outside → house → carpet out → Route 29.
--
-- A New Game now starts at SPAWN_HOME (PLAYERS_HOUSE_2F 3,3), the way
-- engine/menus/intro_menu.asm NewGame does, so the walk begins upstairs: the
-- stairs warp is at (7,0) on 2F and the front door at (6,7)/(7,7) on 1F.
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_walk_smoke.lua love .
return function(game)
  local function wait(frames)
    for _ = 1, frames do coroutine.yield() end
  end

  local function clearDirs()
    for _, d in ipairs({ "up", "down", "left", "right" }) do
      game.input.state[d] = false
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
  end

  -- Entering the house runs MeetMomScript, and a driver that only holds a
  -- direction would sit behind its text boxes forever.  Tap A until the world
  -- accepts input again.  That script is long -- an approach walk, ten text
  -- boxes and three yes/no prompts, ~1300 frames at this tap rate -- so the
  -- budget has to be generous or the run looks like a hang.
  local function clearDialogue()
    for _ = 1, 1200 do
      if not game.world:busy() then return end
      table.insert(game.input.pressQueue, "a")
      coroutine.yield()
      coroutine.yield()
    end
  end

  local function mapId()
    return game.world and game.world.map and game.world.map.id
  end

  local function pos()
    local p = game.world.player
    return p.cellX, p.cellY
  end

  wait(45)
  assert(mapId() == "PLAYERS_HOUSE_2F", "boot map " .. tostring(mapId()))

  -- The bedroom is where a New Game lands, but this driver is about warps and
  -- the Route 29 edge crossing, and the indoor route down two floors is a
  -- fragile way to get to them.  Drop straight outside instead: the door and
  -- carpet warps below are the ones under test.
  game.world:setMap("NEW_BARK_TOWN", 13, 6, "down")
  wait(15)
  assert(mapId() == "NEW_BARK_TOWN",
    ("after setMap: %s @ (%d,%d)"):format(tostring(mapId()), pos()))

  -- Walk back into the player's house door (one cell north of the doorstep).
  hold("up", 40)
  wait(15)
  assert(mapId() == "PLAYERS_HOUSE_1F",
    "after door: " .. tostring(mapId()))
  clearDialogue()

  -- Entry faces up and keeps walking off the carpet into the room; hold
  -- down to step back onto the carpet and warp out.
  hold("down", 60)
  wait(15)
  -- Walking in can trip another coord script; clear it and try the carpet
  -- again before deciding the exit is broken.
  clearDialogue()
  if mapId() ~= "NEW_BARK_TOWN" then
    hold("up", 24)
    clearDialogue()
    hold("down", 48)
    wait(15)
  end
  assert(mapId() == "NEW_BARK_TOWN",
    ("after carpet: %s @ (%d,%d)"):format(tostring(mapId()), pos()))

  -- New Bark's west exit is gated: at scene SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU
  -- the coord events at (1,8)/(1,9) run the teacher's "It's dangerous to go out
  -- without a POKéMON!" script and walk the player back, so a party-less save
  -- can never reach Route 29.  ElmsLab.asm sets the town to SCENE_NEWBARKTOWN_
  -- NOOP once the errand starts; do the same rather than fight the guard.
  game.world.mapScenes["NEW_BARK_TOWN"] = 1

  -- West→Route 29 only has a walkable landing at y=9: row 8 has the tree at
  -- x=8 and row 10 is wall west of x=6.  Re-square onto y=9 every pass rather
  -- than only after a bump, and bound the walk -- a wandering townsfolk can
  -- stand in the way for a step or two, and an unbounded retry loop turns that
  -- into a run that never ends.
  local x, y = pos()
  for _ = 1, 60 do
    if mapId() == "ROUTE_29" then break end
    assert(mapId() == "NEW_BARK_TOWN",
      "unexpected map " .. tostring(mapId()))
    if y < 9 then
      hold("down", 24)
    elseif y > 9 then
      hold("up", 24)
    else
      hold("left", 24)
    end
    x, y = pos()
  end
  assert(mapId() == "ROUTE_29",
    ("after west edge: %s @ (%d,%d)"):format(tostring(mapId()), pos()))

  print("[driver] PASS gold walk house + Route 29")
end
