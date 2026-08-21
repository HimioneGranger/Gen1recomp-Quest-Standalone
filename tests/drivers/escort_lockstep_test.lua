-- Driver: Oak's Pallet Town escort.  Logs the player/Oak separation the
-- whole way down and shoots the walk mid-street, so the formation is
-- checkable by eye as well as by number (the escort holds one cell,
-- ~16px; a desynced Oak drifts off by a cell per two steps).
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local DIR = os.getenv("SHOT_DIR") or "/tmp/shots"
  U.teleport(game, "PALLET_TOWN", 10, 3, "up")
  local ow = game.overworld
  local function oak()
    for _, n in ipairs(ow.npcs or {}) do
      if n.def and n.def.name == "PALLETTOWN_OAK" then return n end
    end
  end
  U.hold(game, "up", 40)
  local worst, samples = 0, 0
  for _ = 1, 1200 do
    if game.stack:top() ~= ow then U.tap(game, "a") end
    local o = oak()
    if o and #ow.scriptMoves > 0 and ow.map.id == "PALLET_TOWN" then
      local d = math.abs(o.px - ow.player.px) + math.abs(o.py - ow.player.py)
      if samples > 0 or d <= 20 then
        samples = samples + 1
        if d > worst then worst = d end
        if samples == 60 then U.shot(game, DIR .. "/escort_midwalk.png") end
        if samples % 24 == 1 then
          U.log(("t=%d player=(%d,%d) oak=(%d,%d) dist=%dpx")
            :format(samples, ow.player.cellX, ow.player.cellY,
                    o.cellX, o.cellY, d))
        end
      end
    end
    if ow.map.id == "OAKS_LAB" then break end
    U.wait(2)
  end
  U.log(("ESCORT worst separation: %dpx over %d samples"):format(worst, samples))
  U.log("map:", ow.map.id, "flag:",
        tostring(game.save.flags.EVENT_FOLLOWED_OAK_INTO_LAB))
  love.event.quit()
end
