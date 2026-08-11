-- Lake of Rage chain probe: resume section 10, travel, fight the Red Gyarados,
-- talk to Lance, enter the mart, and print the three Cluster C flags.
local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter

local function flag(game, name)
  local v = A.event(game, name)
  return v == nil and "?" or (v and "SET" or "clear")
end

return function(game)
  local bot = Bot.new(game)
  for _ = 1, 3000 do if A.ready(game) then break end bot:wait(1) end
  local ok, err = A.loadCheckpoint(game, "10")
  if not ok then
    print("[lake] resume fail " .. tostring(err))
    return
  end
  for _ = 1, 3000 do if A.ready(game) then break end bot:wait(1) end

  bot:forgetSurf()
  print(("[lake] start %s surf=%s gyarados=%s lance=%s stairs=%s")
    :format(tostring(A.mapId(game)), tostring(bot:canSurf()),
            flag(game, "EVENT_LAKE_OF_RAGE_RED_GYARADOS"),
            flag(game, "EVENT_DECIDED_TO_HELP_LANCE"),
            flag(game, "EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART")))

  -- Burn a visit to the lake and back so edgeTries matches a real section-10
  -- approach (10.26 then 10.g), which is what exposed the skip=1 pocket bug.
  print("[lake] priming edgeTries via lake <-> route 43...")
  bot:travelTo("LAKE_OF_RAGE")
  bot:travelTo("ROUTE_43")

  print("[lake] travelTo LAKE_OF_RAGE for the fight...")
  if not bot:travelTo("LAKE_OF_RAGE") then
    print("[lake] FAIL travel")
    return
  end
  local nx, ny = A.pos(game)
  print(("[lake] arrived %s @%d,%d regionSize=%d")
    :format(tostring(A.mapId(game)), nx or -1, ny or -1, bot:regionSize()))

  print("[lake] approach+A Red Gyarados at 18,22...")
  if not bot:approachAndFace(18, 22) then
    print("[lake] FAIL approach gyarados")
    return
  end
  local ax, ay = A.pos(game)
  print(("[lake] standing @%d,%d facing=%s -- pressing A")
    :format(ax or -1, ay or -1, tostring(A.facing(game))))
  bot:tap("a")
  bot:wait(8)
  bot:clearDialogue(nil, 12000)
  print(("[lake] after gyarados: gyarados=%s lanceObj=%s")
    :format(flag(game, "EVENT_LAKE_OF_RAGE_RED_GYARADOS"),
            flag(game, "EVENT_LAKE_OF_RAGE_LANCE")))

  if flag(game, "EVENT_LAKE_OF_RAGE_RED_GYARADOS") ~= "SET" then
    print("[lake] FAIL: EVENT_LAKE_OF_RAGE_RED_GYARADOS still clear")
    return
  end

  print("[lake] talk Lance at 21,28...")
  if not bot:approachAndFace(21, 28) then
    print("[lake] FAIL approach lance")
    return
  end
  bot:tap("a")
  bot:wait(8)
  bot:clearDialogue({ "yes" }, 8000)
  print(("[lake] after lance: decided=%s")
    :format(flag(game, "EVENT_DECIDED_TO_HELP_LANCE")))

  if flag(game, "EVENT_DECIDED_TO_HELP_LANCE") ~= "SET" then
    print("[lake] FAIL: EVENT_DECIDED_TO_HELP_LANCE still clear")
    return
  end

  print("[lake] travelTo MAHOGANY_MART_1F...")
  if not bot:travelTo("MAHOGANY_MART_1F") then
    print("[lake] FAIL travel mart")
    return
  end
  -- Scene script runs on entry.
  bot:clearDialogue(nil, 8000)
  print(("[lake] after mart: stairs=%s map=%s")
    :format(flag(game, "EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART"),
            tostring(A.mapId(game))))

  if flag(game, "EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART") == "SET"
      and flag(game, "EVENT_DECIDED_TO_HELP_LANCE") == "SET"
      and flag(game, "EVENT_LAKE_OF_RAGE_RED_GYARADOS") == "SET" then
    print("[lake] OK: Cluster C chain complete")
  else
    print("[lake] FAIL: chain incomplete")
  end
end
