-- Gate for the Gen 1 module facades a gen2compat mod's require resolves to
-- (src/mods/Gen2Compat.lua).
--
-- The rules this file holds, all of them load-bearing for a Gen 1 follower mod
-- running on Gold:
--   * every served name hands back one stable table, and the ones backed by a
--     Gen 2 module ARE that module, so a monkey-patch lands where Gold runs;
--   * the Game facade is a live proxy, not a snapshot, and aliases the two
--     names Gold spells differently (overworld / writeOptions) plus the one
--     data table that was renamed (sprites);
--   * src/world/gen2/Follower.lua keeps a file-local named exactly
--     `shouldSpawn`, shared by update and onMapEntered, because that upvalue
--     NAME is what three separate follower mods rewrite through
--     debug.setupvalue;
--   * World:step ticks the follower and the overworld facade unconditionally,
--     and World:interact dispatches through the facade when one is installed.
--
-- ROM-free: the world here is hand-built, the way tests/gen2_world_test.lua
-- builds one.

package.path = "./?.lua;./?/init.lua;" .. package.path

love = love or require("tests.love_stub")

local S = require("tests.harness").suite("gen2 mod facade")
local check, eq = S.check, S.eq

local Gen2Compat = require("src.mods.Gen2Compat")
local Follower = require("src.world.gen2.Follower")
local Gen2Map = require("src.world.gen2.Map")
local Gen2Npc = require("src.world.gen2.Npc")
local Player = require("src.world.gen2.Player")
local World = require("src.world.gen2.World")

-- ------- 1. every served name resolves, once, to a table

local SERVED = {
  "src.core.Game", "src.world.NPC", "src.world.Collision",
  "src.world.FieldDefaults", "src.pokemon.Boxes",
  "src.world.OverworldController", "src.world.PikachuFollower",
  "src.world.Map", "src.world.WorldAPI", "src.ui.PartyMenu", "src.ui.BoxMenu",
  "src.ui.StartMenu", "src.ui.OptionsMenu", "src.battle.BattleState",
  "src.script.ScriptRunner",
}

for _, name in ipairs(SERVED) do
  check(Gen2Compat.serves(name), "served: " .. name)
  local a = Gen2Compat.resolve(name, "fixture")
  eq(type(a), "table", "resolves to a table: " .. name)
  check(a == Gen2Compat.resolve(name, "fixture"),
    "one stable table for the run: " .. name)
end

-- the aliased ones ARE the Gen 2 module, so a mod's patch lands on the table
-- Gold runs rather than on a copy
eq(Gen2Compat.resolve("src.world.PikachuFollower"), Follower,
  "PikachuFollower is src/world/gen2/Follower.lua itself")
eq(Gen2Compat.resolve("src.world.Map"), Gen2Map, "Map is the Gen 2 Map")
eq(Gen2Compat.resolve("src.world.NPC"), Gen2Npc,
  "NPC is the Gen 2 NPC, so getmetatable(npc) == the module the mod required")

-- Gen 1's BoxMenu is Bill's PC TOP MENU; Gold's counterpart is PcMenu, and
-- the Gen 2 BoxMenu is the withdraw/deposit LIST Gen 1 builds inline.  Aimed
-- at the wrong one, a mod appending a row appends it to an object with no
-- row list at all.
eq(Gen2Compat.resolve("src.ui.BoxMenu"), require("src.ui.gen2.PcMenu"),
  "BoxMenu is Gold's PC top menu, not its box list")

-- Gold has no BattleState.newWild, and inventing one that took a species and a
-- level would be the silent wrong answer this whole layer exists to avoid.
check(Gen2Compat.resolve("src.battle.BattleState").newWild == nil,
  "no invented newWild on the Gen 2 battle screen")

-- ------- 1b. the coverage table, which the modkit checker reads

