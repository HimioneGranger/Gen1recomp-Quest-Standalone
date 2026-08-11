-- HM07 ball probe: resume section 13, enter Ice Path 1F, run the exact
-- approach the route row 13.10 makes (approachAndFace the ball at (31,7)),
-- and report every state change on the way.
--
--   POKEPORT_IDENTITY=gold-v2b POKEPORT_GAME=gold POKEPORT_SPEED=200 \
--     POKEPORT_GOLD_RESUME=13 \
--     POKEPORT_DRIVER=tests/drivers/gold_hm07_probe.lua love .

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
      print(("[hm07] cannot resume %s: %s"):format(resume, tostring(err)))
      return
    end
    for _ = 1, 3000 do
      if A.ready(game) then break end
      bot:wait(1)
    end
  end

  local world = game.world
  world:setMap("ICE_PATH_1F", 4, 19, "up")
  bot:wait(30)
  bot:clearDialogue(nil, 4000)

  local function report(tag)
    local px, py = A.pos(game)
    print(("[hm07] %-10s map=%s pos=%s,%s ball=%s flag=%s busy=%s")
      :format(tag, tostring(A.mapId(game)), tostring(px), tostring(py),
              tostring(A.npcAt(game, 31, 7) ~= nil),
              tostring(world.events:get(1672)),
              tostring(A.busyReason(game))))
  end

  report("arrived")
  local reached = bot:approachAndFace(31, 7)
  print("[hm07] approachAndFace(31,7):", tostring(reached))
  report("approached")
  if reached then
    for attempt = 1, 4 do
      bot:tap("a")
      bot:wait(4)
      for _ = 1, 30 do
        if A.busy(game) then break end
        bot:wait(1)
      end
      if A.busy(game) then
        print("[hm07] tap " .. attempt .. " opened something")
        break
      end
      print("[hm07] tap " .. attempt .. " opened nothing")
    end
    bot:clearDialogue(nil, 4000)
  end
  report("done")

  -- Engine introspection: is the press being lost, or is interact refusing?
  local p = world.player
  print(("[hm07] engine: busy=%s moving=%s facing=%s turnLatch=%s")
    :format(tostring(world:busy()), tostring(p and p.moving),
            tostring(p and p.facing), tostring(world.turningDirection)))
  local npc = world:npcAt(31, 7)
  print(("[hm07] engine npcAt(31,7): %s def.itemball=%s")
    :format(tostring(npc ~= nil),
            tostring(npc and npc.def and npc.def.itemball
                     and npc.def.itemball.item)))
  local r = world:interact()
  print("[hm07] direct world:interact():", tostring(r))
  bot:wait(60)
  bot:clearDialogue({ "yes" }, 3000)
  report("direct")
  love.event.quit()
end
