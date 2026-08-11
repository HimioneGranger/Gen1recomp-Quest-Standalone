-- Assertion driver: SURF and WHIRLPOOL, done the way a player does them, on
-- real Gold maps.  It PASSES or it errors.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev \
--     POKEPORT_DRIVER=tests/drivers/gold_water_moves.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-water   (default)
--
-- tests/gen2_world_test.lua checks the pure halves (FieldMoves' badge gate,
-- the tile tests, the block replacement tables).  What it cannot check is the
-- part that is all wiring: that walking into the sea puts you ON it, that the
-- player sprite becomes the Lapras, that a whirlpool block really leaves the
-- map's block buffer, and that the water behind it is passable afterwards.
--
-- Both routes IN are driven, because they are different code on the cart and
-- were different code here: TrySurfOW / TryWhirlpoolOW (walk into it, answer
-- the prompt) runs on the spot through CallScript, and the PACK / party-menu
-- route queues a script that only runs once the menus are gone.
local U = require("tests.drivers.util")

local FieldMoves = require("src.world.gen2.FieldMoves")
local Permissions = require("src.world.gen2.Permissions")
local Mon = require("src.battle.gen2.Mon")

-- Cells read out of the cache rather than remembered: Cherrygrove's beach is
-- the first stretch of sea a player can reach, and Route 41's whirlpools are
-- the ones between Olivine and Cianwood.
local BEACH = { map = "CHERRYGROVE_CITY", x = 10, y = 9 }   -- faces water below
local WHIRL = { map = "ROUTE_41", x = 22, y = 11 }          -- faces (22,12)

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-water"

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 6)
  end

  -- Answer whatever text box or yes/no the field move puts up, until the world
  -- is idle again.  A field move is a script, so `busy` is the honest "is it
  -- still going" and mashing A is what a player does.
  local function settle(limit)
    for _ = 1, (limit or 60) do
      if not world:busy() and not world.fieldMove then return true end
      tap("a", 4)
    end
    return not world:busy() and not world.fieldMove
  end

  -- SURF is FOGBADGE, WHIRLPOOL is GLACIERBADGE (FieldMoves.BADGE).  Give
  -- both, so what is under test is the move and not the gate -- the gate has
  -- its own checks in gen2_world_test.
  local badges = game.save.player.badges or {}
  game.save.player.badges = badges
  for _, badge in pairs(FieldMoves.BADGE) do badges[badge] = true end
  assert(FieldMoves.hasBadge(game.save, FieldMoves.BADGE.SURF), "FOGBADGE")
  assert(FieldMoves.hasBadge(game.save, FieldMoves.BADGE.WHIRLPOOL), "GLACIER")

  local swimmer = Mon.new(game.data, "LAPRAS", 30,
    { moves = { { id = "SURF" }, { id = "WHIRLPOOL" } } })
  assert(swimmer, "could not build a LAPRAS")
  game.save.party = { swimmer }

  -- ---- SURF, by walking into the sea -------------------------------------
  do
    world:setMap(BEACH.map, BEACH.x, BEACH.y, "down")
    U.wait(10)
    local ctx = world:fieldContext()
    assert(Permissions.isWater(ctx.facingColl),
      ("%s (%d,%d) is not facing water any more -- re-import moved the beach")
        :format(BEACH.map, BEACH.x, BEACH.y))
    assert(not FieldMoves.isSurfing(world.playerState), "not surfing yet")
    U.shot(game, out .. "/00-beach.png")

    assert(world:trySurfOW(), "TrySurfOW refused a water tile with the badge")
    assert(settle(), "the surf script never finished")
    assert(FieldMoves.isSurfing(world.playerState),
      "SURF ran and the player is still on foot")
    assert(world.player.cellY > BEACH.y,
      ("the player did not step onto the water: still at (%d,%d)")
        :format(world.player.cellX, world.player.cellY))
    local coll = world.map:cellCollision(world.player.cellX, world.player.cellY)
    assert(Permissions.isWater(coll),
      "the player is surfing on something that is not water")
    U.shot(game, out .. "/01-surfing.png")

    -- And it is a real state, not a one-step animation: walk further out.
    local fromY = world.player.cellY
    U.hold(game, "down", 40)
    U.wait(20)
    assert(world.player.cellY > fromY,
      "the player cannot swim once surfing")
    assert(FieldMoves.isSurfing(world.playerState),
      "the surf state did not survive a step")
    U.log(("SURF: walked into the sea at (%d,%d) and swam to (%d,%d)")
      :format(BEACH.x, BEACH.y, world.player.cellX, world.player.cellY))
  end

  -- ---- WHIRLPOOL, from the party menu ------------------------------------
  do
    -- Route 41 is open sea, so the player arrives already surfing -- which is
    -- what the cart does too (wPlayerState survives the warp).
    world:applyPlayerState(FieldMoves.PLAYER_SURF)
    world:setMap(WHIRL.map, WHIRL.x, WHIRL.y, "down")
    U.wait(10)
    local def = world.maps[WHIRL.map]
    local ctx = world:fieldContext()
    assert(Permissions.isWhirlpool(ctx.facingColl),
      ("%s (%d,%d) is not facing a whirlpool"):format(
        WHIRL.map, WHIRL.x, WHIRL.y))
    local index = ctx.facingBlockIndex
    local before = def.blocks[index]
    local replacement = select(1, FieldMoves.blockReplacement(
      FieldMoves.WHIRLPOOL_BLOCKS, ctx.tileset, ctx.facingBlock))
    assert(replacement,
      "no WhirlpoolBlockPointers row for this tileset/block pair")
    assert(before ~= replacement, "the whirlpool is already cleared")
    U.shot(game, out .. "/02-whirlpool.png")

    -- The party-menu route: the result is QUEUED and only runs once the menus
    -- are gone, which is the half that is easy to wire up wrong.
    local result = world:useFieldMove("WHIRLPOOL", game.save.party[1])
    assert(result and result.ok,
      "the party menu refused WHIRLPOOL: " .. tostring(result and result.text))
    assert(world.queuedFieldMove, "and it ran on the spot instead of queueing")
    assert(world:runQueuedFieldMove(), "the queued move did not start")
    assert(settle(), "the whirlpool script never finished")

    assert(def.blocks[index] == replacement,
      ("the whirlpool block did not change: %s, want %s")
        :format(tostring(def.blocks[index]), tostring(replacement)))
    local after = world.map:cellCollision(ctx.facingX, ctx.facingY)
    assert(not Permissions.isWhirlpool(after),
      "the block changed but the cell is still a whirlpool")
    assert(Permissions.isWalkable(after) or Permissions.isWater(after),
      "the cleared whirlpool is not passable")
    U.shot(game, out .. "/03-whirlpool-cleared.png")

    -- Swim through it, which is the whole point of clearing one.
    U.hold(game, "down", 40)
    U.wait(20)
    assert(world.player.cellY >= ctx.facingY,
      ("the player could not swim through the cleared whirlpool: (%d,%d)")
        :format(world.player.cellX, world.player.cellY))
    U.log(("WHIRLPOOL: block %d %s -> %s on %s, and the player swam through")
      :format(index, tostring(before), tostring(replacement), WHIRL.map))

    -- LoadMapAttributes refills the block buffer from ROM: a whirlpool is back
    -- the next time you sail in, exactly like a cut tree.
    world:setMap("NEW_BARK_TOWN", 13, 6, "down")
    U.wait(5)
    world:applyPlayerState(FieldMoves.PLAYER_SURF)
    world:setMap(WHIRL.map, WHIRL.x, WHIRL.y, "down")
    U.wait(5)
    assert(def.blocks[index] == before,
      "the whirlpool did not come back after a map load")
    U.log("and it is back on the next map load, the way the cart refills it")
  end

  U.log("PASS gold_water_moves in " .. out)
  love.event.quit()
end
