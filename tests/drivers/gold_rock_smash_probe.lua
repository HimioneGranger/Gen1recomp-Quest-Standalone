-- ROCK SMASH's wild encounter, and the beasts scattering on CONTINUE, driven
-- through the real game.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold POKEPORT_SPEED=200 \
--     POKEPORT_GOLD_RESUME=13 \
--     POKEPORT_DRIVER=tests/drivers/gold_rock_smash_probe.lua love .
--
-- Two things a ROM-free suite cannot see, because both live behind World:load:
--
--   * the `readMem` hook.  RockSmashScript is `callasm RockMonEncounter /
--     readmem wTempWildMonSpecies / iffalse .done / randomwildmon /
--     startbattle`, and the byte only reads back if World:load installed the
--     seam -- otherwise the VM answers out of its own sparse store, sees 0 and
--     skips the battle, which is what the port did for every smash in the game.
--   * `farcall JumpRoamMons` on the continue path
--     (engine/menus/intro_menu.asm), which is World:roamMonsOnContinue and runs
--     from inside World:load rather than from any map setup script.
--
-- Prints one PASS/FAIL line per claim and quits, so a killed run is visibly
-- incomplete rather than silently green.

local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter

-- data/wild/treemon_maps.asm RockMonMaps: the rock at (16,14) of Dark Cave's
-- Violet entrance is object 2, reachable from (15,14).
local ROCK_MAP = "DARK_CAVE_VIOLET_ENTRANCE"
local ROCK_X, ROCK_Y = 16, 14
local STAND_X, STAND_Y = 15, 14

-- constants/pokemon_constants.asm; TreeMonSet_Rock is 90 KRABBY / 10 SHUCKLE.
local ROCK_SPECIES = { [98] = "KRABBY", [213] = "SHUCKLE" }

local results = {}

local function claim(ok, text)
  results[#results + 1] = ok and true or false
  print((ok and "[rocksmash] PASS " or "[rocksmash] FAIL ") .. text)
end

return function(game)
  local bot = Bot.new(game)

  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end
  local resume = os.getenv("POKEPORT_GOLD_RESUME") or "13"
  local ok, err = A.loadCheckpoint(game, resume)
  if not ok then
    print(("[rocksmash] cannot resume %s: %s"):format(resume, tostring(err)))
    love.event.quit()
    return
  end
  for _ = 1, 3000 do
    if A.ready(game) then break end
    bot:wait(1)
  end

  -- ---- JumpRoamMons on CONTINUE -------------------------------------------
  --
  -- Park all three beasts on one map, then load the very same save again the
  -- way the CONTINUE menu does.  JumpRoamMon re-rolls off the player's own map
  -- and picks one of sixteen otherwise, so all three staying put is a 1 in
  -- 4096 coincidence rather than a passing implementation.
  local save = game.save
  if save and not save.roamers then
    -- `special InitRoamMons`, which the Burned Tower basement runs when the
    -- floor gives way.  A checkpoint taken before that has no structs, and the
    -- scatter below is about the CONTINUE path rather than about this.
    require("src.core.gen2.Roamers").init(save, { force = true })
    print("[rocksmash] note: seeded InitRoamMons for this checkpoint")
  end
  if not (save and save.roamers) then
    claim(false, "the save has roamers to scatter")
  else
    for _, slot in ipairs(save.roamers) do
      if slot.species then slot.map = "ROUTE_29" end
    end
    local continued = pcall(game.continueGame, game, save)
    for _ = 1, 3000 do
      if A.ready(game) then break end
      bot:wait(1)
    end
    local moved = 0
    for _, slot in ipairs(game.save.roamers or {}) do
      if slot.species and slot.map ~= "ROUTE_29" then moved = moved + 1 end
    end
    claim(continued and moved > 0,
      ("CONTINUE scattered the beasts (%d of 3 left ROUTE_29)"):format(moved))
  end

  -- ---- RockMonEncounter ----------------------------------------------------
  local world = game.world
  world:setMap(ROCK_MAP, STAND_X, STAND_Y, "right")
  bot:wait(30)
  bot:clearDialogue(nil, 4000)
  claim(A.mapId(game) == ROCK_MAP, "arrived at " .. ROCK_MAP)

  -- HasRockSmash is CheckPartyMove: the lead has to know the move for
  -- AskRockSmashScript to open at all.  Teaching it is the setup, not the
  -- thing under test.
  local lead = game.save.party and game.save.party[1]
  if lead then
    lead.moves = lead.moves or {}
    lead.moves[#lead.moves + 1] = { id = "ROCK_SMASH", pp = 15, maxPp = 15 }
  end
  claim(lead ~= nil, "the lead can be taught ROCK SMASH")

  -- `ld a, 10 / RandomRange / cp 4` and then SelectTreeMon's 0..99: a zero
  -- passes the 40 percent and lands in the 90 percent KRABBY bracket, so the
  -- smash below is the deterministic case.
  world.rockmonRandom = function() return 0 end
  -- Dark Cave is a wild-encounter map; the walk to the rock must not be
  -- interrupted by one, and the battle under test comes from the script.
  world.noWildEncounters = true

  -- The `startbattle` RockSmashScript ends on comes through here, and the bot
  -- fights the battle out before any poll of its own could see it -- so the
  -- species is read off the seam the script itself reaches.
  local fought
  local realScripted = world.startScriptedBattle
  world.startScriptedBattle = function(self, record, wild, onDone)
    if wild and wild.species then fought = wild.species end
    return realScripted(self, record, wild, onDone)
  end

  local reached = bot:approachAndFace(ROCK_X, ROCK_Y)
  claim(reached, "faced the rock at " .. ROCK_X .. "," .. ROCK_Y)

  for attempt = 1, 4 do
    bot:tap("a")
    bot:wait(4)
    for _ = 1, 40 do
      if A.busy(game) then break end
      bot:wait(1)
    end
    if A.busy(game) then break end
    print("[rocksmash] tap " .. attempt .. " opened nothing")
  end
  -- AskRockSmashScript's yesorno, then the smash, the earthquake and the roll.
  bot:clearDialogue({ "yes" }, 8000)
  for _ = 1, 600 do
    if fought or not A.busy(game) then break end
    bot:wait(1)
  end

  claim(fought ~= nil, "the smash reached startbattle at all")
  claim(fought ~= nil and ROCK_SPECIES[fought] ~= nil,
    "and the wild mon came out of TREEMON_SET_ROCK (got "
      .. tostring(fought and ROCK_SPECIES[fought] or fought) .. ")")

  local failures = 0
  for _, value in ipairs(results) do
    if not value then failures = failures + 1 end
  end
  print(("[rocksmash] %d claims, %d failed"):format(#results, failures))
  love.event.quit()
end
