-- The Gen 2 link surface, exercised against a REAL Gold boot.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_link_fingerprint.lua love .
--
-- Gold cannot link (docs/gen2-link-design.md is the honest account of what that
-- would take), so this is not a link smoke test.  It is the check that the
-- pieces which ARE built work against the extracted Gold dataset rather than
-- against a fixture:
--
--   1. the dataset identifies itself as generation 2 with no help from
--      GameVersion, and Handshake.hello says so on the wire
--   2. the Gen 2 fingerprint is stable, moves when a surface field moves, and
--      does NOT move when a non-surface field moves (the #511 lesson, checked
--      on Gold's own tables this time)
--   3. a Gold peer and a Red peer refuse each other by generation instead of
--      pairing and desyncing
--   4. every mon in a real Gold party survives packMon2 -> unpackMon2 with its
--      stats, experience, held item, happiness and derived shininess intact
--
-- A fixture test cannot say any of that, because the whole question is whether
-- the extracted tables and the engine agree.
local U = require("tests.drivers.util")

local Fingerprint = require("src.link.Fingerprint")
local Handshake = require("src.link.Handshake")
local Mon = require("src.battle.gen2.Mon")
local Protocol = require("src.link.Protocol")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-link"
  local failures = 0

  local function check(ok, label)
    if ok then
      U.log("ok  ", label)
    else
      failures = failures + 1
      U.log("FAIL", label)
    end
    return ok
  end

  U.wait(45)
  local data = game.data
  assert(data and data.pokemon and next(data.pokemon), "gold data did not load")

  -- ---- 1. generation, off the data alone

  check(Fingerprint.generationOf(data) == 2,
    "the Gold dataset reports itself as generation 2")
  local hello = Handshake.hello(game, "trade")
  check(hello.generation == 2, "the hello carries generation 2")
  check(type(hello.fingerprint) == "string" and #hello.fingerprint == 16,
    "the hello carries a 16-hex-digit Gen 2 fingerprint")
  U.log(("fingerprint %s  protocol %d  engine %s"):format(
    tostring(hello.fingerprint), hello.protocol, tostring(hello.engineVersion)))

  -- ---- 2. stability and coverage

  -- The baseline is recomputed with an EMPTY mod list, not taken from the
  -- hello.  Handshake.hello folds Handshake.mods(game) into the digest, and
  -- every comparison below computes with {}, so on an install with one enabled
  -- link-affecting mod the two differ by modKey alone -- which reads as "the
  -- digest is not stable" and "catchRate moved the digest" for a reason having
  -- nothing to do with the surface.  The hello's own digest is asserted above;
  -- from here on the baseline and the comparisons share a mod list.
  Fingerprint.forget(data)
  local base = Fingerprint.compute(data, {})
  Fingerprint.forget(data)
  check(Fingerprint.compute(data, {}) == base,
    "the digest is stable across a forget/recompute")

  -- The Gen 1 surface over the SAME tables must not collide with the Gen 2
  -- one: checkCompat refuses a cross-generation pairing by the hello, and the
  -- "[gen2]" tag is what makes the digest agree with that refusal.
  Fingerprint.forget(data)
  local asGen1 = Fingerprint.compute(data, {}, 1)
  Fingerprint.forget(data)
  check(asGen1 ~= base, "the Gen 1 and Gen 2 surfaces digest differently")

  local function digestAfter(mutate, restore)
    mutate()
    Fingerprint.forget(data)
    local value = Fingerprint.compute(data, {})
    restore()
    Fingerprint.forget(data)
    return value
  end

  -- surface: a base stat, a move's power, a move's effect chance, a held
  -- item's parameter, a growth curve coefficient.  Each one changes a battle
  -- turn or a trade rebuild, so each one must move the digest.
  local species = data.pokemon.TOTODILE or data.pokemon.CYNDAQUIL
  local before = species.baseStats.attack
  check(digestAfter(function() species.baseStats.attack = before + 1 end,
                    function() species.baseStats.attack = before end) ~= base,
    "a Gen 2 base stat moves the digest")

  local move = data.moves.TACKLE
  local movePower = move.power
  check(digestAfter(function() move.power = movePower + 1 end,
                    function() move.power = movePower end) ~= base,
    "a move's power moves the digest")

  local chanceMove, chanceBefore
  for _, id in ipairs({ "BODY_SLAM", "THUNDERBOLT", "ICE_BEAM" }) do
    if data.moves[id] and data.moves[id].effectChance then
      chanceMove, chanceBefore = data.moves[id], data.moves[id].effectChance
      break
    end
  end
  if chanceMove then
    check(digestAfter(function() chanceMove.effectChance = chanceBefore + 1 end,
                      function() chanceMove.effectChance = chanceBefore end) ~= base,
      "a move's effectChance moves the digest (Gen 2 only)")
  else
    U.log("skip  no move with an effectChance in this dataset")
  end

  local held = data.gen2HeldItems and data.gen2HeldItems.LEFTOVERS
  if held then
    local heldBefore = held.heldParameter
    check(digestAfter(function() held.heldParameter = (heldBefore or 0) + 1 end,
                      function() held.heldParameter = heldBefore end) ~= base,
      "a held item's parameter moves the digest")
  else
    U.log("skip  no LEFTOVERS held-item row in this dataset")
  end

  local curves = data.pokemon.growthRates
  local curve = curves and (curves.GROWTH_MEDIUM_SLOW or select(2, next(curves)))
  if curve then
    local linearBefore = curve.linear
    check(digestAfter(function() curve.linear = (linearBefore or 0) + 1 end,
                      function() curve.linear = linearBefore end) ~= base,
      "a growth-curve coefficient moves the digest")
  else
    U.log("skip  no growth-rate coefficient rows in this dataset")
  end

  -- NOT surface: catchRate (#511) and the constants index space.  Either one
  -- moving the digest would split two peers over something neither of their
  -- simulations reads.
  local catchBefore = species.catchRate
  check(digestAfter(function() species.catchRate = (catchBefore or 0) + 1 end,
                    function() species.catchRate = catchBefore end) == base,
    "catchRate does NOT move the digest")

  if data.gen2Constants and data.gen2Constants.mapOrder then
    local order = data.gen2Constants.mapOrder
    local first = order[1]
    check(digestAfter(function() order[1] = "NOT_A_MAP" end,
                      function() order[1] = first end) == base,
      "the constants index space does NOT move the digest")
  end

  -- the per-record digests a subset trade negotiates on
  local speciesRecords = Fingerprint.records(data, "pokemon")
  local heldRecords = Fingerprint.records(data, "held_items")
  check(speciesRecords.TOTODILE ~= nil and speciesRecords.growthRates == nil,
    "per-species digests cover the species and not the growthRates sibling")
  check(next(heldRecords) ~= nil, "per-held-item digests exist on Gold")

  -- ---- 3. a Gold peer refuses a Red peer

  local redHello = { type = "hello", protocol = hello.protocol,
                     name = "RED", generation = 1,
                     engineVersion = hello.engineVersion,
                     fingerprint = "0000000000000000", mods = {} }
  local verdict, reason = Handshake.checkCompat(hello, redHello)
  check(verdict == "refused" and reason == "generation_mismatch",
    "a Gold hello refuses a Gen 1 peer by generation")
  local oldHello = { type = "hello", name = "OLD" } -- pre-handshake build
  check(Handshake.checkCompat(hello, oldHello) == "refused",
    "a Gold hello refuses a pre-handshake build")
  local lines = Handshake.describe(hello, redHello, "refused", "trade")
  check(#lines > 0 and table.concat(lines, " "):find("generation"),
    "the incompatibility screen names the generation")
  for _, line in ipairs(lines) do U.log("  screen |" .. line) end

  -- ---- 4. a real Gold party through the Gen 2 codec

  local party = {}
  for _, spec in ipairs({ { "TOTODILE", 12 }, { "PIDGEY", 7 },
                          { "GEODUDE", 15 } }) do
    local mon = Mon.new(data, spec[1], spec[2])
    if mon then party[#party + 1] = mon end
  end
  check(#party == 3, "built a three-mon Gold party from the extracted tables")
  -- a held item and a status, so the two fields the Gen 1 codec cannot carry
  -- are actually under test
  party[1].item = (data.items and data.items.LEFTOVERS) and "LEFTOVERS" or nil
  party[1].status = "burn"
  party[1].happiness = 137
  party[1].pokerus = 0
  party[1].ot, party[1].otId = "KRIS", 41234
  party[2].hp = math.max(1, math.floor(party[2].maxHp / 2))

  for i, mon in ipairs(party) do
    local packed = Protocol.packMon2(mon)
    local rebuilt, why = Protocol.unpackMon2(data, packed, { strict = true })
    if not check(rebuilt ~= nil, ("slot %d rebuilds (%s)"):format(
        i, tostring(why))) then break end
    check(rebuilt.species == mon.species and rebuilt.level == mon.level,
      ("slot %d keeps species and level"):format(i))
    check(rebuilt.experience == mon.experience,
      ("slot %d keeps experience (%s vs %s)"):format(
        i, tostring(rebuilt.experience), tostring(mon.experience)))
    check(rebuilt.hp == mon.hp and rebuilt.maxHp == mon.maxHp,
      ("slot %d keeps HP %s/%s"):format(i, tostring(rebuilt.hp),
                                        tostring(rebuilt.maxHp)))
    local same = true
    for _, k in ipairs({ "hp", "attack", "defense", "speed",
                         "specialAttack", "specialDefense" }) do
      if rebuilt.stats[k] ~= mon.stats[k] then same = false end
    end
    check(same, ("slot %d recomputes all six stats identically"):format(i))
    check(rebuilt.shiny == mon.shiny and rebuilt.gender == mon.gender,
      ("slot %d re-derives shininess and gender from the DVs"):format(i))
    check(#rebuilt.moves == #mon.moves, ("slot %d keeps its moveset"):format(i))
    check(rebuilt.item == mon.item, ("slot %d keeps its held item (%s)"):format(
      i, tostring(rebuilt.item)))
    check(rebuilt.status == mon.status, ("slot %d keeps its status"):format(i))
    check(rebuilt.happiness == mon.happiness,
      ("slot %d keeps its happiness"):format(i))
    check(rebuilt.otId == mon.otId and rebuilt.ot == mon.ot,
      ("slot %d keeps its original trainer"):format(i))
  end

  -- the HP DV is derived, never sent: a packet that claims one is ignored
  local tampered = Protocol.packMon2(party[1])
  tampered.dvs.hp = 15
  local rebuilt = Protocol.unpackMon2(data, tampered, { strict = true })
  check(rebuilt and rebuilt.dvs.hp == Mon.hpDV(party[1].dvs),
    "a claimed HP DV is ignored and re-derived from the other four")

  -- an item the peer's game does not have is refused rather than carried
  local noSuchItem = Protocol.packMon2(party[1])
  noSuchItem.item = "MOON_FLUTE"
  local _, itemWhy = Protocol.unpackMon2(data, noSuchItem, { strict = true })
  check(itemWhy == "unknown item",
    "an unknown held item is refused in strict mode")

  -- and the subset filter says so BEFORE the mon is ever sent
  local mine = { pokemon = Fingerprint.records(data, "pokemon"),
                 moves = Fingerprint.records(data, "moves"),
                 heldItems = Fingerprint.records(data, "held_items") }
  local theirs = { pokemon = mine.pokemon, moves = mine.moves, heldItems = {} }
  local eligible, reasons = Protocol.eligibleParty(party, mine, theirs)
  check(eligible[1] == false and reasons[1] == "unknown item",
    "the subset filter greys a mon whose held item the peer lacks")
  check(eligible[2] == true, "a mon holding nothing stays tradeable")

  -- ---- proof the game was actually up while all of that ran

  U.shot(game, out .. "/01-gold-link-fingerprint.png")
  U.log(("%d failures"):format(failures))
  assert(failures == 0, ("gold link fingerprint driver: %d failures"):format(
    failures))
  U.log("PASS")
end
