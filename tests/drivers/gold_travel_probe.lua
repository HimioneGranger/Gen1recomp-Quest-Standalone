-- Navigation probe: can the bot WALK from A to B?
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold POKEPORT_SPEED=200 \
--     POKEPORT_GOLD_RESUME=05 \
--     POKEPORT_GOLD_PROBE="CHERRYGROVE_CITY>ILEX_FOREST,VIOLET_CITY>AZALEA_TOWN" \
--     POKEPORT_DRIVER=tests/drivers/gold_travel_probe.lua love .
--
-- Every teleport the route bot logs is a map the planner could not reach, and
-- each one used to cost a ten-minute run to reproduce.  This puts the player at
-- the start map with the checkpoint's badges and HMs, asks Bot:travelTo for the
-- destination, and reports hops and frames -- so a planner change is a
-- one-minute experiment instead of a full replay.
--
-- The placement itself is A.teleport, the same harness shortcut the bot falls
-- back on; it is the SETUP here, never the measurement.  What is measured is
-- only the walk that follows.

local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter

local DEFAULT = "CHERRYGROVE_CITY>ILEX_FOREST"

return function(game)
  local bot = Bot.new(game)

  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end
  if not A.ready(game) then
    print("[probe] the world never came up")
    return
  end

  local resume = os.getenv("POKEPORT_GOLD_RESUME")
  if resume then
    local ok, err = A.loadCheckpoint(game, resume)
    if not ok then
      print(("[probe] cannot resume %s: %s"):format(resume, tostring(err)))
      return
    end
    for _ = 1, 3000 do
      if A.ready(game) then break end
      bot:wait(1)
    end
  end

  -- Single-map walk probe: "ROUTE_32@18,6>6,79" places the player and asks for
  -- one local walk.  Travel failures usually bottom out in one map's local
  -- pathfinding, and isolating that is the difference between a 60k-frame
  -- reproduction and a 400-frame one.
  local walkSpec = os.getenv("POKEPORT_GOLD_WALK")
  if walkSpec then
    for spec in walkSpec:gmatch("[^;]+") do
      local map, sx, sy, gx, gy =
        spec:match("^%s*([%w_]+)@(%-?%d+),(%-?%d+)>(%-?%d+),(%-?%d+)%s*$")
      if not map then
        print(("[probe] cannot parse walk %q"):format(spec))
      else
        if not A.teleport(game, map, tonumber(sx), tonumber(sy)) then
          print(("[probe] cannot place the player on %s"):format(map))
        else
          bot:wait(30)
          bot:clearDialogue()
          bot:progress()
          local start = bot:frames()
          local ok, res = pcall(function()
            return bot:walkTo(tonumber(gx), tonumber(gy))
          end)
          local px, py = A.pos(game)
          print(("[probe] walk %s: %s in %d frames, ended at (%s,%s) on %s")
            :format(spec, (ok and res) and "ok" or "FAIL",
                    bot:frames() - start, tostring(px), tostring(py),
                    tostring(A.mapId(game))))
          -- Who is standing where, now.  An NPC blocks a step exactly like a
          -- wall but appears nowhere in the extracted map, so a corridor that
          -- looks two cells wide on paper can be one cell wide in play -- which
          -- is the difference between "the planner is wrong" and "there is no
          -- way round".
          local map = A.map(game)
          if map and px then
            local near = {}
            for cy = math.max(0, py - 6), math.min(map.heightCells - 1, py + 6) do
              for cx = 0, map.widthCells - 1 do
                if A.npcAt(game, cx, cy) then
                  near[#near + 1] = ("(%d,%d)"):format(cx, cy)
                end
              end
            end
            print(("[probe]   npcs within 6 rows: %s")
              :format(#near > 0 and table.concat(near, " ") or "none"))
          end
          bot:progress()
        end
      end
    end
    return
  end

  local pairsSpec = os.getenv("POKEPORT_GOLD_PROBE") or DEFAULT
  local budget = tonumber(os.getenv("POKEPORT_GOLD_PROBE_BUDGET")) or 60000

  local results = {}
  for spec in pairsSpec:gmatch("[^,]+") do
    -- "A>B" or "A>B#N", where N pins which REGION of B counts as arriving.
    -- Split maps are the whole reason travelTo grew a region argument
    -- (TEAM_ROCKET_BASE_B3F), so the probe has to be able to ask for one or it
    -- cannot test the thing that matters.
    local from, to, region = spec:match("^%s*([%w_]+)%s*>%s*([%w_]+)%s*#(%d+)%s*$")
    if not from then
      from, to = spec:match("^%s*([%w_]+)%s*>%s*([%w_]+)%s*$")
    end
    region = tonumber(region)
    if not from then
      print(("[probe] cannot parse %q"):format(spec))
    else
      -- Place the player at `from` (setup, not navigation), then walk.
      local defs = bot:mapDefs()
      local def = defs[from]
      local landing = def and (def.warps or {})[1]
      local placed
      if landing then
        placed = A.teleport(game, from, landing.x, landing.y)
      else
        placed = A.teleport(game, from, 0, 0)
      end
      if not placed then
        print(("[probe] cannot place the player on %s"):format(from))
        results[#results + 1] = { spec = spec, ok = false, why = "no placement" }
      else
        bot:wait(30)
        bot:clearDialogue()
        bot:progress()
        local start = bot:frames()
        local hops = 0
        local origSay = bot.say
        -- Count hops without threading a counter through the core.
        bot.say = function(self, ...)
          local line = table.concat({ ... }, " ")
          if type((...)) == "string" and (...):match("^hop ") then
            hops = hops + 1
          end
          return origSay(self, ...)
        end
        local ok, res = pcall(function() return bot:travelTo(to, region) end)
        bot.say = origSay
        local spent = bot:frames() - start
        if not ok then
          results[#results + 1] = { spec = spec, ok = false, frames = spent,
                                    hops = hops,
                                    why = (type(res) == "table" and res.why)
                                          or tostring(res) }
        else
          results[#results + 1] = { spec = spec, ok = res, frames = spent,
                                    hops = hops,
                                    why = res and "" or "no route",
                                    landed = tostring(A.mapId(game)) }
        end
        bot:progress()
        if spent > budget then
          print("[probe] budget spent, stopping")
          break
        end
      end
    end
  end

  print("")
  print("================ travel probe ================")
  local passed = 0
  for _, r in ipairs(results) do
    if r.ok then passed = passed + 1 end
    print(("%-4s %-46s %7s frames  %2s hops  %s")
      :format(r.ok and "ok" or "FAIL", r.spec, tostring(r.frames or "-"),
              tostring(r.hops or "-"),
              r.ok and "" or ("%s (on %s)"):format(tostring(r.why),
                                                   tostring(r.landed))))
  end
  print(("%d/%d reachable by walking"):format(passed, #results))
  print("==============================================")
end
