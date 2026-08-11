-- The door warp, end to end, on the map a player meets it on first.
--
-- Walking onto a warp tile is PLAYEREVENT_WARP -> WarpToNewMapScript
-- (engine/overworld/events.asm), which is `warpsound` then
-- `newloadmap MAPSETUP_DOOR`.  MapSetupScript_Door opens on FadeOutToWhite and
-- falls through into _Train, whose tail is FadeInFromWhite, so the load sits in
-- the MIDDLE of the setup script.  This driver asserts the three things that
-- were wrong, and shoots the fade so a human can see it:
--
--   1. the warp makes a sound, picked off the tile the player stands on;
--   2. the screen fades out and back in around the load, holding input for the
--      sixteen frames it runs (four steps of ConvertTimePals*HL, DelayFrames 2
--      apart, per half);
--   3. the player lands on the doormat at (4,11) and the lab's own scene script
--      walks them the nine steps of ElmsLab_WalkUpToElmMovement to (4,2) facing
--      right -- NOT to (4,1), which is where a free step stolen by a still-held
--      direction used to leave them.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_warp_scene.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
--
-- Shots land in /tmp/gold-warp.
local SHOT_DIR = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-warp"

return function(game)
  local w = game.world
  local fails = 0

  local function wait(n) for _ = 1, n do coroutine.yield() end end

  local function ok(cond, msg)
    if cond then
      print("[warp] ok   " .. msg)
    else
      fails = fails + 1
      print("[warp] FAIL " .. msg)
    end
    return cond
  end

  local function shot(name)
    game.capturePath = SHOT_DIR .. "/" .. name .. ".png"
    coroutine.yield()
  end

  local function cell()
    local p = w.player
    return p.cellX, p.cellY, p.facing
  end

  local function holdInto(dir, limit)
    local from = w.map.id
    local levels, shots = {}, 0
    for _ = 1, limit do
      table.insert(game.input.pressQueue, dir)
      game.input.state[dir] = true
      if w.mapSetup then
        levels[#levels + 1] = w.fadeLevel
        shots = shots + 1
        game.capturePath = ("%s/fade-%02d.png"):format(SHOT_DIR, shots)
      end
      coroutine.yield()
      if w.map.id ~= from and not w.mapSetup then break end
    end
    game.input.pressQueue = {}
    game.input.state[dir] = false
    game.input.sources[dir] = nil
    return levels
  end

  os.execute('mkdir -p "' .. SHOT_DIR .. '" 2>/dev/null')
  wait(45)

  -- The teacher's coord event at the west edge gates a party-less save; the
  -- errand script clears it, and this driver is about the door, not the guard.
  w.mapScenes.NEW_BARK_TOWN = 1
  w:setMap("NEW_BARK_TOWN", 6, 5, "up")
  wait(15)

  -- GetWarpSFX reads the tile the player is STANDING on, so the sound belongs to
  -- the doorway they walk into, not to the room they arrive in.
  local sfx = {}
  local realPlaySfx = w.playSfx
  w.playSfx = function(self, id) sfx[#sfx + 1] = id realPlaySfx(self, id) end

  local levels = holdInto("up", 180)
  ok(w.map.id == "ELMS_LAB", "the door warps into the lab (" .. w.map.id .. ")")
  ok(#sfx > 0, "and it makes a sound (" .. #sfx .. " sfx)")
  -- Four rising levels, four falling, with the solid frame in between.
  ok(#levels >= 12,
    "the fade ran for " .. #levels .. " frames (sixteen is the full chain)")
  local peak = 0
  for _, v in ipairs(levels) do if (v or 0) > peak then peak = v end end
  ok(peak == 1, "and reached a solid sheet (peak " .. tostring(peak) .. ")")
  ok(w.fade == nil, "which is gone by the time control comes back")

  local x, y, facing = cell()
  ok(x == 4 and y == 11,
    ("lands on the doormat at (4,11), got (%d,%d)"):format(x, y))
  ok(facing == "up",
    "still facing up: the mat inside is a carpet, not a CheckWarpFacingDown "
    .. "tile (got " .. tostring(facing) .. ")")
  shot("arrive")

  -- ElmsLab_WalkUpToElmMovement: nine `step UP` then `turn_head RIGHT`.
  local idle = 0
  for _ = 1, 900 do
    if w:busy() then idle = 0 else idle = idle + 1 end
    if idle > 40 then break end
    wait(3)
  end
  x, y, facing = cell()
  ok(x == 4 and y == 2 and facing == "right",
    ("the entry scene ends at (4,2) facing right, got (%d,%d) %s")
      :format(x, y, tostring(facing)))
  shot("met-elm")

  if fails > 0 then
    error(("gold warp scene: %d assertion(s) failed"):format(fails))
  end
  print("[driver] PASS gold door warp: sound, fade, and the lab entry walk")
end
