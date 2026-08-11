-- Red Gyarados BATTLETYPE_FORCESHINY probe: the REAL script chain (the
-- RedGyarados object script at 49:4f6f -> loadwildmon GYARADOS, 30 ->
-- loadvar VAR_BATTLETYPE, BATTLETYPE_FORCESHINY -> startbattle) must hand
-- the battle a SHINY Gyarados (InitEnemyMon `.NotRoaming`, engine/battle/
-- core.asm:5876: DVs $EA/$AA) and a battle RUN cannot leave
-- (TryToRunAwayFromBattle's .cant_escape arm for the type).
local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter

return function(game)
  local bot = Bot.new(game)
  for _ = 1, 3000 do if A.ready(game) then break end bot:wait(1) end
  local ok, err = A.loadCheckpoint(game, "10")
  if not ok then
    print("[forceshiny] FAIL resume: " .. tostring(err))
    return
  end
  for _ = 1, 3000 do if A.ready(game) then break end bot:wait(1) end

  if not bot:travelTo("LAKE_OF_RAGE") then
    print("[forceshiny] FAIL travel")
    return
  end
  if not bot:approachAndFace(18, 22) then
    print("[forceshiny] FAIL approach gyarados")
    return
  end
  bot:tap("a")
  local battle
  for _ = 1, 2400 do
    if A.inBattle(game) then
      battle = A.top(game).battle
      break
    end
    bot:tap("a")
    bot:wait(2)
  end
  if not battle then
    print("[forceshiny] FAIL no battle came up")
    return
  end

  local wild = battle.enemy or {}
  local dvs = wild.dvs or {}
  print(("[forceshiny] map=%s pos=%s,%s wild=%s trainer=%s level=%s")
    :format(tostring(A.mapId(game)), tostring(select(1, A.pos(game))),
      tostring(select(2, A.pos(game))), tostring(battle.wild),
      tostring(battle.trainer and battle.trainer.name), tostring(wild.level)))
  print(("[forceshiny] battleType=%s species=%s shiny=%s dvs=%s/%s/%s/%s")
    :format(tostring(battle.battleType), tostring(wild.species),
      tostring(wild.shiny), tostring(dvs.attack), tostring(dvs.defense),
      tostring(dvs.speed), tostring(dvs.special)))

  local pass = battle.battleType == 7
    and wild.species == "GYARADOS"
    and wild.shiny == true
    and dvs.attack == 14 and dvs.defense == 10
    and dvs.speed == 10 and dvs.special == 10

  -- RUN must refuse and leave the encounter live.
  local ran = battle:tryRun()
  print(("[forceshiny] tryRun=%s over=%s")
    :format(tostring(ran), tostring(battle.over)))
  if ran or battle.over then pass = false end

  print(pass and "[forceshiny] PASS" or "[forceshiny] FAIL")
end
