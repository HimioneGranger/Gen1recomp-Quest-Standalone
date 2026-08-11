-- The Vermilion Snorlax's 2x2 footprint, on the real map.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold POKEPORT_SPEED=200 \
--     POKEPORT_GOLD_RESUME=18-pristine \
--     POKEPORT_DRIVER=tests/drivers/gold_snorlax_footprint_probe.lua love .
--
-- SPRITEMOVEDATA_BIGDOLLSYM's palette-flags byte is `STRENGTH_BOULDER |
-- BIG_OBJECT`, and IsNPCAtCoord hands a BIG_OBJECT's coordinate to
-- WillObjectIntersectBigObject -- which accepts anything in (x,y)..(x+1,y+1).
-- IsNPCAtCoord is what both `.CheckNPC` and CheckFacingObject ask, so the
-- sleeping Snorlax at (34,8) fills four cells for walking and for talking.
--
-- A screenshot goes to /tmp/gold-shots/ so the 32x32 draw can be looked at.

local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter
local U = dofile("tests/drivers/util.lua")

local MAP = "VERMILION_CITY"
local DOLL_X, DOLL_Y = 34, 8

local results = {}

local function claim(ok, text)
  results[#results + 1] = ok and true or false
  print((ok and "[snorlax] PASS " or "[snorlax] FAIL ") .. text)
end

return function(game)
  local bot = Bot.new(game)

  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end
  local resume = os.getenv("POKEPORT_GOLD_RESUME") or "18-pristine"
  local ok, err = A.loadCheckpoint(game, resume)
  if not ok then
    print(("[snorlax] cannot resume %s: %s"):format(resume, tostring(err)))
    love.event.quit()
    return
  end
  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end

  local world = game.world
  world.noWildEncounters = true
  world:setMap(MAP, 33, 8, "right")
  bot:wait(30)
  bot:clearDialogue(nil, 4000)
  claim(A.mapId(game) == MAP, "arrived at " .. MAP)

  local doll = world:npcAt(DOLL_X, DOLL_Y)
  claim(doll ~= nil and doll.bigObject == true,
    "the object at (34,8) is a BIG_OBJECT")

  local cells = { { 34, 8 }, { 35, 8 }, { 34, 9 }, { 35, 9 } }
  local blobOk = true
  for _, cell in ipairs(cells) do
    if world:npcAt(cell[1], cell[2]) ~= doll then blobOk = false end
  end
  claim(blobOk, "all four blob cells resolve to the same object")
  claim(world:npcAt(36, 8) == nil and world:npcAt(34, 10) == nil,
    "and the cells just outside it are clear")

  -- `.CheckNPC`: the three cells it merely overhangs refuse a step.  Each is
  -- approached from the far side so the walk is not blocked by the object's
  -- own cell.
  local walks = {
    { 35, 7, "down", "into (35,8) from above" },
    { 33, 9, "right", "into (34,9) from the left" },
    { 35, 10, "up", "into (35,9) from below" },
  }
  for _, row in ipairs(walks) do
    world:setMap(MAP, row[1], row[2], row[3])
    bot:wait(20)
    local sx, sy = A.pos(game)
    A.hold(game, row[3])
    bot:wait(40)
    A.releaseDirs(game)
    bot:wait(20)
    local ex, ey = A.pos(game)
    claim(ex == sx and ey == sy, "a step " .. row[4] .. " is refused")
  end

  -- CheckFacingObject from a cell that only touches the blob's overhang.
  world:setMap(MAP, 36, 9, "left")
  bot:wait(20)
  local talked = world:interact()
  claim(talked, "an A press from (36,9) reaches the Snorlax")
  bot:clearDialogue(nil, 6000)

  world:setMap(MAP, 33, 8, "right")
  bot:wait(40)
  U.shot(game, "/tmp/gold-shots/snorlax-footprint.png")

  local failures = 0
  for _, value in ipairs(results) do
    if not value then failures = failures + 1 end
  end
  print(("[snorlax] %d claims, %d failed"):format(#results, failures))
  love.event.quit()
end
