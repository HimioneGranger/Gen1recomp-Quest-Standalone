-- Rock-smash probe: resume a checkpoint, stand at Burned Tower 1F (4,4),
-- press A at the rock on (4,3), and report every state change -- the textbox
-- body, the stack top, and whether the rock object is still there.
--
--   POKEPORT_IDENTITY=gold-v2 POKEPORT_GAME=gold POKEPORT_SPEED=200 \
--     POKEPORT_GOLD_RESUME=07 \
--     POKEPORT_DRIVER=tests/drivers/gold_rock_probe.lua love .

local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter

return function(game)
  local bot = Bot.new(game)

  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end
  local resume = os.getenv("POKEPORT_GOLD_RESUME")
  if resume then
    local ok, err = A.loadCheckpoint(game, resume)
    if not ok then
      print(("[rock] cannot resume %s: %s"):format(resume, tostring(err)))
      return
    end
    for _ = 1, 3000 do
      if A.ready(game) then break end
      bot:wait(1)
    end
  end

  local world = game.world
  -- Skip the rival ambush: hide his object and advance the scene the way his
  -- own script would have, so the probe measures the ROCK and nothing else.
  world.events:set(1733, true)          -- EVENT_RIVAL_BURNED_TOWER
  world.mapScenes["BURNED_TOWER_1F"] = 1 -- SCENE_BURNEDTOWER1F_FIREBREATHER_DICK
  world:setMap("BURNED_TOWER_1F", 9, 15, "up")
  bot:wait(30)
  bot:clearDialogue(nil, 12000)
  print("[rock] after rival: map=" .. tostring(A.mapId(game)))
  if A.mapId(game) ~= "BURNED_TOWER_1F" then
    print("[rock] ABORT: rival fight lost / left the tower")
    love.event.quit()
    return
  end

  local function report(tag)
    local npc = A.npcAt(game, 4, 3)
    print(("[rock] %-12s map=%s pos=%s,%s rock=%s busy=%s")
      :format(tag, tostring(A.mapId(game)),
              tostring(select(1, A.pos(game))), tostring(select(2, A.pos(game))),
              tostring(npc ~= nil), tostring(A.busyReason(game))))
  end

  -- Simulate a long session: a stale hLastTalked from an earlier talk.  The
  -- cart overwrites it on every A-press dispatch; a port that does not will
  -- smash the wrong object.
  world.vm.lastTalked = 9

  report("arrived")
  local okw = bot:walkTo(4, 4)
  print("[rock] walkTo(4,4):", tostring(okw))
  report("standing")
  bot:face("up")
  for attempt = 1, 4 do
    bot:tap("a")
    bot:wait(4)
    for _ = 1, 30 do
      if A.busy(game) then break end
      bot:wait(1)
    end
    if A.busy(game) then
      print("[rock] tap " .. attempt .. " opened something")
      break
    end
    print("[rock] tap " .. attempt .. " opened nothing")
  end
  bot:clearDialogue({ "yes" }, 4000)
  report("talked")
  love.event.quit()
end