eq(Gen2Compat.COVERAGE_VERSION, 1, "the coverage contract is versioned")
local names = Gen2Compat.modules()
eq(#names, #SERVED, "every served name is in the coverage listing")
for _, name in ipairs(names) do
  local row = Gen2Compat.coverage(name)
  check(row ~= nil, "coverage for " .. name)
  eq(row.module, name, "coverage names itself: " .. name)
  check(row.kind == "facade" or row.kind == "alias",
    "coverage kind is facade or alias: " .. name)
  for member, status in pairs(row.members) do
    check(status == "backed" or status == "warned" or status == "absent",
      ("%s.%s carries one of the three statuses"):format(name, member))
  end
end
eq(Gen2Compat.coverage("src.pokemon.Boxes").kind, "facade",
  "Boxes is a facade over the Gen 2 module, not an alias")
eq(Gen2Compat.memberStatus("src.pokemon.Boxes", "deposit"), "backed",
  "the deposit override is published as backed")
eq(Gen2Compat.memberStatus("src.battle.BattleState", "makeSafari"), "absent",
  "makeSafari is published absent, which is what the wilds mod probes for")
eq(Gen2Compat.memberStatus("src.world.Collision", "load"), "warned",
  "Collision.load is present, answers nil and says so")
eq(Gen2Compat.coverage("nope.nope"), nil, "an unserved name has no coverage")

-- a table per call, so a consumer cannot mutate the adapter's own record
local first = Gen2Compat.coverage("src.world.Collision")
first.members.canMove = "absent"
eq(Gen2Compat.memberStatus("src.world.Collision", "canMove"), "backed",
  "coverage hands back a fresh table each call")

-- ------- 2. the Game facade proxies a LIVE game

local persisted = 0
local liveGame = {
  world = { tag = "the world" },
  save = { party = {} },
  stack = { tag = "the stack" },
  data = { gen2Sprites = { SPRITE_CHRIS = { id = "SPRITE_CHRIS" } },
           gen2Maps = { TEST_MAP = { id = "TEST_MAP" } },
           gen2Constants = { specialOrder = {} },
           pokemon = { PIDGEY = { name = "PIDGEY" } } },
  persistOptions = function() persisted = persisted + 1 end,
}
local current = nil
Gen2Compat.bind(function() return current end)

local Game = Gen2Compat.resolve("src.core.Game", "fixture")
eq(Game.save, nil, "captured before a game exists, the facade reads nil")
current = liveGame
eq(Game.save, liveGame.save, "and fills in the moment one is wired")
eq(Game.overworld, liveGame.world, "overworld is the Gen 1 name for .world")
eq(Game.stack, liveGame.stack, "the stack is the real one, so a patch of "
  .. "stack.push reaches the engine")
eq(Game.data.pokemon.PIDGEY.name, "PIDGEY", "data forwards")
eq(Game.data.sprites, liveGame.data.gen2Sprites,
  "data.sprites is the Gen 1 name for gen2Sprites")
eq(Game.data.field, nil, "data.field has no Gen 2 backing and says so")
Game.writeOptions(Game)
eq(persisted, 1, "writeOptions is persistOptions, called with the live game")
Game._fixtureStamp = true
eq(liveGame._fixtureStamp, true, "a stamp written through the facade lands on "
  .. "the live game")

-- the four Gen 1 members Gold has no counterpart for are NAMED, not answered
eq(Game.renderer, nil, "Game.renderer is absent, not the real Renderer: half "
  .. "its surface would answer and the other half silently no-op")
eq(Game.load, nil, "Game:load is absent; calling it would re-run Gold's boot")
eq(Game.bootConfig, nil, "Game:bootConfig is absent")
eq(Game.makeTitleState, nil, "Game:makeTitleState is absent")
eq(Game.data.constants, nil, "data.constants is NOT routed to gen2Constants, "
  .. "which is the cart's ordered name lists and a different thing entirely")
eq(Game.data.maps, liveGame.data.gen2Maps, "data.maps is the Gen 1 name")
eq(Game.logicSpeed(), 1, "logicSpeed never returns below 1 on Gold")
eq(type(Game.fixedStep), "table", "fixedStep is the shared singleton")

-- ------- 3. NPC: the Gen 1 constructor shape, a Gen 2 entity out

local NPCFacade = Gen2Compat.resolve("src.world.NPC", "fixture")
local sheet = "assets/fixture/follower.png"
local sprites = { SPRITE_PIKACHU =
  { id = "SPRITE_PIKACHU", image = sheet, frames = 6, walker = true } }
local trailer = NPCFacade.new({ gen2Sprites = sprites }, "TEST_MAP", {
  index = 241, name = "TRAILER_1", sprite = "SPRITE_PIKACHU",
  movement = "STAY", range = "NONE", x = 3, y = 4,
})
eq(getmetatable(trailer), Gen2Npc, "the trailer is a real Gen 2 NPC, so the "
  .. "Gen 2 draw list poses it")
eq(trailer.cellX, 3, "cell carried over")
eq(trailer.spriteId, "SPRITE_PIKACHU", "Gen 1's spriteId stamp is kept")
check(not trailer.fixedFacing, "STAY must not map to STILL: a trailer that "
  .. "cannot turn is not a follower")
eq(trailer.kind, "stand", "and it never wanders off on its own")
eq(type(trailer.pose), "function", "Gen 1's pose contract exists to be wrapped")

-- ------- 4. Collision, Boxes, the map vocabulary

local Collision = Gen2Compat.resolve("src.world.Collision", "fixture")
eq(Collision.DELTA, Gen2Map.DELTA, "one DELTA table, not a copy")
local tx, ty = Collision.target(2, 2, "right")
eq(tx, 3, "target x") eq(ty, 2, "target y")
trailer.passable = true
eq(Collision.occupied({ trailer }, 3, 4, nil), nil,
  "a passable entity never blocks a step")

local Boxes = Gen2Compat.resolve("src.pokemon.Boxes", "fixture")
local save = { currentBox = 2 }
local boxes = Boxes.ensure(save)
check(save.boxes ~= nil, "ensure MATERIALISES save.boxes, because Gen 1's "
  .. "callers index it straight afterwards")
eq(#boxes, require("src.core.gen2.Boxes").NUM_BOXES, "all of Gold's boxes")
eq(Boxes.active(save), save.boxes[2], "active is the current box")

-- COUNT / CAPACITY used to be missing outright, so `for i = 1, Boxes.COUNT`
-- raised "'for' limit must be a number"
eq(Boxes.COUNT, require("src.core.gen2.Boxes").NUM_BOXES, "Boxes.COUNT")
eq(Boxes.CAPACITY, require("src.core.gen2.Boxes").MONS_PER_BOX, "Boxes.CAPACITY")

-- the inherited Gen 2 deposit(save, partyIndex, boxIndex) would index
-- save.party with a MON TABLE, return false plus "There is no POKeMON there."
-- and drop the mon -- which reads exactly like "every box is full"
local mon = { species = "PIDGEY" }
eq(Boxes.deposit(save, mon), 2, "deposit takes a MON and answers a box number")
eq(save.boxes[2][1], mon, "and the mon is in the save, not in a detached table")

-- ensure clamps currentBox, which is load bearing: Boxes2.box hands back a
-- fresh DETACHED table for an index outside 1..NUM_BOXES
local wild = { currentBox = 99 }
local wildBoxes = Boxes.ensure(wild)
eq(wild.currentBox, Boxes.COUNT, "ensure clamps currentBox into range")
eq(Boxes.active(wild), wildBoxes[Boxes.COUNT], "so active is a box in the save")

eq(type(Gen2Map.isCounterCell), "function", "Map:isCounterCell exists")
eq(type(Gen2Map.warpAtCell), "function", "Map:warpAtCell exists")
check(Gen2Map.isOutside({ environment = "TOWN" }), "a town is outside")
check(not Gen2Map.isOutside({ environment = "INDOOR" }), "a house is not")
eq(type(Player.facingCell), "function", "Player:facingCell exists")

-- the Gen 1 module-level statics, which a facade could not have served
-- because a mod calls them on world.map
for _, name in ipairs({ "blockAt", "setBlock", "tileAt", "isDoorTileCell",
                        "isWarpTileCell", "signAtCell" }) do
  eq(type(Gen2Map[name]), "function", "Map:" .. name .. " exists")
end
check(Gen2Map.isOutdoor({ environment = "ROUTE" }), "a route is outdoor")
check(Gen2Map.inRegion({ id = "GOLDENROD_CITY" }, nil, "GOLDENROD"),
  "inRegion falls back to the id prefix, which is honest on either cache")
-- a sprite-name test would answer false for every real boulder on Gold
check(Gen2Map.isPushable({ movement = 0x19 }), "STRENGTH_BOULDER is pushable")
check(not Gen2Map.isPushable({ sprite = "SPRITE_BOULDER" }),
  "and the Gen 1 sprite name is not what decides it")
-- absent, not answered: Gold's fly points are landmark spawns and its ghost
-- battles are Kanto content
eq(Gen2Map.isFlyTown, nil, "Map.isFlyTown stays absent on Gold")
eq(Gen2Map.ghostBattles, nil, "Map.ghostBattles stays absent on Gold")

-- ------- 4b. FieldDefaults answers only what Gold genuinely shares

local FD = Gen2Compat.resolve("src.world.FieldDefaults", "fixture")
eq(FD.CONSTANTS.world.stepFrames, 16, "stepFrames is 16 on both generations")
eq(FD.CONSTANTS.world.turnFrames, 4, "and turnFrames is 4")
eq(FD.CONSTANTS.encounterBuckets, nil,
  "the Gen 1 wild-slot spread is Kanto and must not roll on Gold")
eq(FD.CONSTANTS.hmBadges, nil, "nor may Kanto's HM badge gates")
eq(FD.world(nil, "stepFrames"), 16, "world() answers the shared keys")
eq(FD.world(nil, "poisonStepInterval"), nil,
  "and refuses the ones Gold's StepEvents do not read from a table")
eq(FD.FIELD, nil, "FIELD is absent: every leaf of it is Kanto")
eq(FD.seed({}), nil, "seed never writes Kanto's field record into a Gold cache")
-- Gen 1's fieldValue is VARIADIC; a fixed arity dropped every deeper path
eq(FD.fieldValue(nil, "playerSprites", "walk"), World.PLAYER_SPRITE,
  "the one data.field path Gold can answer")
eq(FD.fieldValue(nil, "playerSprites"), nil,
  "and not the whole table, which a mod would index .surf on")

-- ------- 5. the follower's shouldSpawn upvalue, by name

local function upvalueIndex(fn, wanted)
  local i = 1
  while true do
    local name = debug.getupvalue(fn, i)
    if not name then return nil end
    if name == wanted then return i end
    i = i + 1
  end
end

local updateIdx = upvalueIndex(Follower.update, "shouldSpawn")
local enterIdx = upvalueIndex(Follower.onMapEntered, "shouldSpawn")
check(updateIdx ~= nil, "Follower.update closes over a local named shouldSpawn")
check(enterIdx ~= nil, "and so does Follower.onMapEntered")

-- the supported way in writes the SAME cell, so a mod that uses the setter and
-- one that rewrites the upvalue cannot end up with two different predicates
local sentinel = function() return false end
local restore = Follower.setShouldSpawn(sentinel)
eq(select(2, debug.getupvalue(Follower.update, updateIdx)), sentinel,
  "setShouldSpawn writes the upvalue debug.setupvalue would have")
Follower.setShouldSpawn(restore)

-- ------- 6. patch it and the follower spawns, trails and survives a rebuild

local function fixtureWorld()
  local game = { data = {}, save = { party = {} } }
  local world = World.new(game)
  world.maps = {
    TEST_MAP = { id = "TEST_MAP", group = 1, map = 2, width = 4, height = 4,
      blocks = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
      objects = {}, warps = {} },
  }
  -- every cell walkable: one block id whose whole quad is COLL_FLOOR
  local tileset = { collision = { [2] = { 0, 0, 0, 0 } } }
  world.map = Gen2Map.new(world.maps.TEST_MAP, tileset)
  world.sprites = { SPRITE_PIKACHU =
    { id = "SPRITE_PIKACHU", image = sheet, frames = 6, walker = true } }
  world.player = Player.new(4, 4, "down",
    { id = "SPRITE_CHRIS", image = sheet, frames = 6, walker = true })
  world.npcs, world.entities, world.ghosts = {}, { world.player }, {}
  return world, game
end

local world, game = fixtureWorld()
local always = function() return true end
debug.setupvalue(Follower.update, updateIdx, always)

-- the two closures share one upvalue cell under 5.1, which is what lets a mod
-- patch either one and suppress both -- assert it rather than assume it
eq(select(2, debug.getupvalue(Follower.onMapEntered, enterIdx)), always,
  "update and onMapEntered share the shouldSpawn cell")

Follower.onMapEntered(game, world, nil, true)
local npc = Follower.current(world)
check(npc ~= nil, "the follower spawns once shouldSpawn says yes")
check(npc.passable, "and never blocks the player")
eq(npc.cellX, 4, "parked on the player for a fresh map load")

-- Two committed steps right.  The first hands the follower the cell it is
-- already standing on (it spawned under the player), the second is the one it
-- has to walk -- and the goal is taken on the COMMIT, while targetX is still
-- set, not on the landing, which is what keeps the gap at one cell.
local function commit(tx)
  world.player.targetX, world.player.moving = tx, true
  Follower.update(game, world)
  world.player.cellX, world.player.targetX = tx, nil
  world.player.moving = false
end
commit(5)
commit(6)
eq(npc.goalX, 5, "the goal is the cell the player VACATED, one behind")
check(npc.moving, "and the follower took a step toward it")
eq(npc.targetX, 5, "one cell, in the right direction")
eq(npc.facing, "right", "facing the way it walks")

-- a seamless rebuild is what used to wipe a mod-inserted entity
world.map.def.objects = {}
world:rebuildPeople({ seamless = true })
check(Follower.current(world) ~= nil,
  "a guest survives rebuildPeople, so a follower does not vanish at the top "
  .. "of the hour")
eq(#world.npcs, 1, "and is listed exactly once")

-- ------- 7. World:step ticks it, World:interact dispatches through the facade

local ticked = 0
world.stepBody = function() end
local realUpdate = Follower.update
Follower.update = function() ticked = ticked + 1 end
world:step()
Follower.update = realUpdate
eq(ticked, 1, "World:step calls Follower.update after the body, which is the "
  .. "one per-frame driver every Gen 1 follower mod wraps")

local OC = Gen2Compat.resolve("src.world.OverworldController", "fixture")
world.interactBody = function() return "vanilla" end
eq(world:interact(), "vanilla", "with nothing patched, interact is the body")
local vanillaInteract = OC.interact
OC.interact = function(w) return "wrapped:" .. tostring(vanillaInteract(w)) end
eq(world:interact(), "wrapped:vanilla",
  "a replaced OverworldController.interact is what the A press dispatches to")
OC.interact = vanillaInteract

local owTicks = 0
local vanillaUpdate = OC.update
OC.update = function() owTicks = owTicks + 1 end
world:step()
OC.update = vanillaUpdate
eq(owTicks, 1, "and a replaced OverworldController.update ticks once a frame")

world:step()
eq(owTicks, 1, "restored, it costs one comparison and does not run")

-- talkTo is the other dispatch a follower mod wraps, and it used to be a warn
-- saying the wrapper would never run
local talked = nil
world.player.facing = "down"
world.player.cellX, world.player.cellY = 4, 4
local guest = Gen2Npc.new("TEST_MAP", { index = 9, x = 4, y = 5,
  movement = Gen2Npc.MOVE.STANDING_UP },
  { id = "SPRITE_CHRIS", image = sheet, frames = 6, walker = true })
table.insert(world.npcs, guest)
world.interactBody = nil
world.busy = function() return false end
world.vm = { lastTalked = 0, start = function() return true end,
              running = function() return false end }
local vanillaTalk = OC.talkTo
OC.talkTo = function(_w, npc) talked = npc return true end
eq(world:interactBody(), true, "a replaced talkTo intercepts the A press")
eq(talked, guest, "and receives the object Gold resolved")
OC.talkTo = vanillaTalk

-- ------- 8. the follower's three general members, which were nil calls

Follower.onMapEntered(game, world, nil, true)
local trailer = Follower.current(world)
check(trailer ~= nil, "a follower to hide")
eq(Follower.at(world, trailer.cellX, trailer.cellY), trailer,
  "Follower.at finds a standing follower, which is the interact hook's test")
trailer.moving = true
eq(Follower.at(world, trailer.cellX, trailer.cellY), nil,
  "and not a moving one, which is between two cells")
trailer.moving = false
local drawn = 0
for _, e in ipairs(world.entities) do if e == trailer then drawn = drawn + 1 end end
eq(drawn, 1, "it is on the draw list to begin with")
Follower.setVisible(world, false)
drawn = 0
for _, e in ipairs(world.entities) do if e == trailer then drawn = drawn + 1 end end
eq(drawn, 0, "setVisible(false) drops it from the DRAW list")
check(Follower.current(world) == trailer,
  "and leaves it in the UPDATE list, so it hides in place and keeps trailing")
Follower.setVisible(world, true)
Follower.setVisible(world, true)
drawn = 0
for _, e in ipairs(world.entities) do if e == trailer then drawn = drawn + 1 end end
eq(drawn, 1, "and re-adding is idempotent rather than doubling the entity")

-- the Gen 1 name for the trail, by reference: a reset through either name has
-- to move the live one
check(world.pikachuTrail == world.followerTrail,
  "ow.pikachuTrail and world.followerTrail are one table")

-- ------- 9. the NPC instance surface Gen 1 mods pose and draw through

local posed = { trailer:pose() }
eq(#posed, 7, "pose keeps Gen 1's seven-value contract")
eq(posed[4], trailer.facing, "facing is the fourth")
eq(type(Gen2Npc.marching), "nil", "marching is a FIELD, not a method")
-- Gen 2 saw moving with no targetX, sat still, then assigned cellX = nil and
-- every later read blew up a frame downstream
trailer.marching, trailer.progress, trailer.stepFrames = true, 0, 2
trailer.moving = false
local wasX, wasY = trailer.cellX, trailer.cellY
trailer:update(world.map, world.entities)
check(trailer.moving, "a marching NPC animates in place")
trailer:update(world.map, world.entities)
eq(trailer.cellX, wasX, "and never leaves its cell")
eq(trailer.cellY, wasY, "on either axis")
check(not trailer.marching, "the cycle ends itself after one step's frames")
trailer.stepFrames = nil

-- ------- 10. Collision.canMove answers what Gold's own player is told

-- the surf exception: without it the facade tells a surfing mod every water
-- cell is blocked, one line before Gold rides onto it.  0x20 is COLL_WATER's
-- row in Permissions' table.
local waterMap = Gen2Map.new(world.maps.TEST_MAP,
  { collision = { [2] = { 0x20, 0x20, 0x20, 0x20 } } })
local walker = { cellX = 1, cellY = 1 }
local surfer = { cellX = 1, cellY = 1, surfing = true }
eq(select(2, Collision.canMove(waterMap, {}, walker, "right")), "tile",
  "water refuses a walker")
check(Collision.canMove(waterMap, {}, surfer, "right"),
  "and carries a surfer, which map:isWalkableCell alone never says")

-- GetMovementPermissions' side-wall rule (Map:stepPermitted): a facade that
-- omits it says yes where Gold bumps, which is what ends an Ice Path slide
local stubMap = {
  inBounds = function() return true end,
  isWalkableCell = function() return true end,
  cellCollision = function() return 0 end,
  stepPermitted = function() return false end,
}
eq(select(2, Collision.canMove(stubMap, {}, walker, "up")), "tile",
  "and a step the neighbour's wall kind forbids is refused as 'tile'")

-- a mod's OWN movement.collision hook has to see its own canMove call
local Runtime = require("src.mods.Runtime")
local realHooks = Runtime.hooks
local seen = nil
Runtime.hooks = {
  chains = { ["movement.collision"] = true },
  call = function(_self, name, vanilla, allowed, ctx)
    if name ~= "movement.collision" then return vanilla(allowed, ctx) end
    seen = ctx
    return not allowed
  end,
}
check(Collision.canMove(waterMap, {}, walker, "right"),
  "the movement.collision chain runs inside the facade's canMove")
eq(seen and seen.reason, "tile", "with the ctx keys both generations use")
eq(seen and seen.toX, 2, "including the target cell")
Runtime.hooks = realHooks

eq(Collision.load({}), nil,
  "Collision.load is a NAMED no-op, never a silent accept: Gold has no "
  .. "tile-pair table for the mod's intent to land in")

-- ------- 11. ScriptRunner: the pure half forwards, the rest is a handle

local SR = Gen2Compat.resolve("src.script.ScriptRunner", "fixture")
eq(SR.scanLabels({ { "label", "top" }, { "wait", 1 } }).top, 1,
  "scanLabels is the real Gen 1 function, pure over the mod's own rows")
-- with Gen 1's default lookup a script of show_text / wait / warp validates
-- CLEAN on Gold and then every row is skipped at run time
liveGame.data.commands = { ["fixture:beep"] = {} }
eq(#SR.validate({ { "show_text", "x" } }), 1,
  "validate resolves against Gold's OWN command registry, so a Gen 1 built-in "
  .. "is reported rather than passed")
eq(#SR.validate({ { "fixture:beep" } }), 0, "and a registered mod verb passes")
eq(SR.new(nil, world).isRunning, SR.new(nil, world).isRunning,
  "the handle carries the query half of the one world.vm")
eq(SR.new(nil, world):resume(), nil, "resume is refused, not forwarded: the "
  .. "World already drives the VM and a second call dispatches twice")
eq(SR.new(nil, world):update(), nil,
  "and so is update, which would double-decrement every pause")

-- ow.runner, the field a mod guards on before acting.  nil there is FALSEY,
-- so a mod concludes NO SCRIPT IS RUNNING while one is.
check(world.runner ~= nil, "the World carries a runner shim")
eq(world.runner:isRunning(), world:scriptRunning(),
  "and answers the Gen 1 query")

-- ------- 12. a monkey-patch on a proxied class reads back as ITSELF
--
-- The write-through proxy answered its own override first, so
-- `PartyMenu.new = wrapper` read back as the facade's function (the patch was
-- invisible) and the override then called the class member the write had
-- already replaced -- straight back into the wrapper.

local Party2 = require("src.ui.gen2.PartyMenu")
local PM = Gen2Compat.resolve("src.ui.PartyMenu", "fixture")
local facadeNew = PM.new
local wrapped = 0
local wrapper = function(...) wrapped = wrapped + 1 return facadeNew(...) end
PM.new = wrapper
check(rawequal(PM.new, wrapper), "a mod's write to a proxied member reads "
  .. "back as the mod's own value, so the patch is visible")
check(rawequal(Party2.new, wrapper),
  "and still lands on the class Gold pushes")

liveGame.stack.top = function() return nil end
liveGame.stack.pop = function() end
local switched = nil
local pressed = {}
liveGame.input = { wasPressed = function(_, b) return pressed[b] end }
local pidgey = { species = "PIDGEY" }
local menu = PM.new(liveGame, { party = { pidgey },
                                onSwitch = function(mon) switched = mon end })
eq(wrapped, 1, "the wrapper ran exactly once: the override calls the "
  .. "constructor it CAPTURED, not the patched class member")
PM.new = nil
eq(PM.new, nil, "a nil write is honoured rather than resurrecting the override")
PM.new = facadeNew

-- Gen 1 fires onSwitch on A for this construction (src/ui/PartyMenu.lua:569);
-- Gold's field submenu swallowed the press and only CANCEL could ever answer.
check(not menu.wantsSubmenu, "onSwitch outside battle builds the DIRECT list")
pressed.a = true
menu:update(1 / 60)
eq(switched, pidgey, "and A on the row fires onSwitch with the mon")
liveGame.input = nil

-- the same shape on the battle screen, whose overrides are stamped onto Gold's
-- class so an instance answers them
local BS = Gen2Compat.resolve("src.battle.BattleState", "fixture")
local Battle2 = require("src.ui.gen2.BattleState")
local facadeSay = BS.say
local sayPatch = function(self, text) return facadeSay(self, text) end
BS.say = sayPatch
check(rawequal(BS.say, sayPatch), "BattleState.say reads back as the patch")
check(rawequal(Battle2.say, sayPatch), "and an instance dispatches to it")
BS.say = facadeSay

-- ------- 13. the overworld facade over a LIVE world

local ow = Gen2Compat.resolve("src.world.OverworldController", "fixture")
local owWorld = fixtureWorld()
owWorld.map.def.tileset = "TS"
owWorld.maps.OTHER_MAP = { id = "OTHER_MAP", group = 1, map = 3, width = 4,
  height = 4, blocks = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
  objects = {}, warps = {}, tileset = "TS" }
owWorld.tilesets = { TS = { collision = { [2] = { 0, 0, 0, 0 } } } }
-- Map copies def.connections at construction (src/world/gen2/Map.lua:26)
owWorld.map.connections = { west = { map = "OTHER_MAP", offset = 0 } }
liveGame.world = owWorld

-- objectId 0 is the PLAYER and 1 is wLastTalked (World:objectEntity): the old
-- `(def.index or 0) + 1` gave the player -- which has no .def -- objectId 1,
-- so the canonical Gen 1 call walked the last-talked NPC and returned true.
local talkNpc = Gen2Npc.new("TEST_MAP", { index = 1, x = 1, y = 1,
  movement = Gen2Npc.MOVE.STANDING_UP },
  { id = "SPRITE_CHRIS", image = sheet, frames = 6, walker = true })
table.insert(owWorld.npcs, talkNpc)
owWorld.talkNpc = talkNpc

check(ow.scriptMove(owWorld.player, "up", 1), "scriptMove takes the player")
eq(owWorld.moveState.objectId, 0, "as objectId 0, not the last-talked NPC")
owWorld.moveState = nil
check(ow.scriptMove(talkNpc, "up", 1), "and a mapped object")
eq(owWorld.moveState.objectId, 2, "as def.index + 1")
owWorld.moveState = nil
local moved, why = ow.scriptMove({ cellX = 1, cellY = 1 }, "up", 1)
eq(moved, nil, "an entity with neither is REFUSED, never moved by proxy")
check(type(why) == "string" and #why > 0, "with a reason")

eq(ow.npcByIndex(1), talkNpc, "npcByIndex maps the Gen 1 index to index + 1")
eq(ow.npcByIndex(0), nil, "and index 0 -- which names no object on either "
  .. "generation -- is nil, not Gold's wLastTalked")

-- Gen 1 returns dest DEF, tileset def, x, y, conn
-- (src/world/OverworldController.lua:1404); three values with a map ID first
-- shifted every name in `local dest, ts, x, y = ...`
eq(select("#", ow.connectionLanding("left")), 5,
  "connectionLanding keeps Gen 1's five-value shape")
local dest, ts, cx, cy, conn = ow.connectionLanding("left")
eq(type(dest), "table", "dest is the map DEF, so dest.width reads")
eq(dest.width, 4, "with the destination's own size")
check(Gen2Map.defPassable(dest, ts, cx, cy, false),
  "and the tileset def is the second value, which is what the very next "
  .. "Map.defPassable call takes")
eq(type(conn), "table", "the connection record is the fifth")

-- COVERAGE has to match what a read actually answers: these eight were
-- published backed and every one of them read nil
local owCoverage = Gen2Compat.coverage("src.world.OverworldController")
for member, status in pairs(owCoverage.members) do
  if status == "backed" then
    check(ow[member] ~= nil,
      "published backed and answers: OverworldController." .. member)
  end
end
eq(ow.player, owWorld.player, "ow.player is the live player, the way Gen 1's "
  .. "module IS the live state (src/core/Game.lua:87)")
eq(ow.map, owWorld.map, "and ow.map the live map")
eq(ow.npcs, owWorld.npcs, "and the lists are the world's own")
local swap = Player.new(1, 1, "down",
  { id = "SPRITE_CHRIS", image = sheet, frames = 6, walker = true })
ow.player = swap
eq(owWorld.player, swap, "a write to a live name moves the world, not a "
  .. "shadow copy on the facade")
ow.player = owWorld.player

-- Gold's neighbour rows carry `id`, Gen 1's carry `map`: answered, every
-- nb.map read is nil and a scan matches nothing
eq(ow.neighbors, nil, "neighbors answers nil rather than a list of the wrong "
  .. "shape")
eq(Gen2Compat.memberStatus("src.world.OverworldController", "neighbors"),
  "warned", "and coverage says so")
eq(Follower.shouldSpawn, nil, "Follower.shouldSpawn is a file-local")
eq(Gen2Compat.memberStatus("src.world.PikachuFollower", "shouldSpawn"),
  "absent", "so coverage publishes it absent, with setShouldSpawn as the way in")

-- leave the process as we found it: these tables are singletons
debug.setupvalue(Follower.update, updateIdx, function() return false end)

S.finish()
