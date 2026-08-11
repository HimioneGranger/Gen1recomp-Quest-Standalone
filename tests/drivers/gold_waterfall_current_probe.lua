-- Current tiles at Tohjo Falls, driven through the real game.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold POKEPORT_SPEED=200 \
--     POKEPORT_GOLD_RESUME=16 \
--     POKEPORT_DRIVER=tests/drivers/gold_waterfall_current_probe.lua love .
--
-- DoPlayerMovement's .CheckTile treats COLL_WATERFALL $33 as a CURRENT tile and
-- forces one DOWN step per frame while the player stands on one, above
-- .CheckTurning and .TryStep -- so the plunge is automatic and the column
-- cannot be climbed by pressing UP.  Tohjo Falls' west fall is four cells wide
-- and four tall ((8,8)..(11,11)), with plain water above and below it, which
-- makes it the map the three claims below are about:
--
--   * holding UP from the pool never reaches the ledge above the fall
--   * HM07's own climb (Script_UsedWaterfall) still does
--   * stepping back into the column carries the player down with no input
--
-- Prints one PASS/FAIL line per claim and quits.

local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter
local FieldMoves = require("src.world.gen2.FieldMoves")

local MAP = "TOHJO_FALLS"
local POOL_X, POOL_Y = 11, 12   -- plain water below the fall
local TOP_Y = 7                 -- the water above it

local results = {}

local function claim(ok, text)
  results[#results + 1] = ok and true or false
  print((ok and "[current] PASS " or "[current] FAIL ") .. text)
end

return function(game)
  local bot = Bot.new(game)

  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end
  local resume = os.getenv("POKEPORT_GOLD_RESUME") or "16"
  local ok, err = A.loadCheckpoint(game, resume)
  if not ok then
    print(("[current] cannot resume %s: %s"):format(resume, tostring(err)))
    love.event.quit()
    return
  end
  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end

  local world = game.world
  world:setMap(MAP, POOL_X, POOL_Y, "up")
  world:applyPlayerState(FieldMoves.PLAYER_SURF)
  world.noWildEncounters = true
  bot:wait(30)
  bot:clearDialogue(nil, 4000)
  claim(A.mapId(game) == MAP and A.surfing(game),
    "surfing in the pool below the west fall")

  local map = A.map(game)
  claim(map ~= nil and A.isWaterfall(map, POOL_X, POOL_Y - 1),
    "the cell above the player is a waterfall tile")

  -- ---- the d-pad cannot climb it ------------------------------------------
  local highest = select(2, A.pos(game))
  for _ = 1, 600 do
    A.hold(game, "up")
    bot:wait(1)
    local _, y = A.pos(game)
    if y < highest then highest = y end
  end
  A.releaseDirs(game)
  bot:wait(20)
  claim(highest > TOP_Y,
    ("holding UP for 600 frames never got above the fall (best y=%d)")
      :format(highest))

  -- ---- HM07 still does -----------------------------------------------------
  local px, py = A.pos(game)
  if py ~= POOL_Y or px ~= POOL_X then
    world:setMap(MAP, POOL_X, POOL_Y, "up")
    world:applyPlayerState(FieldMoves.PLAYER_SURF)
    bot:wait(20)
  end
  bot:face("up")
  local used = A.useWaterfall(game)
  bot:wait(8)
  bot:clearDialogue({ "yes" }, 6000)
  for _ = 1, 900 do
    if not A.moving(game) and not A.busy(game) then break end
    bot:wait(1)
  end
  local _, afterClimb = A.pos(game)
  claim(used and afterClimb <= TOP_Y,
    ("Script_UsedWaterfall still climbs the fall (y=%s)")
      :format(tostring(afterClimb)))

  -- ---- and the descent rides the current -----------------------------------
  local beforeX, beforeY = A.pos(game)
  -- Long enough to turn and take the ONE step onto the top of the fall, then
  -- the d-pad is let go: everything after this is .CheckTile's doing.
  bot:face("down")
  A.hold(game, "down")
  bot:wait(20)
  A.releaseDirs(game)
  for _ = 1, 600 do
    if not A.moving(game) then
      local _, y = A.pos(game)
      if y >= POOL_Y then break end
    end
    bot:wait(1)
  end
  local endX, endY = A.pos(game)
  claim(endY >= POOL_Y,
    ("one DOWN press carried the player the whole way down (%d,%d -> %d,%d)")
      :format(beforeX, beforeY, endX, endY))

  local failures = 0
  for _, value in ipairs(results) do
    if not value then failures = failures + 1 end
  end
  print(("[current] %d claims, %d failed"):format(#results, failures))
  love.event.quit()
end
