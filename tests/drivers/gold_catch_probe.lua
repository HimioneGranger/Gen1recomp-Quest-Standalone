-- Catch-op probe: resume a checkpoint and hunt one species.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold POKEPORT_SPEED=200 \
--     POKEPORT_GOLD_RESUME=08 \
--     POKEPORT_GOLD_CATCH="ECRUTEAK_CITY:POLIWAG,POLIWHIRL" \
--     POKEPORT_GOLD_CATCH_WATER=1 \
--     POKEPORT_DRIVER=tests/drivers/gold_catch_probe.lua love .
--
-- Used to prove a water/grass hunt without replaying the section that leads
-- up to it.  Placement is travelTo (or a teleport if POKEPORT_GOLD_CATCH_TP=1);
-- the measurement is ops.catch.

local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter

return function(game)
  local bot = Bot.new(game)

  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end
  if not A.ready(game) then
    print("[catch-probe] the world never came up")
    return
  end

  local resume = os.getenv("POKEPORT_GOLD_RESUME")
  if resume then
    local ok, err = A.loadCheckpoint(game, resume)
    if not ok then
      print(("[catch-probe] cannot resume %s: %s"):format(resume, tostring(err)))
      return
    end
    for _ = 1, 3000 do
      if A.ready(game) then break end
      bot:wait(1)
    end
  end

  local spec = os.getenv("POKEPORT_GOLD_CATCH")
  if not spec then
    print("[catch-probe] set POKEPORT_GOLD_CATCH=MAP:SPECIES[,SPECIES...]")
    return
  end
  local map, rest = spec:match("^%s*([%w_]+)%s*:%s*(.+)%s*$")
  if not map then
    print(("[catch-probe] cannot parse %q"):format(spec))
    return
  end
  local species = {}
  for id in rest:gmatch("[%w_]+") do species[#species + 1] = id end

  bot:forgetSurf()
  print(("[catch-probe] start on %s at %d,%d; surf=%s; balls=%s")
    :format(tostring(A.mapId(game)), select(1, A.pos(game)),
            select(2, A.pos(game)),
            tostring(bot:canSurf()),
            tostring(game.save and game.save.inventory
                     and game.save.inventory.POKE_BALL)))

  if os.getenv("POKEPORT_GOLD_CATCH_TP") == "1" then
    if not A.teleport(game, map, 20, 20) then
      print("[catch-probe] teleport failed")
      return
    end
    bot:wait(30)
  else
    if A.mapId(game) ~= map then
      local ok = bot:travelTo(map)
      print(("[catch-probe] travelTo %s: %s"):format(map, ok and "ok" or "FAIL"))
      if not ok then return end
    end
  end

  -- Same hunt loop as ops.catch (water filter + bot.catchWanted throws).
  print("[catch-probe] hunting " .. table.concat(species, "/"))

  local wanted = {}
  for _, id in ipairs(species) do wanted[id] = true end
  local function have()
    for _, mon in ipairs(A.party(game)) do
      if wanted[mon.species] then return mon end
    end
  end
  if have() then
    print("[catch-probe] already have one: " .. have().species)
    return
  end

  local water = os.getenv("POKEPORT_GOLD_CATCH_WATER") == "1"
  bot:forgetSurf()
  if water and not bot:canSurf() then
    print("[catch-probe] FAIL: water catch needs SURF and FOGBADGE")
    return
  end

  local ball = os.getenv("POKEPORT_GOLD_CATCH_BALL") or "POKE_BALL"
  bot.catchWanted, bot.catchBall = wanted, ball
  local start = bot:frames()
  local caught = nil
  for pass = 1, 300 do
    caught = have()
    if caught then break end
    if not A.hasItem(game, ball) then
      print("[catch-probe] FAIL: out of " .. ball)
      break
    end
    if A.busy(game) then bot:clearDialogue({ "no", "no" }, 2000) end
    if A.mapId(game) ~= map then
      if not bot:travelTo(map) then
        print("[catch-probe] FAIL: left map and could not return")
        break
      end
    end
    local m = A.map(game)
    if not m then break end
    local spots = {}
    for cy = 0, m.heightCells - 1 do
      for cx = 0, m.widthCells - 1 do
        if A.isEncounterCell(m, cx, cy)
            and (not water or A.isWater(m, cx, cy)) then
          spots[#spots + 1] = { cx, cy }
        end
      end
    end
    if pass == 1 then
      print(("[catch-probe] %d encounter spots (water=%s)")
        :format(#spots, tostring(water)))
    end
    if #spots == 0 then
      print("[catch-probe] FAIL: no encounter spots")
      break
    end
    for _ = 1, 8 do
      local pick = spots[math.random(1, #spots)]
      if bot:planPath(pick[1], pick[2]) then
        bot:walkTo(pick[1], pick[2], { attempts = 3 })
        break
      end
    end
    if pass % 20 == 0 then
      local left = (game.save and game.save.inventory
                    and game.save.inventory[ball]) or 0
      print(("[catch-probe] still hunting pass=%d balls=%d party=%d")
        :format(pass, left, A.partySize(game)))
    end
  end
  bot.catchWanted, bot.catchBall = nil, nil
  if A.busy(game) then bot:clearDialogue({ "no", "no" }, 2000) end

  caught = have()
  if caught then
    print(("[catch-probe] OK: caught %s in %d frames")
      :format(caught.species, bot:frames() - start))
    -- Prove the HM lists that motivated the catch.
    local def = game.data and game.data.pokemon and game.data.pokemon[caught.species]
    local haveHm = {}
    for _, id in ipairs((def and def.tmhm) or {}) do
      if id == "WHIRLPOOL" or id == "WATERFALL" or id == "SURF"
          or id == "STRENGTH" or id == "FLY" then
        haveHm[#haveHm + 1] = id
      end
    end
    print(("[catch-probe]   tmhm of interest: %s")
      :format(#haveHm > 0 and table.concat(haveHm, ", ") or "(none)"))
  else
    print(("[catch-probe] FAIL: did not catch in %d frames")
      :format(bot:frames() - start))
  end
end
