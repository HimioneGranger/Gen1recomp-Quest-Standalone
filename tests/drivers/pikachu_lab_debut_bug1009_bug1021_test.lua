-- Pikachu stays in its ball until the rival fight (#1009) and clears (4,3) for the rival (#1021); the Route 15 leg only instruments #920.
-- pokeyellow scripts/OaksLab.asm, OaksLab_2.asm.
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local GameVersion = require("src.core.GameVersion")
  local MapScripts = require("src.script.MapScripts")
  local Commands = require("src.script.Commands")
  local PF = require("src.world.PikachuFollower")
  local Pokemon = require("src.pokemon.Pokemon")
  local Bag = require("src.inventory.Bag")
  local BattleState = require("src.battle.BattleState")

  local SHOT_DIR = os.getenv("SHOT_DIR") or "/tmp/shots"
  local LAB = "OAKS_LAB"
  local RIVAL = 1                       -- OAKSLAB_RIVAL, object index 1
  local GIFT = { x = 5, y = 3 }   -- where OaksLabRLE_PlayerWalksToOak ends

  local function check(label, ok)
    U.log(ok and "PASS" or "FAIL", label)
    return ok
  end
  local function idle()
    while true do coroutine.yield() end
  end
  local function ow() return game.overworld end
  local function follower() return PF.current(game.overworld) end
  local function ctx()
    return { game = game, save = game.save, overworld = game.overworld }
  end
  local function where(npc)
    if not npc then return "gone" end
    return "(" .. npc.cellX .. "," .. npc.cellY .. ") facing "
           .. tostring(npc.facing)
  end

  -- one player step; false when refused, so a caller can route around a map edit
  local function stepOnce(dir)
    local p = ow().player
    local x0, y0 = p.cellX, p.cellY
    for _ = 1, 60 do
      table.insert(game.input.pressQueue, dir)
      game.input.state[dir] = true
      coroutine.yield()
      p = ow().player
      if p.cellX ~= x0 or p.cellY ~= y0 then break end
    end
    game.input.state[dir] = false
    for _ = 1, 40 do
      if not ow().player.moving then break end
      U.wait(1)
    end
    U.wait(3)
    p = ow().player
    return p.cellX ~= x0 or p.cellY ~= y0
  end

  -- ---------------------------------------------------------------- checks
  if not check("running the Yellow cache (POKEPORT_VERSION=yellow)",
               GameVersion.isYellow()) then
    U.log("Red and Blue have no follower and no Yellow lab script, so every")
    U.log("line below would fail for the wrong reason.")
    idle()
  end
  check("SPRITE_PIKACHU resolves in the sprite table",
        game.data.sprites ~= nil and game.data.sprites.SPRITE_PIKACHU ~= nil)
  check("PikachuFollower.oaksLabMakeWay exists",
        type(PF.oaksLabMakeWay) == "function")
  check("the pikachu_make_way verb exists",
        type(Commands.pikachu_make_way) == "function")
  check("and it blocks the runner while the walk plays",
        Commands.meta.pikachu_make_way ~= nil
        and Commands.meta.pikachu_make_way.blocking == true)

  local lab = require("data.scripts.oaks_lab_yellow")
  local oakRows = lab.talk.TEXT_OAKSLAB_OAK1
  local function rowIndex(pred)
    for i, r in ipairs(oakRows) do
      if pred(r) then return i end
    end
    return nil
  end
  local iGramps = rowIndex(function(r)
    return r[1] == "show_text" and r[2] == "_OaksLabRivalGrampsText"
  end)
  local iMakeWay = rowIndex(function(r) return r[1] == "pikachu_make_way" end)
  local iShow = rowIndex(function(r)
    return r[1] == "show_object" and r[3] == "OAKSLAB_RIVAL"
  end)
  check("Oak's parcel branch has a make-way row", iMakeWay ~= nil)
  -- the callfar sits after the GRAMPS text and before ShowObject; a row on
  check("it sits between the GRAMPS text and the rival's ShowObject",
        iGramps ~= nil and iMakeWay ~= nil and iShow ~= nil
        and iGramps < iMakeWay and iMakeWay < iShow)

  local sfx = game.save.options and game.save.options.sfxVol
  if sfx == 0 then
    U.log("sfxVol is 0. Pikachu's cry as it bursts out of the ball will be")
    U.log("silent and a mute run reads exactly like a missing cry -- turn")
    U.log("the sound back up before judging the escape scene.")
  end

  -- leg 1: in the ball.  Level 30 only so the lab battle ends fast
  game.save.flags = game.save.flags or {}
  local flags = game.save.flags
  flags.EVENT_GOT_STARTER = true
  flags.EVENT_CHOSE_PIKACHU = true
  flags.EVENT_FOLLOWED_OAK_INTO_LAB = true
  flags.EVENT_FOLLOWED_OAK_INTO_LAB_2 = true
  flags.EVENT_BATTLED_RIVAL_IN_OAKS_LAB = nil
  flags.EVENT_OAK_ASKED_TO_CHOOSE_MON = true
  flags.EVENT_GOT_POKEDEX = nil
  flags.EVENT_OAK_GOT_PARCEL = nil
  game.save.party = { Pokemon.new(game.data, "PIKACHU", 30) }
  game.save.player.name = "bryan"
  game.save.onBike = false
  game.save.pikachuInBall = true

  U.teleport(game, LAB, GIFT.x, GIFT.y, "up")
  U.wait(10)
  Commands.show_object(ctx(), LAB, "OAKSLAB_OAK1")
  U.wait(5)

  -- asked after the teleport: the registry only fills on first require
  check("the Yellow lab module is the one bound to the map",
        MapScripts.talkScript(LAB, "TEXT_OAKSLAB_OAK1") == oakRows)

  check("straight after the gift there is no follower on the map",
        follower() == nil)

  -- save compat: nil pikachuInBall falls back to the rival-fight flag, not false
  game.save.pikachuInBall = nil
  U.wait(10)
  check("a pre-#1009 save before the rival fight still has none",
        follower() == nil)
  flags.EVENT_BATTLED_RIVAL_IN_OAKS_LAB = true
  U.wait(20)
  check("a pre-#1009 save past the rival fight keeps its follower",
        follower() ~= nil)
  flags.EVENT_BATTLED_RIVAL_IN_OAKS_LAB = nil
  game.save.pikachuInBall = true
  U.wait(20)
  check("and the in-ball byte puts it away again", follower() == nil)

  U.shot(game, SHOT_DIR .. "/bug1009_in_ball.png")
  U.log("captured", SHOT_DIR .. "/bug1009_in_ball.png",
        "- player alone at the gift spot")

  -- --------------------------------------------- leg 2: out of the ball
  Commands.show_object(ctx(), LAB, "OAKSLAB_RIVAL")
  U.wait(5)

  -- OaksLabRivalChallengesPlayerScript fires from y >= 6 with the starter held
  local walkedClean = true
  for _ = 1, 10 do
    if ow().player.cellY >= 6 then break end
    if follower() then walkedClean = false end
    if not stepOnce("down") then
      if not stepOnce("left") then break end
    end
  end
  check("crossed the lab to the door row with no follower behind",
        walkedClean and follower() == nil)
  check("reached the row the rival challenges from", ow().player.cellY >= 6)

  -- the escape only spawns the companion once the overworld is back on top
  local sawBattle, escapedAt, spawnCell = false, nil, nil
  for _ = 1, 2500 do
    local o = game.overworld
    local top = game.stack:top()
    if top ~= o then
      if getmetatable(top) == BattleState then sawBattle = true end
      U.tap(game, "a")
      U.wait(3)
    else
      local npc = follower()
      if npc and not escapedAt then
        escapedAt = U.frame()
        spawnCell = { x = npc.cellX, y = npc.cellY, facing = npc.facing }
        U.shot(game, SHOT_DIR .. "/bug1009_escaped.png")
      end
      if escapedAt and not o.runner:isRunning() and #o.scriptMoves == 0 then
        break
      end
      U.wait(2)
    end
  end

  check("the rival battle actually ran", sawBattle)
  check("the escape scene put a follower on the map", escapedAt ~= nil)
  check("EVENT_BATTLED_RIVAL_IN_OAKS_LAB is set",
        flags.EVENT_BATTLED_RIVAL_IN_OAKS_LAB == true)
  check("the ball is open (save.pikachuInBall false, not nil)",
        game.save.pikachuInBall == false)
  if spawnCell then
    local p = ow().player
    U.log("it appeared at", spawnCell.x, spawnCell.y, "with the player at",
          p.cellX, p.cellY, "facing", p.facing)
    -- OaksLabPikachuEscapesPokeballScript faces the player up and uses spawn
    check("it burst out on the cell behind the player, not beside him",
          spawnCell.x == p.cellX and spawnCell.y == p.cellY + 1)
    U.log("captured", SHOT_DIR .. "/bug1009_escaped.png")
  end

  -- leg 3: Oak's .DeliverParcelText needs parcel held, no balls, no Pokedex
  flags.EVENT_BATTLED_RIVAL_IN_OAKS_LAB = true
  flags.EVENT_PALLET_AFTER_GETTING_POKEBALLS = nil
  flags.EVENT_BEAT_ROUTE22_RIVAL_1ST_BATTLE = nil
  flags.EVENT_GOT_POKEDEX = nil
  game.save.pikachuInBall = false
  game.save.inventory = game.save.inventory or {}
  game.save.inventory.POKE_BALL = nil
  if game.save.pokedex then game.save.pokedex.owned = {} end
  Bag.add(game.save, "OAKS_PARCEL", 1, game.data)

  -- the SPRITE_FACING_LEFT case of TryApplyPikachuMovementData
  U.teleport(game, LAB, 4, 3, "right")
  U.wait(10)
  Commands.show_object(ctx(), LAB, "OAKSLAB_OAK1")
  -- he walked out after the lab battle; ShowObject brings him back mid-scene
  Commands.hide_object(ctx(), LAB, "OAKSLAB_RIVAL")
  U.wait(5)
  check("the follower is back for the parcel scene", follower() ~= nil)
  stepOnce("right")
  -- Oak stands on (5,2) and blocks, so this only turns the player up
  U.hold(game, "up", 10)
  U.wait(10)

  local p = ow().player
  local pika = follower()
  U.log("player at", p.cellX, p.cellY, "facing", p.facing,
        "| Pikachu at", where(pika))
  check("the player is below Oak on row 3", p.cellY == 3 and p.facing == "up")
  local onRivalCell = pika ~= nil and pika.cellX == 4 and pika.cellY == 3
  check("Pikachu is standing on the rival's landing cell (4,3)", onRivalCell)
  if not onRivalCell then
    U.log("Without it on (4,3) the movement data does not apply and the")
    U.log("scene below proves nothing about #1021.")
  end
  U.shot(game, SHOT_DIR .. "/bug1021_before.png")

  -- the rival's own walk sits in the same scriptMoves list, so ask only
  local function stillWalking(o, npc)
    if npc.moving then return true end
    for _, mv in ipairs(o.scriptMoves) do
      if mv.entity == npc then return true end
    end
    return false
  end

  -- end pose snapshotted at walk stop; the idle roll turns it later (Func_fc803)
  U.tap(game, "a")
  local leftCell, rivalSeen, rivalArrived, midShot = nil, nil, nil, false
  local settled
  local trace, last = {}, nil
  for f = 1, 1200 do
    local o = game.overworld
    local top = game.stack:top()
    local npc = follower()
    if npc then
      local cell = npc.cellX .. "," .. npc.cellY
      if cell ~= last then
        last = cell
        trace[#trace + 1] = "f" .. f .. " " .. cell
      end
      if not leftCell and not (npc.cellX == 4 and npc.cellY == 3) then
        leftCell = f
      end
      if leftCell and not settled and not stillWalking(o, npc) then
        settled = { x = npc.cellX, y = npc.cellY, facing = npc.facing }
      end
    end
    local rival = o:npcByIndex(RIVAL)
    if rival and not rivalSeen then rivalSeen = f end
    if rival and not rivalArrived and rival.cellX == 4 and rival.cellY == 3
       and not rival.moving then
      rivalArrived = f
    end
    if leftCell and rival and rival.moving and not midShot then
      midShot = true
      U.shot(game, SHOT_DIR .. "/bug1021_stepped_aside.png")
    end
    if rivalArrived and settled then break end
    if top ~= o then U.tap(game, "a") end
    U.wait(2)
  end

  U.log("Pikachu trace:", table.concat(trace, " | "))
  check("Pikachu moved off (4,3)", leftCell ~= nil)
  check("the rival came in and reached (4,3)", rivalArrived ~= nil)
  if leftCell and rivalSeen then
    -- the callfar runs before ShowObject: the cell is clear before the rival
    check("it started clearing the cell before the rival appeared",
          leftCell <= rivalSeen)
  end
  if settled then
    U.log("the walk ended with Pikachu at", settled.x, settled.y,
          "facing", settled.facing)
  end
  -- OaksLabPikachuMovementData2: STEP_DOWN, STEP_RIGHT, LOOK_UP
  check("it ended one below the player looking up",
        settled ~= nil and settled.x == 5 and settled.y == 4
        and settled.facing == "up")
  U.shot(game, SHOT_DIR .. "/bug1021_rival_in_place.png")

  -- leg 4: nothing is fixed for #920; this only records ow.npcs and trail.ledgeHop
  local eastMap = game.data.maps.FUCHSIA_CITY
                  and game.data.maps.FUCHSIA_CITY.connections
                  and game.data.maps.FUCHSIA_CITY.connections.east
  eastMap = eastMap and eastMap.map or "ROUTE_15"
  U.log("Fuchsia's east connection is", eastMap)

  U.teleport(game, "FUCHSIA_CITY", 10, 12, "down")
  U.wait(10)
  local city = ow().map
  local row = nil
  for y = 0, city.heightCells - 1 do
    if city:isWalkableCell(city.widthCells - 1, y)
       and city:isWalkableCell(city.widthCells - 2, y) then
      row = row or y
    end
  end
  if row then
    U.log("crossing the east seam on row", row)
    U.teleport(game, "FUCHSIA_CITY", city.widthCells - 2, row, "right")
    U.wait(10)
    for _ = 1, 6 do
      if ow().map.id == eastMap then break end
      if not stepOnce("right") then break end
    end
  end
  -- the seam row is blocked (gate rebuild, mod): drop in on the route itself
  local function dropOnRoute()
    U.teleport(game, eastMap, 4, 8, "right")
    U.wait(10)
    local m = ow().map
    if m:isWalkableCell(4, 8) then return end
    for y = 0, m.heightCells - 1 do
      for x = 0, 9 do
        if m:isWalkableCell(x, y) then
          U.teleport(game, eastMap, x, y, "right")
          U.wait(10)
          return
        end
      end
    end
  end
  if ow().map.id ~= eastMap then
    U.log("could not walk the seam; dropping straight on to", eastMap)
    dropOnRoute()
  end
  check("standing on " .. eastMap, ow().map.id == eastMap)

  local worstGap, lostAt, steps = 0, nil, 0
  local back = { x = ow().player.cellX, y = ow().player.cellY }
  for i = 1, 10 do
    if not stepOnce("right") then
      if not stepOnce("down") then break end
    end
    local o = game.overworld
    if o.map.id ~= eastMap then
      -- the route's gate is a warp, and an arrival respawn is not the stall
      U.log("step", i, "walked into", o.map.id, "- stepping back out")
      U.teleport(game, eastMap, back.x, back.y, "left")
      U.wait(10)
      break
    end
    steps = i
    back.x, back.y = o.player.cellX, o.player.cellY
    local npc = follower()
    local p2 = o.player
    local hop = o.pikachuTrail and o.pikachuTrail.ledgeHop
    if npc then
      local gap = math.abs(npc.cellX - p2.cellX)
                  + math.abs(npc.cellY - p2.cellY)
      if gap > worstGap then worstGap = gap end
      U.log("step", i, "player", p2.cellX, p2.cellY, "| Pikachu", where(npc),
            "| gap", gap, "| ledgeHop", tostring(hop))
    else
      lostAt = lostAt or i
      U.log("step", i, "player", p2.cellX, p2.cellY,
            "| Pikachu is not in ow.npcs at all | ledgeHop", tostring(hop))
    end
  end
  U.log("walked", steps, "steps east on", eastMap)
  check("the follower stayed in ow.npcs the whole way", lostAt == nil)
  check("it never fell more than two cells behind", worstGap <= 2)
  if lostAt then
    U.log("it dropped out of ow.npcs on step", lostAt,
          "- that is the shape #920 would take")
  end
  -- an arrival parks the follower under the player (#863), so walk one step
  stepOnce("left")
  U.wait(20)
  U.shot(game, SHOT_DIR .. "/bug920_east_of_fuchsia.png")

  U.log("Six shots, in story order. bug1009_in_ball: the player alone in the")
  U.log("lab with the starter already in the party. bug1009_escaped: the cry,")
  U.log("then Pikachu on the cell behind him. bug1021_stepped_aside: it walks")
  U.log("down and right on the GRAMPS text while the rival is still off the")
  U.log("map, ending below the player looking up. The near miss to watch for")
  U.log("is the rival arriving first and Pikachu shuffling around him after,")
  U.log("or the walk playing under the box instead of after it.")
  U.log("Talk to Pikachu here for the control case: it answers with a bubble")
  U.log("and a cry, which is the same sprite and the same audio path.")
  U.log("#920 is unfixed. The pad is yours on Route 15; the step log above is")
  U.log("what the triage wants from a stall -- whether it is still in ow.npcs")
  U.log("and whether trail.ledgeHop stayed set after a ledge.")

  idle()
end
