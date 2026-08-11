-- Gold route bot: New Bark Town to the Olivine Gym.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold POKEPORT_SPEED=200 \
--     POKEPORT_DRIVER=tests/drivers/gold_bot.lua love .
--
-- Interprets tests/drivers/gold/route.lua (objectives derived from
-- docs/gold-walkthrough/asm-walk) using the core in tests/drivers/gold/bot.lua.
-- Validate the route first -- `luajit tests/gold_route_validate_test.lua` --
-- because every coordinate error it catches costs an hour of run time here.
--
-- An unimplemented or failing op does NOT abort the run.  It is logged, added
-- to the skip list and stepped over, so one run tells you every wall rather
-- than only the first: a stall names the asm-walk row it stalled on, which is a
-- paste-ready issue instead of a mystery.  The summary at the end is the point
-- of the whole exercise.
--
-- Env:
--   POKEPORT_GOLD_LOG=path       mirror the log to a file, flushed per line
--   POKEPORT_GOLD_FROM=id        skip route rows until this id (resume)
--   POKEPORT_GOLD_UNTIL=id       stop after this id
--   POKEPORT_GOLD_STALL=frames   silent-stall budget (default 5000)
--   POKEPORT_GOLD_REPEATS=n      identical-log-line budget (default 12)

local Bot = dofile("tests/drivers/gold/bot.lua")
local ROUTE = dofile("tests/drivers/gold/route.lua")
local A = Bot.adapter

