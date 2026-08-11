-- Screenshots of the mon SUMMARY (engine/pokemon/stats_screen.asm), which is
-- the one thing tests/gen2_summary_test.lua cannot check: it asserts every
-- hlcoord, but not whether the three pages read like Gold's.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_summary_shots.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-summary   (default)
--
-- Boots into the world (Game2 skips the cinema under POKEPORT_DRIVER),
-- builds a party through the ONE Gen 2 builder so the mons actually have
-- stats, moves, PP and experience, then puts each page up.
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")
local PartyMenu = require("src.ui.gen2.PartyMenu")
local SummaryMenu = require("src.ui.gen2.SummaryMenu")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-summary"

  local function shot(name)
    U.wait(3)
    U.shot(game, ("%s/%s.png"):format(out, name))
  end

  local function show(name, state)
    game.stack:push(state)
    shot(name)
    game.stack:pop()
  end

  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")

  local save = game.save
  save.player.name = "GOLD"
  save.player.id = 12345

  -- Mon.new is the only party-member builder: anything routed through Gen 1's
  -- Pokemon.new comes back with no moves at all, because a Gen 2 moveset is
  -- `levelMoves` and Gen 1 reads level1Moves / learnset.
  local function build(species, level, opts)
    opts = opts or {}
    local mon = Mon.new(game.data, species, level, {
      dvs = { attack = 15, defense = 15, speed = 15, special = 15 },
    })
    assert(mon, "no base data for " .. species)
    mon.nickname = opts.nickname or mon.name
    mon.otName = save.player.name
    mon.otId = save.player.id
    for key, value in pairs(opts.fields or {}) do mon[key] = value end
    -- Spend some PP so the PP columns are not four identical pairs, and take
    -- a bite out of the HP so the bar is not always full green.
    for i, move in ipairs(mon.moves or {}) do
      move.pp = math.max(0, (move.maxPp or move.pp) - i * 3)
    end
    return mon
  end

  save.party = {
    -- A held item, a status, and a dual-typed third mon so the pink page shows
    -- both type rows.
    build("CYNDAQUIL", 22, { fields = { item = "BERRY" } }),
    build("TOTODILE", 18, { fields = { status = "psn" } }),
    build("GASTLY", 15, {}),
  }
  save.party[1].hp = math.floor(save.party[1].maxHp * 0.4)
  save.party[2].hp = math.floor(save.party[2].maxHp * 0.15)
  -- Part way to the next level, so the exp bar is not empty or full.
  local growth = game.data.pokemon.growthRates
  local function partWay(mon)
    local def = game.data.pokemon[mon.species]
    local rate = growth and def and growth[def.growthRate]
    if not rate then return end
    local base = Mon.experienceForLevel(rate, mon.level)
    local next_ = Mon.experienceForLevel(rate, mon.level + 1)
    mon.experience = base + math.floor((next_ - base) * 0.6)
  end
  for _, mon in ipairs(save.party) do partWay(mon) end

  -- The party list the summary is opened from, and the action submenu STATS
  -- lives in (engine/pokemon/mon_submenu.asm).
  local party = PartyMenu.new(game, { prompt = "choose", submenu = true })
  show("00-party", party)
  party:openSubmenu()
  show("01-mon-submenu", party)
  party:closeSubmenu()

  -- The three pages, in the order .d_right walks them.
  local function page(n)
    local screen = SummaryMenu.new(game, {
      party = save.party, index = 1, save = save, page = n,
    })
    return screen
  end
  show("02-pink-page", page(SummaryMenu.PINK_PAGE))
  show("03-green-page", page(SummaryMenu.GREEN_PAGE))
  show("04-blue-page", page(SummaryMenu.BLUE_PAGE))

  -- ...and the same three for the poisoned mon, whose HP bar is red and whose
  -- status line is not OK.
  local hurt = SummaryMenu.new(game, {
    party = save.party, index = 2, save = save,
  })
  show("05-pink-page-poisoned", hurt)
  hurt.page = SummaryMenu.BLUE_PAGE
  show("06-blue-page-second-mon", hurt)

  -- The dual-typed mon, for the second TYPE row.
  local ghost = SummaryMenu.new(game, {
    party = save.party, index = 3, save = save,
  })
  show("07-pink-page-dual-type", ghost)

  -- PlaceMoveData's screen, which is where the cart shows a move description.
  local detail = SummaryMenu.new(game, {
    party = save.party, index = 1, save = save,
    page = SummaryMenu.GREEN_PAGE,
  })
  detail.moveDetail = true
  show("08-move-description", detail)
  detail.moveIndex = 2
  show("09-move-description-second", detail)

  print("[driver] PASS gold summary shots in " .. out)
end
