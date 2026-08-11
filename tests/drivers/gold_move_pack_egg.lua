-- The three screens a test cannot see: MOVE POKéMON W/O MAIL, the PACK's item
-- submenu, and the EGG summary page.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_move_pack_egg.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-move-pack-egg   (default)
--
-- Each one is here because its bug was invisible to a green test:
--
--   * MOVE POKéMON W/O MAIL (_MovePKMNWithoutMail, engine/pokemon/bills_pc.asm)
--     used to move the mon the instant it was chosen, to a box the player
--     never named, with the confirmation string computed and dropped.  On
--     screen that is a PC that eats your Pokemon.  The shots walk the cart's
--     four steps and print the census at each one, so the mon is accounted for
--     in the log as well as on the screen.
--   * The PACK (engine/items/pack.asm .ItemBallsKey_LoadSubmenu) had no item
--     submenu at all, so USE was the only verb and a TOSS was unreachable.
--   * The EGG page (EggStatsScreen) draws menu_gfx.eggHatch.egg, and a cache
--     imported before the extractor learned EggPic has no such file -- so the
--     pic block was blank.  The shot proves the ICON_EGG fallback fills it.
local U = require("tests.drivers.util")

local BoxMenu = require("src.ui.gen2.BoxMenu")
local Boxes = require("src.core.gen2.Boxes")
local Mon = require("src.battle.gen2.Mon")
local PackMenu = require("src.ui.gen2.PackMenu")
local SummaryMenu = require("src.ui.gen2.SummaryMenu")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-move-pack-egg"

  local function shot(name)
    U.wait(3)
    U.shot(game, ("%s/%s.png"):format(out, name))
  end

  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")

  local save = game.save
  save.player.name = "GOLD"
  save.player.id = 12345

  local function build(species, level, fields)
    local mon = Mon.new(game.data, species, level,
      { dvs = { attack = 15, defense = 15, speed = 15, special = 15 } })
    assert(mon, "no base data for " .. species)
    mon.nickname = mon.name
    mon.otName = save.player.name
    mon.otId = save.player.id
    for key, value in pairs(fields or {}) do mon[key] = value end
    return mon
  end

  -- Every mon in the save, party and boxes together.  If this number ever
  -- changes across a move, the PC ate one.
  local function census()
    local n = #(save.party or {})
    for i = 1, Boxes.NUM_BOXES do n = n + Boxes.count(save, i) end
    return n
  end

  save.party = {
    build("CYNDAQUIL", 14),
    build("TOTODILE", 12),
    build("PIDGEY", 9),
  }
  local box = Boxes.box(save, 1)
  box[1] = build("SENTRET", 6)
  box[2] = build("HOOTHOOT", 7)
  box[3] = build("GEODUDE", 8)
  save.currentBox = 1

  local before = census()
  U.log(("[driver] %d mons before the move"):format(before))

  -- ---- 1. MOVE POKéMON W/O MAIL -----------------------------------------
  local move = BoxMenu.new(game, { save = save, mode = "move",
    onClose = function() end })
  game.stack:push(move)
  shot("00-move-choose")            -- "Choose a <PK><MN>."
  U.tap(game, "a")
  shot("01-move-submenu")           -- MOVE / STATS / CANCEL, "What's up?"
  U.tap(game, "a")
  shot("02-move-to-where")          -- the insert cursor, "Move to where?"
  assert(census() == before, "the mon left the save before it was placed")
  U.tap(game, "right")
  shot("03-move-destination-box2")  -- BOX2 named in the header
  U.tap(game, "a")
  shot("04-move-saving")            -- "Saving… Leave ON!"
  assert(census() == before, "a moved mon went missing")
  assert(Boxes.count(save, 2) == 1, "nothing landed in BOX2")
  U.tap(game, "a")
  U.tap(game, "left")
  U.tap(game, "left")
  shot("05-move-party-list")        -- box 0: the PARTY, which the old screen
                                    -- could not reach at all
  game.stack:pop()
  U.log(("[driver] %d mons after the move (BOX2 holds %d)")
    :format(census(), Boxes.count(save, 2)))

  -- ---- 2. the PACK's item submenu ---------------------------------------
  save.inventory = {
    POTION = 5, SUPER_POTION = 2, REPEL = 3, POKE_BALL = 10,
    BICYCLE = 1, ITEMFINDER = 1, HM_CUT = 1, TM_HEADBUTT = 1,
  }
  local pack = PackMenu.new(game, { save = save, onClose = function() end })
  -- Rows sort by ItemNames index, so SUPER POTION (17) is above POTION (18);
  -- park the cursor on the POTION by name rather than by position.
  for i, row in ipairs(pack.rows) do
    if row.id == "POTION" then pack.index = i end
  end
  game.stack:push(pack)
  shot("06-pack-items")
  U.tap(game, "a")
  shot("07-pack-submenu")           -- USE / GIVE / TOSS / QUIT
  U.tap(game, "down")
  U.tap(game, "down")
  shot("08-pack-submenu-toss")
  U.tap(game, "a")
  shot("09-pack-toss-how-many")     -- "Throw away how many?" + the counter
  U.tap(game, "up")
  U.tap(game, "up")
  shot("10-pack-toss-count")
  U.tap(game, "a")
  shot("11-pack-toss-confirm")      -- "Throw away 3 POTION(S)?" + YES/NO
  U.tap(game, "a")
  shot("12-pack-threw-away")        -- "Threw away POTION(S)."
  U.log(("[driver] POTIONs left: %s"):format(tostring(save.inventory.POTION)))
  assert((save.inventory.POTION or 0) == 2, "the TOSS did not spend three")
  game.stack:pop()

  -- ---- 3. the EGG summary page ------------------------------------------
  local egg = build("TOGEPI", 5, { isEgg = true, eggSteps = 20 })
  egg.nickname = "EGG"
  local summary = SummaryMenu.new(game, { mon = egg, save = save })
  local gfx = (game.data.gen2MenuGfx or {}).eggHatch
  U.log(("[driver] menu_gfx.eggHatch.egg = %s")
    :format(tostring(gfx and gfx.egg)))
  game.stack:push(summary)
  shot("13-egg-summary")
  game.stack:pop()

  print("[driver] PASS gold move/pack/egg shots in " .. out)
end