return function(game)
  local bot = Bot.new(game)

  -- ---------------------------------------------------------------------
  -- postconditions
  -- ---------------------------------------------------------------------
  -- Every asm-walk checklist row ends in a flag, which is the oracle the Gen 1
  -- bot never had: it inferred success from position and could not tell "the
  -- script ran" from "we happen to be standing in the right place".
  local function flagSet(name)
    if not name then return true end
    local ev = A.event(game, name)
    if ev ~= nil then return ev end
    local en = A.engine(game, name)
    if en ~= nil then return en end
    return nil                       -- unknown name: the validator should have
                                     -- caught it, so treat as inconclusive
  end

  local function satisfied(row)
    if not row.expect then return true end
    local set = flagSet(row.expect)
    if set == nil then
      bot:say(("  ? %s: cannot evaluate %s"):format(row.id, row.expect))
      return true
    end
    return set
  end

  -- ---------------------------------------------------------------------
  -- ops
  -- ---------------------------------------------------------------------

  local ops = {}

  function ops.travel(row)
    -- `region` pins WHICH half of a split map counts as arriving; see
    -- Bot:travelTo.
    return bot:reachMap(row.map, row.region)
  end

  function ops.settle(row)
    -- Sit through whatever the map load started.  Not a no-op: several beats
    -- (MeetMomScript, Mr Pokemon, the Burned Tower rival) are scene scripts
    -- that fire on arrival with nothing to walk into.
    bot:clearDialogue(row.answers, row.budget or 4000)
    return true
  end

  function ops.walk(row)
    return bot:walkTo(row.x, row.y, { answers = row.answers })
  end

  function ops.warp(row)
    -- Retry across wild-encounter interruptions.  A warp whose cell is a long
    -- walk over grass (Route 30's Mr Pokemon's house is 60 steps) can have its
    -- walk broken by encounter after encounter -- and worse, a mis-stepped
    -- re-plan can walk the bot clean OFF the map (Route 30's south edge drops
    -- into Cherrygrove), after which every enterWarp aims at (x,y) on the wrong
    -- map and "the warp did not take" forever.  So re-reach the row's own map
    -- before each attempt, then walk the warp; the bot is closer each pass.
    for _ = 1, 3 do
      if row.to and A.mapId(game) == row.to then return true end
      if A.mapId(game) ~= row.map then
        if A.busy(game) then bot:clearDialogue() end
        local ok, res = pcall(bot.reachMap, bot, row.map)
        if not (ok and res) then
          if not ok and not (type(res) == "table" and res.botStall) then
            error(res, 0)
          end
        end
      end
      if bot:enterWarp(row.x, row.y, row.to) then return true end
      if A.busy(game) then bot:clearDialogue() end
    end
    return A.mapId(game) == (row.to or A.mapId(game))
  end

  function ops.edge(row)
    -- Route rows write the compass word the asm-walk uses ("walk west"); the
    -- pad wants a screen direction.
    local dir = bot.button(row.dir)
    if not dir then return false, "unknown direction " .. tostring(row.dir) end
    return bot:crossEdge(dir, row.to)
  end

  -- A talk/battle row names the OBJECT'S HOME cell out of the map data, but a
  -- sighted trainer WALKS to the player and then stands wherever the fight
  -- happened -- so the named cell can be empty while the npc is two cells
  -- away.  Aim at the npc's LIVE position when one homed at (x, y) exists;
  -- bg-event targets (doors, switches, signs) have no npc and keep the row's
  -- own coordinates.
  local function liveTarget(x, y)
    local npc = A.npcHome(game, x, y)
    if npc and npc.cellX then return npc.cellX, npc.cellY end
    return x, y
  end

  function ops.talk(row)
    -- Retry with a reposition between attempts.  A single approach failing is
    -- usually not "unreachable" but "an NPC is standing in the one doorway" or
    -- "we came in by the far entrance and the local search gave up" -- and
    -- failing the row outright then let the bot wander off the map entirely,
    -- which is how the Farfetch'd herd died on its very first talk.
    local tx, ty = liveTarget(row.x, row.y)
    local reached = bot:approachAndFace(tx, ty, row.facings)
    for _ = 1, 3 do
      if reached then break end
      -- Wait, do not wander.  The first version of this retry walked to a
      -- random cell, which on a map whose exits sit in the open (Ilex Forest's
      -- do) means stepping onto a warp and leaving -- after which every
      -- remaining row reported "could not reach ILEX_FOREST".  Standing still
      -- solves the actual cause anyway: the usual reason an approach fails is
      -- an NPC parked in the one free cell, and NPCs walk away.
      bot:wait(40)
      if A.busy(game) then bot:clearDialogue() end
      if A.mapId(game) ~= row.map then break end
      tx, ty = liveTarget(row.x, row.y)
      reached = bot:approachAndFace(tx, ty, row.facings)
    end
    if not reached then return false end
    -- Press until SOMETHING opens.  One tap into the void is how the Burned
    -- Tower rock survived 07.20: a wild fight on the approach ends a few
    -- frames before the press, the post-battle teardown swallows it, and the
    -- row then reports ok off its own opinion with the rock still standing.
    -- Anything a talk row aims at answers with a textbox, so silence after
    -- the press always means the press was lost.
    local opened = false
    for attempt = 1, 4 do
      bot:tap("a")
      bot:wait(4)
      for _ = 1, 30 do
        if A.busy(game) then break end
        bot:wait(1)
      end
      if A.busy(game) then
        opened = true
        break
      end
      bot:say(("  talk: press %d at (%d,%d) opened nothing")
        :format(attempt, tx, ty))
    end
    if not opened then
      bot:say("  talk: every press was swallowed")
    end
    bot:clearDialogue(row.answers, row.budget)
    return true
  end

  -- Ride an elevator.  The panel bg event at (x, y) opens the scrolling floor
  -- menu (engine/events/elevator.asm); picking a row does NOT warp -- it
  -- rewrites the door warp's destination (Elevator_GoToFloor -> wBackup*) and
  -- the ride happens when the player walks out through the door at
  -- (doorX, doorY).  The map graph cannot express any of that, which is why
  -- the Goldenrod dept store basement -- the only road out of the Rocket
  -- warehouse -- needs an explicit row instead of a travel.
  function ops.elevator(row)
    if A.mapId(game) ~= row.map then return false, "not on the elevator" end
    if not bot:approachAndFace(row.x, row.y, row.facings) then
      return false, "could not reach the panel"
    end
    bot:tap("a")
    local menu
    for _ = 1, 300 do
      menu = A.elevatorMenu(game)
      if menu then break end
      bot:wait(1)
    end
    if not menu then return false, "elevator menu never opened" end
    local want
    for i = 1, #menu.floors do
      if A.elevatorFloorName(menu, i) == row.floor then want = i break end
    end
    if not want then
      return false, ("no floor %s on this elevator"):format(tostring(row.floor))
    end
    for _ = 1, 32 do
      if menu.index == want then break end
      bot:tap(menu.index > want and "up" or "down")
      bot:wait(4)
    end
    if menu.index ~= want then return false, "cursor never reached the floor" end
    bot:tap("a")
    bot:wait(8)
    -- Door-close SFX and script; the menu is gone, so this only clears chrome.
    bot:clearDialogue(nil, 2000)
    if not bot:enterWarp(row.doorX, row.doorY, row.to) then
      return false, "the door did not take"
    end
    return A.mapId(game) == row.to
  end

  function ops.battle(row)
    if row.talk then
      local tx, ty = liveTarget(row.x, row.y)
      if not bot:approachAndFace(tx, ty, row.facings) then return false end
      bot:tap("a")
    elseif row.x then
      -- A sight-line fight: walking onto the cell is what trips it.
      bot:walkTo(row.x, row.y, { answers = row.answers })
    end
    bot:wait(8)
    -- The approach itself is a script (the trainer walks over), so the battle
    -- may be several hundred frames away.
    bot:clearDialogue(row.answers, row.budget or 8000)
    return true
  end

  -- The asm-walk phrases healing as a town-level beat ("heal at the
  -- Pokecenter, warp 1 at (13,21)"), so a heal row names the CITY while the
  -- nurse stands a warp away inside it.  healUp finds the nearest map that
  -- actually has a nurse, so no row needs to carry the interior map name.
  function ops.heal(row)
    return bot:healUp()
  end

  function ops.grind(row)
    -- Walk back and forth in whatever grass is reachable until the party's
    -- lowest level reaches the target.  Crude, and deliberately so: the point
    -- is not to be fast, it is to not walk into Falkner at level 5.
    --
    -- Blacking out mid-grind is expected at these levels and is survivable: the
    -- engine heals the party and warps to the spawn point.  So walk back and
    -- carry on, but cap the number of round trips -- a route step that can
    -- never be met should end the op with a report, not keep the run alive
    -- forever making no progress.
    local target = row.level
    local grindMap = row.map
    local wipes = 0

    -- Grinding the party minimum means grinding the mon that is NOT fighting.
    -- Experience in Gen 2 goes to whoever was sent out, and the bot always
    -- leads with slot 1, so a party-minimum target on the default order is a
    -- number that can never be reached: the SLOWPOKE caught for SURF sat at
    -- level 7 behind a level-30 starter for the whole run.  Putting the weakest
    -- mon in front is what the PARTY menu's own SWITCH row does, and the order
    -- is put back afterwards so the rest of the route still leads with the
    -- fighter.
    --
    -- Whoever is lowest RIGHT NOW goes in front, re-checked every pass.
    --
    -- This used to choose once, before the loop, and a party-minimum target
    -- then could not be met with two weak mons in it: run 24 trained the
    -- SLOWPOKE from 5 to 10 while the TOGEPI sat at 5 behind it, so `minLevel`
    -- never moved and the row died on its futility ceiling at "level 5/20".
    -- Re-picking rotates them, which is what a player switching at the PARTY
    -- menu does anyway.
    --
    -- The original order is snapshotted whole rather than tracked as a single
    -- swap index, because after a few rotations there is no single swap to undo
    -- -- and the rest of the route needs slot 1 to be the fighter again.
    local originalOrder
    if row.lead == false then
      originalOrder = {}
      for i, mon in ipairs(A.party(game)) do originalOrder[i] = mon end
    end
    local function leadWithWeakest()
      if not originalOrder then return end
      local party = A.party(game)
      local weakest
      for i, mon in ipairs(party) do
        if not mon.isEgg and (mon.hp or 0) > 0
            and (not weakest or (mon.level or 0)
                 < (party[weakest].level or 0)) then
          weakest = i
        end
      end
      if weakest and weakest > 1 then
        party[1], party[weakest] = party[weakest], party[1]
        bot:say(("  grind: leading with %s (level %d) so it earns the levels")
          :format(tostring(party[1].species), party[1].level or 0))
      end
    end
    leadWithWeakest()
    -- Grinding the party minimum means the mon in front cannot win a fight, so
    -- the bot switches the fighter in on turn one and lets the weakling collect
    -- its participation share.  See A.openBattleParty.
    bot.switchTrain = (row.lead == false) or nil
    local function finish(ok, why)
      bot.switchTrain = nil
      if originalOrder then
        local party = A.party(game)
        for i, mon in ipairs(originalOrder) do party[i] = mon end
      end
      return ok, why
    end
    -- `lead = true` grinds the front mon only; the default is the party
    -- minimum, which is what the opening Route 29 row wants.
    local levelOf = row.lead and A.leadLevel or A.minLevel
    -- A frame ceiling as well as a pass ceiling.  A grind re-travels to its map
    -- after every wipe, and if that journey is the one that loops -- Radio
    -- Tower 2F, where an NPC stands in the only corridor -- the pass counter
    -- never advances and the row eats the entire run's wall clock.  Run 14 died
    -- this way at row 208 with the League untouched.
    local grindStart = bot:frames()
    local grindBudget = tonumber(os.getenv("POKEPORT_GOLD_GRIND_BUDGET"))
      or 700000
    -- Futility ceiling, separate from the frame budget.
    --
    -- Keyed on EXPERIENCE, not level, because those are two different
    -- questions. A grind can be earning steadily and still not cross a level
    -- for a long time -- ROUTE_34's wilds against a level-28 QUILAVA are worth
    -- very little each -- and killing that grind loses levels the route is
    -- counting on. What is worth killing is a grind earning *nothing at all*:
    -- run 24's TOGEPI fainted before it could act every single battle, and a
    -- fainted participant is awarded nothing, so "level 5/20" was unreachable
    -- by construction and the 700k frame budget was going to spend forty
    -- minutes proving it.
    --
    -- Summed over the whole party, so it stays true for the party-minimum form
    -- where the mon in front changes from pass to pass.
    local function partyExp()
      local total = 0
      for _, mon in ipairs(A.party(game)) do
        if not mon.isEgg then total = total + (mon.experience or 0) end
      end
      return total
    end
    local stuckExp, stuckSince = partyExp(), 0
    -- Pass ceiling.  Raised from 900 after Cluster E: a lead one level short of
    -- target (09.g at 37/38, 07.g similarly) was still earning every pass, so
    -- the futility guard never fired, the frame budget was still hundreds of
    -- thousands away, and the loop fell off the end with no `why` -- which the
    -- runner printed as the opaque "action reported failure".  Grass pacing
    -- (below) is what actually makes the levels land; the higher ceiling is
    -- the backstop that still names the cause when they do not.
    local passBudget = tonumber(os.getenv("POKEPORT_GOLD_GRIND_PASSES")) or 2000
    local function returnToGrind(why)
      bot:forgetSurf()
      bot.borders = {}
      if A.busy(game) then bot:clearDialogue() end
      if bot:travelTo(grindMap) then return true end
      -- One retry.  The failed trip leaves priced exits and a half-finished
      -- position; standing still clears NPC timing, and a second plan is what
      -- gets the bot out of the Route-36 National-Park-gate loop that killed
      -- every 05.g recovery before the whiteout-spawn fix.
      bot:say(("  grind: %s, retrying travel"):format(why))
      bot:wait(30)
      if A.busy(game) then bot:clearDialogue() end
      return bot:travelTo(grindMap)
    end
    for pass = 1, passBudget do
      if levelOf(game) >= target then return finish(true) end
      local exp = partyExp()
      if exp > stuckExp then
        stuckExp, stuckSince = exp, pass
      elseif pass - stuckSince > 120 then
        return finish(false, ("no experience earned in %d passes (level %d/%d)"
          .. " -- nothing here can be beaten"):format(
          pass - stuckSince, levelOf(game), target))
      end
      if bot:frames() - grindStart > grindBudget then
        return finish(false, ("gave up after %d frames (level %d/%d)")
          :format(bot:frames() - grindStart, levelOf(game), target))
      end
      if A.busy(game) then bot:clearDialogue() end
      -- Rotate: the mon that was lowest last pass may not be lowest now.
      leadWithWeakest()

      -- Heal before the party is dry.  A wipe is a free heal on the cart, but
      -- the walk home is what ended 05.g (and used to return to Cherrygrove for
      -- the whole game).  Attacking PP is the signal that matters: LEER /
      -- SMOKESCREEN keep total PP looking fine while EMBER is empty, and the
      -- fighter then STRUGGLES itself into a whiteout.
      if A.damagingPpFraction(game) < 0.2 or A.leadHpFraction(game) < 0.25 then
        bot:say(("  grind: healing mid-session (hp %.2f attacking-pp %.2f)")
          :format(A.leadHpFraction(game), A.damagingPpFraction(game)))
        if not bot:healUp() then
          return finish(false, "could not heal mid-grind")
        end
        if A.mapId(game) ~= grindMap and not returnToGrind("post-heal") then
          return finish(false, "could not get back to " .. grindMap
            .. " after mid-grind heal")
        end
      end

      if A.mapId(game) ~= grindMap then
        wipes = wipes + 1
        if wipes > (row.wipeBudget or 4) then
          return finish(false, ("blacked out %d times grinding %s (level %d/%d)")
            :format(wipes, grindMap, levelOf(game), target))
        end
        bot:say(("  grind: back to %s after a wipe (%d)"):format(grindMap, wipes))
        if not returnToGrind("wipe recovery") then
          return finish(false, "could not get back to " .. grindMap)
        end
      end

      local map = A.map(game)
      if not map then
        return finish(false, "no map loaded while grinding " .. grindMap)
      end
      -- Pace encounter tiles, not random corridor.  The catch op already learned
      -- this: wandering the whole map mostly walks road, burns frames without
      -- rolls, and steps onto connection edges that the wipe counter then
      -- treats as blackouts.
      --
      -- Cave / dungeon maps skip the grass array entirely
      -- (FieldMoves.canEncounterWildMon): every non-ice walkable tile rolls, so
      -- VICTORY_ROAD reports zero `isEncounterCell` hits and still has a full
      -- wild table.  Treat those floors the same way the engine does.
      local walked = false
      local spots = {}
      local env = map.def and map.def.environment
      local caveFloor = (env == "CAVE" or env == "DUNGEON")
      for cy = 0, map.heightCells - 1 do
        for cx = 0, map.widthCells - 1 do
          local hit
          if caveFloor then
            hit = A.walkable(game, map, cx, cy) and not A.isIce(map, cx, cy)
          else
            -- Water is in CheckGrassCollision's array; a grind paces LAND
            -- grass, and aiming at a pond bounces off the shore (or surfs
            -- off the grind entirely once the party can).
            hit = A.isEncounterCell(map, cx, cy)
              and not A.isWater(map, cx, cy)
          end
          if hit then spots[#spots + 1] = { cx, cy } end
        end
      end
      if #spots > 0 then
        for _ = 1, 12 do
          local pick = spots[math.random(1, #spots)]
          if bot:planPath(pick[1], pick[2]) then
            bot:walkTo(pick[1], pick[2], { attempts = 3 })
            walked = true
            break
          end
        end
      end
      if not walked then
        for _ = 1, 10 do
          local x = math.random(0, math.max(0, map.widthCells - 1))
          local y = math.random(0, math.max(0, map.heightCells - 1))
          if bot:planPath(x, y) then
            bot:walkTo(x, y, { attempts = 3 })
            break
          end
        end
      end
      if pass % 20 == 0 then
        bot:say(("  grind: level %d/%d on %s")
          :format(levelOf(game), target, tostring(A.mapId(game))))
      end
    end
    return finish(false, ("gave up after %d passes (level %d/%d)")
      :format(passBudget, levelOf(game), target))
  end

  -- Teach an HM move to a party mon that can legally learn it.
  --
  -- Driven through the model rather than the four screens the player would
  -- walk (PACK -> the HM -> the party list -> confirm).  That is a deliberate
  -- driver shortcut of the same kind tests/drivers/gold_walk_smoke.lua takes
  -- when it calls world:setMap: the subject under test is the ROUTE, and menu
  -- navigation is neither what a route row means nor what it is checking.
  -- Compatibility is still honoured -- the mon must have the move in its
  -- tmhm list -- so this cannot teach SURF to something that could never
  -- learn it and quietly invalidate the run.
  function ops.teach(row)
    local Mon = require("src.battle.gen2.Mon")
    local move = row.move
    local pokemon = game.data and game.data.pokemon
    for _, mon in ipairs(A.party(game)) do
      for _, known in ipairs(mon.moves or {}) do
        if known.id == move then
          bot:say(("  teach: %s already knows %s"):format(
            tostring(mon.species), move))
          return true
        end
      end
    end
    -- Slot 1 LAST.
    --
    -- This used to walk the party in order, so every HM went to whoever was in
    -- front -- which is always the starter, because the bot always leads with
    -- the fighter.  By the League the lead's four slots were CUT, STRENGTH and
    -- a level-10 EMBER, and a level-73 Typhlosion was swinging a Normal HM at
    -- Bruno.  HMs belong on the mule; the mon that has to win fights keeps its
    -- attacking moves.  The lead is still the fallback, because a route that
    -- cannot teach CUT cannot leave Ilex Forest.
    local order = {}
    local party = A.party(game)
    for i = 2, #party do order[#order + 1] = party[i] end
    if party[1] then order[#order + 1] = party[1] end

    for _, mon in ipairs(order) do
      local def = pokemon and pokemon[mon.species]
      local compatible = false
      for _, id in ipairs((def and def.tmhm) or {}) do
        if id == move then compatible = true break end
      end
      if compatible and not mon.isEgg then
        local ok, reason, entry = Mon.learnMove(mon, move, game.data)
        if ok then
          bot:say(("  teach: %s learned %s"):format(tostring(mon.species), move))
          return true
        end
        if reason == "full" and entry then
          -- No forget screen exists in the port yet, so replace the weakest
          -- move rather than stall: a bot that cannot teach CUT cannot leave
          -- Ilex Forest at all.
          --
          -- Never an HM move, though -- the cart flatly refuses to overwrite
          -- one, and the run needs them simultaneously: the mule carries SURF,
          -- WHIRLPOOL and WATERFALL together for Route 27, and this exact
          -- line once paid WHIRLPOOL for WATERFALL and re-walled Tohjo Falls.
          local HM_MOVES = { CUT = true, FLY = true, SURF = true,
                             STRENGTH = true, FLASH = true,
                             WHIRLPOOL = true, WATERFALL = true }
          local defs = game.data.moves
          local worst, worstPower
          for i, known in ipairs(mon.moves) do
            if not HM_MOVES[known.id] then
              local power = (defs and defs[known.id] and defs[known.id].power) or 0
              if not worst or power < worstPower then
                worst, worstPower = i, power
              end
            end
          end
          if worst then
            bot:say(("  teach: %s forgets %s for %s"):format(
              tostring(mon.species), tostring(mon.moves[worst].id), move))
            mon.moves[worst] = entry
            return true
          end
          -- All four slots are HMs: this mon is out of room, try the next.
          bot:say(("  teach: %s has no forgettable slot for %s"):format(
            tostring(mon.species), move))
        end
      end
    end
    return nil, ("no party mon can learn %s"):format(tostring(move))
  end

  -- Use a field move against a cell (CUT a tree, ROCK_SMASH a boulder, SURF
  -- off a beach).  Face the target first: World:fieldContext reads the tile the
  -- player is facing, so the facing IS the argument.
  function ops.field(row)
    local move = row.move
    local world = A.world(game)
    if not world then return false end
    -- Bot:stepDir launches SURF on its own whenever a planned step enters
    -- water, so by the time an explicit SURF row runs the player is often
    -- already afloat -- and useFieldMove then refuses with "You're already
    -- SURFING."  Already surfing IS this row's postcondition.
    if move == "SURF" and A.surfing(game) then
      bot:say("  field: already surfing")
      return true
    end
    local user = world:partyMoveUser(move)
    if not user then
      return nil, ("no party mon knows %s"):format(tostring(move))
    end
    if not bot:approachAndFace(row.x, row.y) then
      return false, ("could not face (%d,%d)"):format(row.x, row.y)
    end
    local result = world:useFieldMove(move, user)
    if not (result and result.ok) then
      return false, ("%s refused here (%s)"):format(move,
        tostring(result and result.text))
    end
    -- The move runs as a queued script on the next frame the world owns.
    bot:wait(8)
    bot:clearDialogue({ "yes" }, 3000)
    return true
  end

  -- Buy from a Mart.
  --
  -- Driven through the save rather than the four screens a player walks, the
  -- same shortcut ops.teach and A.throwBall take, and honest for the same
  -- reason: the money is checked and spent at the item's own price, so this can
  -- only buy what the player could have bought standing at the counter.
  --
  -- It exists because of one hard dependency.  The Cyndaquil line cannot learn
  -- SURF, so the route catches a SLOWPOKE for it -- and Elm's aide hands over
  -- exactly five POKE BALLs in the whole game to that point.  Five throws at a
  -- wild SLOWPOKE is a coin flip, and losing it costs SURF, which costs
  -- Cianwood, the Storm Badge and every section after.
  function ops.buy(row)
    local save = game.save
    local defs = game.data and game.data.items
    local id = row.item
    local want = row.count or 1
    if not (save and defs and defs[id]) then
      return nil, "unknown item " .. tostring(id)
    end
    local price = defs[id].price or 0
    save.inventory = save.inventory or {}
    local bought = 0
    for _ = 1, want do
      if (save.player.money or 0) < price then break end
      save.player.money = save.player.money - price
      save.inventory[id] = (save.inventory[id] or 0) + 1
      bought = bought + 1
    end
    bot:say(("  buy: %d x %s for %d, %d left")
      :format(bought, id, bought * price, save.player.money or 0))
    return bought > 0
  end

  -- Shove a STRENGTH boulder.
  --
  -- Two separate things, and conflating them is why the route carried this as
  -- a `manual` row.  STRENGTH must first be turned ON for this map load
  -- (World:runStrength sets strengthActive, and ResetBikeFlags clears it on
  -- every map change), which is a field move used against the boulder.  Only
  -- then does walking INTO the boulder push it, one cell per step, the way
  -- MovementFunction_Strength does on the cart.
  --
  -- `count` is how many cells to shove it; `dir` the direction to shove.  The
  -- bot stands on the far side and walks forward, so the cell it must reach is
  -- one step BEHIND the boulder.
  function ops.push(row)
    local world = A.world(game)
    if not world then return false end
    local move = "STRENGTH"
    local user = world:partyMoveUser(move)
    if not user then return nil, "no party mon knows STRENGTH" end

    local d = ({ up = { 0, -1 }, down = { 0, 1 },
                 left = { -1, 0 }, right = { 1, 0 } })[bot.button(row.dir)]
    if not d then return false, "unknown push direction " .. tostring(row.dir) end
    -- Stand on the opposite side, facing the boulder.
    local standX, standY = row.x - d[1], row.y - d[2]
    if not bot:walkTo(standX, standY) then
      return false, ("could not stand at (%d,%d) to push"):format(standX, standY)
    end
    bot:face(bot.button(row.dir))

    if not world.strengthActive then
      local result = world:useFieldMove(move, user)
      if not (result and result.ok) then
        -- "BOULDERS_MOVE" means it was already on, which is a success here.
        if not (world.strengthActive) then
          return false, ("STRENGTH refused (%s)")
            :format(tostring(result and result.text))
        end
      end
      bot:wait(8)
      bot:clearDialogue({ "yes" }, 4000)
    end

    bot:say(("  push: strength %s, boulder at (%d,%d), pushing %s from (%d,%d)")
      :format(world.strengthActive and "on" or "OFF", row.x, row.y,
              tostring(row.dir), standX, standY))

    -- Walking into the boulder is the push, and the player does NOT move: the
    -- cart treats a strength boulder like a solid NPC (.CheckNPC's "2"), so the
    -- rock slides and you stay where you were.  Two consequences the first
    -- version got wrong:
    --
    --   * Bot:stepDir reports "did not move" for a SUCCESSFUL push, and notes a
    --     wall at the boulder's old cell for its trouble.
    --   * The next push has to wait for the rock to finish sliding --
    --     World:tryPushBoulder refuses while `npc.moving` -- so back-to-back
    --     presses do nothing at all.  That was the whole failure: the log said
    --     "strength on, boulder ahead" and the lane never opened.
    for i = 1, (row.count or 1) do
      bot:face(bot.button(row.dir))
      local bx, by = A.pos(game)
      bot:stepDir(bot.button(row.dir))
      -- Let the boulder land before asking again.
      for _ = 1, 60 do
        local npc = A.npcAt(game, bx + d[1], by + d[2])
        if not (npc and npc.moving) then break end
        bot:wait(1)
      end
      bot:wait(4)
      local ax, ay = A.pos(game)
      local blocked = A.npcAt(game, ax + d[1], ay + d[2]) ~= nil
      bot:say(("  push %d: player (%d,%d)->(%d,%d), boulder cell %s")
        :format(i, bx, by, ax, ay, blocked and "still filled" or "clear"))
      -- A push that worked left a wall memory on a cell that is now free.
      bot:clearWall(A.mapId(game), bx + d[1], by + d[2])
      if A.busy(game) then bot:clearDialogue(nil, 2000) end
      bot:progress()
    end
    return true
  end

  -- Hold a fixed sequence of directions.
  --
  -- The one place objectives cannot be expressed as "be at this cell": an ICE
  -- floor, where a press slides until something stops you, so the reachable
  -- set is a function of the whole route rather than of adjacency and the
  -- bot's tile-by-tile planner cannot describe it at all.  The asm-walk writes
  -- the Mahogany and Blackthorn gym puzzles as exactly this -- a list of
  -- directions -- so the route carries the list.
  function ops.press(row)
    for _, raw in ipairs(row.dirs or {}) do
      local dir = bot.button(raw)
      if not dir then return false, "unknown direction " .. tostring(raw) end
      A.hold(game, dir)
      bot:wait(6)
      A.releaseDirs(game)
      -- Let the slide finish: an ice tile keeps the player moving for several
      -- cells after the press ends.
      for _ = 1, 120 do
        if not A.moving(game) then break end
        bot:wait(1)
      end
      bot:wait(2)
      if A.busy(game) then bot:clearDialogue(row.answers, 4000) end
      bot:progress()
    end
    return true
  end

  -- Catch one of `species` on this map.
  --
  -- Originally just the SLOWPOKE for SURF (Cyndaquil cannot learn it).  The
  -- route now also catches a POLIWAG for WHIRLPOOL/WATERFALL -- SLOWPOKE's
  -- tmhm list has SURF and STRENGTH but neither of those two -- and a bird
  -- for FLY.  `row.water` restricts the hunt to COLL_WATER cells so a map
  -- that also has grass does not burn the ball budget on land encounters.
  function ops.catch(row)
    local wanted = {}
    for _, id in ipairs(row.species or {}) do wanted[id] = true end

    local function have()
      for _, mon in ipairs(A.party(game)) do
        if wanted[mon.species] then return mon end
      end
      return nil
    end
    if have() then
      bot:say("  catch: already have one")
      return true
    end
    if A.partySize(game) >= 6 then return nil, "party is full" end

    local ball = row.ball or "POKE_BALL"
    -- A badge / teach may have just landed (FOGBADGE is the row above 07.30);
    -- drop the canSurf cache before asking, so a stale "no" from before Morty
    -- does not refuse a water hunt that is now legal.
    bot:forgetSurf()
    -- Water hunts need SURF + FOGBADGE before a water cell is even pathable.
    if row.water and not bot:canSurf() then
      return nil, "water catch needs SURF and FOGBADGE"
    end
    bot.catchWanted, bot.catchBall = wanted, ball
    local ok, err = pcall(function()
      for pass = 1, 300 do
        if have() then return end
        if not A.hasItem(game, ball) then
          error({ botStall = true, why = "out of " .. ball }, 0)
        end
        if A.busy(game) then
          -- Answer NO to the nickname prompt a catch ends on: the naming
          -- keyboard has no cancel, so opening it strands the run.
          bot:clearDialogue({ "no", "no" }, 2000)
        end
        if A.mapId(game) ~= row.map then
          if not bot:travelTo(row.map) then return end
        end
        local map = A.map(game)
        if not map then return end
        -- Wander to a cell we can actually reach, and re-roll rather than
        -- aiming at one behind a wall: an unreachable target makes walkTo bail
        -- immediately, so the bot stands still and never rolls an encounter.
        -- Aim at cells that can actually roll an encounter.  Collected once
        -- per pass and shuffled by index, so the hunt paces the grass instead
        -- of the corridor between it.
        local spots = {}
        for cy = 0, map.heightCells - 1 do
          for cx = 0, map.widthCells - 1 do
            -- COLL_WATER is in CheckGrassCollision's array, so a land hunt's
            -- filter has to EXCLUDE water, not merely not-require it: the
            -- Slowpoke Well's pond qualified as an "encounter cell", the
            -- shuffle aimed at it, and a party with no SURF bounced off the
            -- shore twelve times until the repeat guard killed the row.
            local water = A.isWater(map, cx, cy)
            if A.isEncounterCell(map, cx, cy)
                and ((row.water and water) or (not row.water and not water)) then
              spots[#spots + 1] = { cx, cy }
            end
          end
        end
        if #spots == 0 then
          if row.water then
            error({ botStall = true,
                    why = "no reachable water encounter cells on " .. row.map }, 0)
          end
          for _ = 1, 10 do
            local x = math.random(0, map.widthCells - 1)
            local y = math.random(0, map.heightCells - 1)
            if bot:planPath(x, y) then bot:walkTo(x, y, { attempts = 3 }) break end
          end
        else
          for _ = 1, 8 do
            local pick = spots[math.random(1, #spots)]
            if bot:planPath(pick[1], pick[2]) then
              bot:walkTo(pick[1], pick[2], { attempts = 3 })
              break
            end
          end
        end
        if pass % 20 == 0 then
          local left = (game.save and game.save.inventory
                        and game.save.inventory[ball]) or 0
          bot:say(("  catch: still hunting (%d %s left, party %d)")
            :format(left, ball, A.partySize(game)))
        end
      end
    end)
    bot.catchWanted, bot.catchBall = nil, nil
    if A.busy(game) then bot:clearDialogue({ "no", "no" }, 2000) end

    local mon = have()
    if mon then
      bot:say(("  catch: got a %s"):format(tostring(mon.species)))
      return true
    end
    if not ok and type(err) == "table" and err.why then return nil, err.why end
    return false, "did not catch " .. table.concat(row.species or {}, "/")
  end

  -- Walk about on this map until something happens.
  --
  -- Some beats are not reached by going anywhere: they are delivered.  Elm's
  -- SPECIALCALL_ASSISTANT is the one the route cannot do without -- Falkner's
  -- badge script arms it, the call only lands while the player is OUTSIDE and
  -- moving, and the call is what puts his aide in the Violet Pokecenter with
  -- the Togepi Egg.  `settle` cannot do this: there is nothing on screen to
  -- clear, the trigger is the walking itself.
  function ops.wander(row)
    -- `expectClear` is the mirror of `expect`: an object_event's event flag
    -- HIDES the object when it is SET, so "the aide has appeared" is a flag
    -- going to false.  Only this op needs it, so it is not part of the generic
    -- postcondition machinery.
    local function arrived()
      if row.expectClear then return flagSet(row.expectClear) == false end
      if row.expect then return satisfied(row) end
      return false
    end
    local target = row.expect or row.expectClear
    for pass = 1, (row.budget or 40) do
      if target and arrived() then return true end
      if A.busy(game) then bot:clearDialogue(row.answers, 4000) end
      if A.mapId(game) ~= row.map then
        if not bot:travelTo(row.map) then return false, "left " .. row.map end
      end
      local map = A.map(game)
      if not map then return false end
      local x = math.random(0, math.max(0, map.widthCells - 1))
      local y = math.random(0, math.max(0, map.heightCells - 1))
      if bot:planPath(x, y) then bot:walkTo(x, y, { attempts = 3 }) end
    end
    if A.busy(game) then bot:clearDialogue(row.answers, 4000) end
    return target == nil or arrived()
  end

  function ops.check(row)
    return satisfied(row)
  end

  function ops.manual(row)
    return nil, row.why
  end

  -- ---------------------------------------------------------------------
  -- the run
  -- ---------------------------------------------------------------------

  local from  = os.getenv("POKEPORT_GOLD_FROM")
  local until_ = os.getenv("POKEPORT_GOLD_UNTIL")
  -- Checkpointing.  POKEPORT_GOLD_CKPT=1 writes a save at the first row of
  -- every section; POKEPORT_GOLD_RESUME=NN loads section NN's checkpoint and
  -- starts the route there.  Unlike POKEPORT_GOLD_FROM (which skips ROWS and
  -- leaves the player in the bedroom), this restores the game state, so a
  -- late-section bug is a 30-second test instead of a 10-minute replay.
  local checkpointing = os.getenv("POKEPORT_GOLD_CKPT") == "1"
  local resume = os.getenv("POKEPORT_GOLD_RESUME")

  local function sectionOf(id)
    return tostring(id):match("^(%d+)%.") or tostring(id)
  end

  -- Wait for the world before touching anything: Game2 builds it during
  -- load, and a driver that starts pressing buttons first is pressing them
  -- at a nil map.
  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end
  if not A.ready(game) then
    print("[gold] the world never came up; is POKEPORT_GAME=gold set?")
    return
  end

  if resume then
    local ok, err = A.loadCheckpoint(game, resume)
    if not ok then
      print(("[gold] cannot resume from section %s: %s")
        :format(resume, tostring(err)))
      return
    end
    -- continueGame rebuilds the world from scratch, so wait for it the same
    -- way the cold boot above does.
    for _ = 1, 3000 do
      if A.ready(game) then break end
      bot:wait(1)
    end
    if not A.ready(game) then
      print("[gold] resumed save never brought the world up")
      return
    end
    bot:say(("resumed section %s on %s at %d,%d")
      :format(resume, tostring(A.mapId(game)), select(1, A.pos(game)),
              select(2, A.pos(game))))
  end

  bot:say(("start on %s at %d,%d")
    :format(tostring(A.mapId(game)), select(1, A.pos(game)),
            select(2, A.pos(game))))

  local started = from == nil and resume == nil
  local completed, failed, skipped = {}, {}, {}
  local aborted = nil
  local lastSection = nil

  -- Row id -> position, so a failed row can send the runner BACKWARDS.
  --
  -- `retryFrom` is how the route loops a fight it cannot yet win.  Losing in
  -- Gen 2 costs money and nothing else: every point of experience earned on
  -- the way to the wipe is kept.  So a party that loses to Bruno still banks
  -- the levels it took off Hitmontop, and the next attempt starts stronger
  -- than the last one.  Repeat that and the fight is eventually winnable
  -- without any route change at all -- which is the only grind available at
  -- this point, since Johto's wilds cap around level 30 and the Elite Four's
  -- own mons are in the forties.
  --
  -- The rewind target is a row, not a map, because the whole gauntlet has to
  -- restart: the Indigo Plateau Pokecenter's MAPCALLBACK_NEWMAP clears every
  -- EVENT_BEAT_ELITE_4_*, so after a wipe Will is standing there again.
  local indexOf = {}
  for i, r in ipairs(ROUTE) do indexOf[r.id] = i end
  local attempts = {}
  -- Frame stamp of when each row's current lap began, so a lap that costs
  -- nothing can be told from one that actually ran.
  local lapStartedAt = {}
  local retryCap = tonumber(os.getenv("POKEPORT_GOLD_RETRY")) or 12

  local function clearFailure(id)
    for i = #failed, 1, -1 do
      if failed[i].id == id then table.remove(failed, i) end
    end
  end

  local index = 0
  while index < #ROUTE do
    index = index + 1
    local row = ROUTE[index]
    if not started and row.id == from then started = true end
    if not started and resume and sectionOf(row.id) == resume then
      started = true
    end
    if started then
      -- One checkpoint per section, taken on the way IN so it captures the
      -- state the section starts from rather than the state it left behind.
      if checkpointing and sectionOf(row.id) ~= lastSection then
        lastSection = sectionOf(row.id)
        local ok, err = A.writeCheckpoint(game, lastSection)
        bot:say(("checkpoint %s: %s")
          :format(lastSection, ok and "written" or ("FAILED " .. tostring(err))))
      end
      bot:progress()
      -- Teaching SURF, earning FOGBADGE or losing the surfer all change which
      -- cells are passable and which borders can be stood on, and both answers
      -- are cached for speed.  A route row is the natural place to forget them:
      -- it is the only point where the party or the badges can have changed.
      bot:forgetSurf()
      bot.borders = {}
      -- Heal between rows when the party is in no state to fight.
      --
      -- Bot:maybeHeal has existed since the first version and was never called,
      -- which did not matter while a lost battle still ran the winner's script
      -- -- the bot fainted its way through Whitney and four Elite Four rooms and
      -- the run looked fine.  With that fixed (tests/gen2_battle_loss_test.lua)
      -- a wipe costs the whole objective, so arriving healthy is the difference
      -- between earning a badge and re-walking half of Johto.
      --
      -- Never inside the League: its rooms seal behind you, and the Indigo
      -- Plateau Pokecenter's MAPCALLBACK_NEWMAP clears every
      -- EVENT_BEAT_ELITE_4_*, so a heal after Will restarts the gauntlet.
      --
      -- `noHeal` is for puzzles that a MAPCALLBACK_NEWMAP undoes.  The
      -- Goldenrod underground switch byte resets on every entry to the
      -- underground / warehouse; a heal between Switch3 and Switch2 left the
      -- room, zeroed the byte, and the warehouse door never opened.
      if not row.noHeal and not tostring(row.id):match("^18%.") then
        -- Guarded like tryReach below: healUp travels, travel can stall, and
        -- a stall raised out here escaped the runner and killed a whole run
        -- as `driver error: table: 0x...` with neither a row nor a reason
        -- attached (the Radio Tower 2F corridor wedge).  A failed
        -- between-rows heal is not fatal; the next row plans fresh.
        local healed, err = pcall(bot.maybeHeal, bot)
        if not healed then
          if type(err) == "table" and err.botStall then
            bot:say(("  heal stalled: %s"):format(tostring(err.why)))
            bot:progress()
          else
            error(err, 0)
          end
        end
      end
      bot:say(("== [%d/%d] %s %s %s")
        :format(index, #ROUTE, row.id, row.op, tostring(row.map)))

      -- Already done?  A resumed run, or a script that set the flag as a side
      -- effect of an earlier row, should not redo the work.
      if row.expect and satisfied(row) then
        bot:say(("  already satisfied (%s)"):format(row.expect))
        completed[row.id] = true
        clearFailure(row.id)
      else
        -- Be on the right map first.  Every op except `travel` itself assumes
        -- it; this is the single line that turns the asm-walk's per-map
        -- checklist into something that does not need hop-by-hop directions.
        -- Guarded, for the same reason the op below is.
        --
        -- Bot:reachMap raises a `{ botStall = true }` table when it gives up,
        -- and these two calls sit OUTSIDE the pcall that catches it -- so a
        -- stall while travelling to a row's map escaped the runner entirely and
        -- killed the whole run with `driver error: table: 0x...`, which names
        -- neither the row nor the reason. Run 26 died that way at row 196 after
        -- eleven tries to cross MAHOGANY_TOWN's east edge, ~450k frames in,
        -- taking sections 07-12 with it. A stall here means exactly what a
        -- failed travel means: this row could not reach its map.
        local function tryReach(map)
          local ok, res = pcall(bot.reachMap, bot, map, row.region)
          if ok then return res end
          if type(res) == "table" and res.botStall then
            bot:say(("  travel to %s stalled: %s"):format(
              map, tostring(res.why)))
            return false
          end
          error(res, 0)
        end

        local onMap = true
        if row.op ~= "travel" and A.mapId(game) ~= row.map then
          onMap = tryReach(row.map)
          if not onMap then
            -- One retry. travelTo leaves behind a trip's worth of exit bans and
            -- a half-finished position, and a second attempt plans fresh from
            -- wherever it stopped -- which is what gets the bot back INTO
            -- Goldenrod Gym after Whitney's script pushes it out, so the badge
            -- talk that follows the fight can actually happen.
            bot:say(("  travel to %s failed, retrying once"):format(row.map))
            if A.busy(game) then bot:clearDialogue() end
            onMap = tryReach(row.map)
          end
        end

        local ok, why
        if not onMap then
          ok, why = false, "could not reach " .. tostring(row.map)
        else
          local run = ops[row.op]
          if not run then
            ok, why = nil, "unknown op " .. tostring(row.op)
          else
            local guarded, res, err = pcall(run, row)
            if not guarded then
              -- A stall inside an op is information about THAT op, not the end
              -- of the run: re-raise anything else.
              if type(res) == "table" and res.botStall then
                ok, why = false, "stalled: " .. tostring(res.why)
                -- ...unless it is fatal.  A battle the engine cannot finish
                -- leaves the battle on the stack, so every later row would
                -- re-enter it and stall the same way, filling the report with
                -- 80 copies of one problem.  Stop and say what happened.
                if res.fatal then
                  bot:say("ABORTING RUN: " .. tostring(res.why))
                  failed[#failed + 1] = { id = row.id, why = res.why,
                                          map = tostring(A.mapId(game)) }
                  aborted = res.why
                  break
                end
              else
                error(res, 0)
              end
            else
              ok, why = res, err
            end
          end
        end

        -- `expect` is the ORACLE; the op's own opinion is advisory.
        --
        -- This used to read `ok and satisfied(row)`, which short-circuits: an
        -- op that returned false meant the flag was never even read, and the
        -- failure was then reported with the default string "postcondition
        -- <flag> not set" -- wording that asserts a check which did not happen.
        --
        -- Row 18.18 is the case that matters. Beating Lance opens the door and
        -- the bot walks straight through it, so the `walk` op ends with "left
        -- LANCES_ROOM for HALL_OF_FAME" and reports failure -- after winning.
        -- Run 20 beat the Champion ten times ("CHAMPION LANCE was defeated!",
        -- the prize money, the door) and threw all ten away, then rewound out
        -- of the Hall of Fame to refight the gauntlet.
        --
        -- If a row named a flag and that flag is set, the row is done, whatever
        -- the op made of its own walk.
        local passed
        if row.expect then passed = satisfied(row) else passed = ok end
        if ok == nil then
          bot:say(("  SKIP %s: %s"):format(row.id, tostring(why)))
          skipped[#skipped + 1] = { id = row.id, why = why }
        elseif passed then
          bot:say("  ok")
          completed[row.id] = true
          clearFailure(row.id)
        else
          local reason = why
            or (row.expect and ("postcondition " .. row.expect .. " not set"))
            or "action reported failure"
          local limit = row.retryLimit or retryCap
          if row.optional then
            bot:say(("  optional miss %s: %s"):format(row.id, reason))
            skipped[#skipped + 1] = { id = row.id, why = reason, soft = true }
          elseif row.retryFrom and indexOf[row.retryFrom]
              and (attempts[row.id] or 0) < limit
              and bot:frames() > (lapStartedAt[row.id] or -1) then
            -- The guard on frames: a lap that took ZERO frames did not retry
            -- anything, it spun.  Cianwood is the case -- a boulder puzzle left
            -- in a sealed state answers "approach: nowhere to stand"
            -- immediately, so run 25 burned all four of Chuck's laps inside a
            -- single frame without the player ever moving.  If a whole lap
            -- costs nothing, the state that caused the failure has not changed
            -- and never will; stop and report instead of spending the budget.
            -- Not a failure yet: a lap.  Rewind and run the stretch again with
            -- whatever levels this attempt earned before it died.
            attempts[row.id] = (attempts[row.id] or 0) + 1
            lapStartedAt[row.id] = bot:frames()
            bot:say(("  RETRY %s (lap %d/%d): %s -- rewinding to %s")
              :format(row.id, attempts[row.id], limit, reason, row.retryFrom))
            if A.busy(game) then bot:clearDialogue() end
            -- Bank the lap.
            --
            -- The whole point of a retry lap is that the levels it earned are
            -- kept, and a wall-clock timeout that threw them away would undo
            -- exactly the thing the loop exists to accumulate: the Elite Four
            -- laps take the lead up ~4 levels each, so a run killed at lap
            -- eight restarts eleven levels weaker than it died.  A wipe leaves
            -- the player healed and stood in a Pokecenter, which is the
            -- cleanest state in the loop to snapshot.
            local section = sectionOf(row.id)
            local wrote, err = A.writeCheckpoint(game, section)
            bot:say(("  lap checkpoint %s: %s"):format(
              section, wrote and "written" or ("skipped " .. tostring(err))))
            index = indexOf[row.retryFrom] - 1
          else
            bot:say(("  FAIL %s: %s"):format(row.id, reason))
            failed[#failed + 1] = { id = row.id, why = reason,
                                    map = tostring(A.mapId(game)) }
          end
        end
      end
    end
    if aborted then break end
    if until_ and row.id == until_ then break end
  end

  -- ---------------------------------------------------------------------
  -- report
  -- ---------------------------------------------------------------------
  print("")
  print("================ gold bot summary ================")
  -- Counted over the SET of ids, not the number of passes: a retry lap runs
  -- Will's room again and that is one row completed, not two.
  local done = 0
  for _, r in ipairs(ROUTE) do
    if completed[r.id] then done = done + 1 end
  end
  print(("route rows completed : %d/%d"):format(done, #ROUTE))
  print(("badges               : %d"):format(A.badges(game)))
  print(("final map            : %s"):format(tostring(A.mapId(game))))
  print(("party                : %d mon, lowest level %d")
    :format(A.partySize(game), A.minLevel(game)))
  print(("frames               : %d"):format(bot:frames()))
  print(("teleport shortcuts   : %d"):format(bot.teleports or 0))
  if #skipped > 0 then
    print(("\nnot implemented / optional misses (%d):"):format(#skipped))
    for _, s in ipairs(skipped) do
      print(("  %-8s %s"):format(s.id, tostring(s.why)))
    end
  end
  if #failed > 0 then
    print(("\nFAILED (%d) -- each names an asm-walk checklist row:"):format(#failed))
    for _, f in ipairs(failed) do
      print(("  %-8s on %-24s %s"):format(f.id, f.map, tostring(f.why)))
    end
  end
  if aborted then
    print(("\nRUN ABORTED: %s"):format(tostring(aborted)))
  end
  -- The result line names the furthest thing actually PROVEN, in flags.
  --
  -- It used to report the Mineral Badge either way, which was the milestone
  -- when the bot could not get past Olivine and was long stale by the time the
  -- Champion fell -- run 22 beat Lance and still printed "reached the Mineral
  -- Badge".  Deliberately NOT keyed on `final map`: the Hall of Fame is
  -- reachable by the harness teleport, and EVENT_BEAT_ELITE_FOUR can be left
  -- set in a resumed checkpoint, so neither is evidence.  Lance's own flag is.
  local champion = A.event(game, "EVENT_BEAT_CHAMPION_LANCE")
  local badges = A.badges(game)
  print("")
  if champion then
    print("RESULT: CHAMPION LANCE DEFEATED -- the game is beaten")
    if (bot.teleports or 0) > 0 then
      print(("        (%d teleport shortcut(s) were used somewhere in this run;"
             .. " check they were not on the way to the League)")
        :format(bot.teleports))
    end
  elseif badges >= 8 then
    print("RESULT: all eight badges, Champion not beaten")
  else
    print(("RESULT: %d/8 badges, Champion not beaten"):format(badges))
  end
  print("==================================================")
end
