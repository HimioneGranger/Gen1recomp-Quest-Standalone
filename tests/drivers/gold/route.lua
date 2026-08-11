-- Gold route: New Bark Town through the Olivine Gym (asm-walk sections 00-09).
--
-- Hand-authored from docs/gold-walkthrough/asm-walk/section-NN-*.md.  Every row
-- carries the section and checklist step it came from in `id`, so a stall names
-- a paragraph a human can go read.
--
-- Why this is not generated from the markdown.  The plan was a converter over
-- each section's "## 4. Bot checklist" table, on the botconv principle that the
-- docs stay the source of truth.  Seven of these ten sections write that
-- checklist as free prose ("walk west along y=11..13", "grind to the
-- walkthrough's level 8", "avoid the three trainers") rather than the template's
-- six-column table, and the Intent column has no controlled vocabulary anywhere
-- -- so a parser would have been a prose-guesser wearing a converter's clothes,
-- and normalising 300 rows of prose into tables by hand is strictly more work
-- than writing the Lua those tables would have produced.  The anti-drift job the
-- converter was for is done better by tests/gold_route_validate_test.lua, which
-- checks every coordinate below against the extracted cache: a warp that is not
-- at (6,3), an object that moved, a map that does not exist and an EVENT_* that
-- is not a real flag name all fail in seconds, which is more than a markdown
-- parser could ever have caught.
--
-- Scope: the REQUIRED spine only.  Optional pickups, phone numbers, the Ruins of
-- Alph, the Bug Contest and the day-of-week NPCs are left out of this first
-- pass; each one is a place the bot can stall for no progression benefit.  Rows
-- marked `optional = true` may fail without failing the run.
--
-- Ops:
--   travel   be on this map, however the map graph gets there
--   walk     stand on this cell (trip-wires and coord events)
--   warp     walk onto this warp cell, expect to arrive on `to`
--   edge     cross this map connection, expect to arrive on `to`
--   talk     stand adjacent, face it, press A, answer `answers` in order
--   battle   as `talk`/`walk`, then fight whatever starts
--   grind    fight wilds here until the party's lowest level reaches `level`
--   heal     talk to this map's Pokecenter nurse
--   teach    teach a move from an HM to an eligible party mon
--   field    use a field move against this cell
--   catch    hunt this map's wild encounters until one of `species` is caught
--   manual   not implemented; log it, record it, carry on

return {

  -- =========================================================================
  -- Section 00 : the bedroom through the starter
  -- =========================================================================
  -- NEW GAME, InitClock and NamePlayer have no rows here on purpose.  A
  -- POKEPORT_DRIVER run without POKEPORT_BOOT_CINEMA boots straight into the
  -- world (src/core/Game2.lua:load), so the bot starts already stood
  -- in the bedroom with none of the three ever on screen.  With the cinema on
  -- they are driven instead by tests/drivers/gold_boot_smoke.lua.

  { id = "00.5",  map = "PLAYERS_HOUSE_2F", op = "warp", x = 7, y = 0,
    to = "PLAYERS_HOUSE_1F" },

  -- MeetMomScript fires on the scene-0 load and runs ~1300 frames of text with
  -- a yes/no pair inside it.  The section's step 6a is explicit that answering
  -- the DST question is not enough: the confirm loops back to .SetDayOfWeek on
  -- "no", so both answers have to be yes.
  { id = "00.6",  map = "PLAYERS_HOUSE_1F", op = "settle",
    answers = { "yes", "yes" }, budget = 4000 },

  { id = "00.7",  map = "PLAYERS_HOUSE_1F", op = "warp", x = 6, y = 7,
    to = "NEW_BARK_TOWN" },
  { id = "00.9",  map = "NEW_BARK_TOWN", op = "warp", x = 6, y = 3,
    to = "ELMS_LAB" },

  -- Scene 0 auto-walks the player to (4,2) and talks; nothing to drive but the
  -- text.
  { id = "00.10", map = "ELMS_LAB", op = "settle", budget = 3000 },

  -- Starter.  Cyndaquil at (6,3): section 09's own battle notes say to bring a
  -- Fire or Fighting lead for Jasmine, and Fire also answers Bugsy's Scyther in
  -- section 04.  Answers are yes (take it) then no (skip the nickname screen --
  -- the naming keyboard has no cancel, only END, so it is far cheaper never to
  -- open it: src/ui/gen2/NamingScreen.lua:236).
  { id = "00.11", map = "ELMS_LAB", op = "talk", x = 6, y = 3,
    answers = { "yes", "no" }, expect = "EVENT_GOT_A_POKEMON_FROM_ELM" },

  { id = "00.12", map = "ELMS_LAB", op = "walk", x = 4, y = 8 },
  { id = "00.14", map = "ELMS_LAB", op = "warp", x = 4, y = 11,
    to = "NEW_BARK_TOWN" },
  { id = "00.15", map = "NEW_BARK_TOWN", op = "edge", dir = "west",
    to = "ROUTE_29" },

  -- =========================================================================
  -- Section 01 : Cherrygrove, Mr Pokemon, the egg, and north to Violet
  -- =========================================================================

  -- The starter is level 5 and Falkner is four maps away.  The walkthrough
  -- grinds Route 29 to 8 before Cherrygrove; do the same, because every later
  -- gate in this section is a scripted battle we cannot decline.
  { id = "01.5",  map = "ROUTE_29", op = "grind", level = 8 },
  { id = "01.6",  map = "ROUTE_29", op = "edge", dir = "west",
    to = "CHERRYGROVE_CITY" },

  -- The guide gent's tour is a long follow/stopfollow cutscene.  It is not a
  -- progression gate, but he walks up and starts it unprompted, so it is
  -- cheaper to run it deliberately than to be ambushed mid-path later.
  { id = "01.7",  map = "CHERRYGROVE_CITY", op = "talk", x = 32, y = 6,
    answers = { "yes" }, optional = true, budget = 6000 },
  { id = "01.8",  map = "CHERRYGROVE_CITY", op = "heal", optional = true },

  { id = "01.9",  map = "CHERRYGROVE_CITY", op = "edge", dir = "up",
    to = "ROUTE_30" },
  { id = "01.12", map = "ROUTE_30", op = "warp", x = 17, y = 5,
    to = "MR_POKEMONS_HOUSE" },

  -- The scene fires on load: egg, Pokedex, the blackout point moves to
  -- Cherrygrove, and SPECIALCALL_ROBBED is armed.
  { id = "01.13", map = "MR_POKEMONS_HOUSE", op = "settle", budget = 5000,
    expect = "EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON" },
  { id = "01.14", map = "MR_POKEMONS_HOUSE", op = "warp", x = 2, y = 7,
    to = "ROUTE_30" },

  -- Elm's call lands a few overworld steps after leaving; `settle` after the
  -- travel below picks it up wherever it fires.
  { id = "01.15", map = "CHERRYGROVE_CITY", op = "travel" },
  { id = "01.15b", map = "CHERRYGROVE_CITY", op = "settle", budget = 2000,
    optional = true },
  { id = "01.16", map = "CHERRYGROVE_CITY", op = "battle", x = 33, y = 6,
    note = "rival scene trip-wire on row 6/7 at x=33" },

  { id = "01.18", map = "ELMS_LAB", op = "travel" },
  { id = "01.18b", map = "ELMS_LAB", op = "walk", x = 4, y = 5,
    note = "SCENE_ELMSLAB_MEET_OFFICER trip-wire; CopScript names the rival" },
  { id = "01.18c", map = "ELMS_LAB", op = "settle", budget = 4000 },
  { id = "01.19", map = "ELMS_LAB", op = "talk", x = 5, y = 2,
    answers = { "yes" }, expect = "EVENT_GAVE_MYSTERY_EGG_TO_ELM" },
  { id = "01.20", map = "ELMS_LAB", op = "walk", x = 4, y = 8,
    note = "aide's five POKE BALLs" },

  -- Route 30's north blockers come down with the egg handed over, so the run
  -- north to Violet is only now possible.  The trainers on the way (Joey,
  -- Mikey, Don, Wade) are walked into rather than sought: the route is
  -- geography and the sight lines do the rest.
  { id = "01.25", map = "ROUTE_30", op = "travel" },
  { id = "01.26", map = "ROUTE_31", op = "travel" },
  { id = "01.30", map = "VIOLET_CITY", op = "travel" },

  -- =========================================================================
  -- Section 02 : Sprout Tower and Falkner
  -- =========================================================================
  -- Sprout Tower is optional for the badge but is where HM05 FLASH lives, and
  -- the rival fight on 3F is a scene trip-wire that will otherwise ambush a
  -- later pass through.  Kept, but the sages are left to their sight lines.

  { id = "02.1",  map = "SPROUT_TOWER_1F", op = "travel", optional = true },
  { id = "02.15", map = "SPROUT_TOWER_3F", op = "travel", optional = true },
  { id = "02.15b", map = "SPROUT_TOWER_3F", op = "walk", x = 11, y = 9,
    optional = true, note = "rival encounter coord event, scene 0" },
  { id = "02.16", map = "SPROUT_TOWER_3F", op = "talk", x = 10, y = 2,
    optional = true, expect = "EVENT_GOT_HM05_FLASH" },

  -- Grind before each gym.  The route used to carry exactly one grind row (the
  -- opening Route 29 one) and fought every leader at whatever level the walking
  -- happened to produce -- which is why runs stalled with a level-10 lead and
  -- two badges.  The badges are load bearing far beyond the badge count: FOG
  -- gates SURF and PLAIN gates STRENGTH, so losing Morty or Whitney means the
  -- HMs never work and Cianwood is never reached.
  { id = "02.g",  map = "ROUTE_31", op = "grind", level = 14, lead = true },
  { id = "02.19", map = "VIOLET_CITY", op = "travel" },
  { id = "02.20", map = "VIOLET_CITY", op = "heal" },
  { id = "02.22", map = "VIOLET_GYM", op = "travel" },

  -- Falkner at (5,1).  Abe and Rod are in the way of the walk up and engage on
  -- their own; the badge script force-sets their flags either way.
  { id = "02.26", map = "VIOLET_GYM", op = "battle", x = 5, y = 1, talk = true,
    expect = "ENGINE_ZEPHYRBADGE",
    retryFrom = "02.20", retryLimit = 4 },

  -- The Togepi Egg, and it is not a side quest: it is what OPENS ROUTE 32.
  --
  -- Route 32's only road south runs through (18,8), which carries a coord
  -- event at scene 0 -- the Miracle Seed man, who follows you, walks you two
  -- cells back north and hands you nothing you need (maps/Route32.asm
  -- Route32CooltrainerMStopsYouScene).  Nothing in that script changes the
  -- scene.  The one thing in the game that does is Elm's aide, three maps
  -- away: giving you the egg runs `setmapscene ROUTE_32,
  -- SCENE_ROUTE32_OFFER_SLOWPOKETAIL` (maps/VioletPokecenter1F.asm), and only
  -- then does the road open.  The map is a soft gate and the egg is the key.
  --
  -- Without these three rows the bot walked into that scene, was pushed back,
  -- re-planned the identical path and was pushed back again -- so Azalea, Ilex
  -- Forest, Goldenrod and everything past them were reachable only by
  -- teleport, which is most of what the run's shortcut count was.
  --
  -- The aide only appears once Elm has phoned: Falkner's badge script arms
  -- `specialphonecall SPECIALCALL_ASSISTANT` (maps/VioletGym.asm), the call
  -- lands outdoors after a few steps, and its script clears
  -- EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER, which is what un-hides him.
  --
  -- The wander row waits on a flag being CLEARED rather than set, which is why
  -- it carries `expectClear` instead of `expect`: an object_event's event flag
  -- HIDES the object when set (CheckObjectFlag), so the aide appears the moment
  -- the call clears his.
  { id = "02.26b", map = "VIOLET_CITY", op = "wander", budget = 40,
    expectClear = "EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER", optional = true,
    note = "walk outdoors until Elm's SPECIALCALL_ASSISTANT lands" },
  { id = "02.26c", map = "VIOLET_POKECENTER_1F", op = "travel" },
  { id = "02.26d", map = "VIOLET_POKECENTER_1F", op = "talk", x = 4, y = 3,
    answers = { "yes" }, budget = 6000,
    expect = "EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE" },

  -- =========================================================================
  -- Section 03 : Route 32, Union Cave, Route 33
  -- =========================================================================
  -- The Ruins of Alph detour (steps 4-14) is skipped: the Unown puzzle needs
  -- `special UnownPuzzle` driven through a sliding-tile UI, and nothing past it
  -- gates progress to Azalea.

  { id = "03.16", map = "ROUTE_32", op = "travel" },
  { id = "03.28", map = "ROUTE_32_POKECENTER_1F", op = "travel",
    optional = true },
  { id = "03.28b", map = "ROUTE_32_POKECENTER_1F", op = "heal",
    optional = true },
  { id = "03.29", map = "UNION_CAVE_1F", op = "travel" },
  { id = "03.36", map = "ROUTE_33", op = "travel" },
  { id = "03.39", map = "AZALEA_TOWN", op = "travel" },

  -- =========================================================================
  -- Section 04 : Slowpoke Well and Bugsy
  -- =========================================================================
  -- Slowpoke Well is a hard gate, not a side quest: clearing it is what sets
  -- AZALEA_TOWN's scene to SCENE_AZALEATOWN_RIVAL_BATTLE, and Ilex Forest --
  -- the only way west -- is behind that scene's coord event.

  { id = "04.3",  map = "KURTS_HOUSE", op = "travel" },
  { id = "04.3b", map = "KURTS_HOUSE", op = "talk", x = 3, y = 2,
    expect = "EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET" },
  { id = "04.5",  map = "AZALEA_POKECENTER_1F", op = "travel", optional = true },
  { id = "04.5b", map = "AZALEA_POKECENTER_1F", op = "heal", optional = true },

  -- Balls before the well.  Elm's aide gives five in the whole game, and the
  -- SLOWPOKE below is not optional: it is the only SURF user available before
  -- FOGBADGE opens water hunting, so five failed throws cost Cianwood, the
  -- Storm Badge and everything after it.  A run that came this far has
  -- thousands of yen and nothing else to spend it on.  Count is sized for this
  -- catch plus the later POLIWAG and bird hunts (07.g0 / 07.30).
  { id = "04.5c", map = "AZALEA_MART", op = "buy", item = "POKE_BALL",
    count = 40 },
  -- Potions, for the same reason the balls are bought: the bot has thousands
  -- of yen and nothing else to spend it on, and until now it walked into every
  -- gym leader with no way to answer damage except more levels.  Bot:fightBattle
  -- drinks the strongest thing in the bag when the lead drops below a third.
  { id = "04.5d", map = "AZALEA_MART", op = "buy", item = "SUPER_POTION",
    count = 10, optional = true },

  { id = "04.6",  map = "SLOWPOKE_WELL_B1F", op = "travel" },

  -- Catch a SLOWPOKE while we are down here.  Not in the walkthrough, and the
  -- run cannot finish without it: SURF is required to reach Cianwood in section
  -- 08, and the Cyndaquil line cannot learn it (its tmhm list has CUT,
  -- STRENGTH and ROCK_SMASH but no SURF or FLY).  SLOWPOKE is in this map's own
  -- grass table and learns SURF *and* STRENGTH -- but NOT WHIRLPOOL or
  -- WATERFALL, which is why 07.30 catches a POLIWAG once the pond opens.
  { id = "04.6b", map = "SLOWPOKE_WELL_B1F", op = "catch",
    species = { "SLOWPOKE" }, ball = "POKE_BALL" },
  -- The three grunts are sight-line fights on the way north and west; the last
  -- one at (5,2) runs the whole clear-out cutscene with no endifjustbattled,
  -- ending in HealParty and a warp to Kurt's house.
  { id = "04.8",  map = "SLOWPOKE_WELL_B1F", op = "battle", x = 15, y = 8 },
  { id = "04.9",  map = "SLOWPOKE_WELL_B1F", op = "battle", x = 13, y = 3 },
  { id = "04.11", map = "SLOWPOKE_WELL_B1F", op = "battle", x = 6, y = 6 },
  { id = "04.13", map = "SLOWPOKE_WELL_B1F", op = "battle", x = 5, y = 3,
    budget = 8000, expect = "EVENT_CLEARED_SLOWPOKE_WELL" },

  { id = "04.14", map = "KURTS_HOUSE", op = "talk", x = 3, y = 2,
    answers = { "no" }, optional = true,
    note = "LURE_BALL, then decline the apricorn prompt" },

  { id = "04.g",  map = "UNION_CAVE_1F", op = "grind", level = 19, lead = true },
  { id = "04.17", map = "AZALEA_GYM", op = "travel" },
  { id = "04.22", map = "AZALEA_GYM", op = "battle", x = 5, y = 7, talk = true,
    expect = "ENGINE_HIVEBADGE",
    retryFrom = "04.17", retryLimit = 4 },

  -- =========================================================================
  -- Section 05 : Ilex Forest, CUT, and Whitney
  -- =========================================================================

  { id = "05.1",  map = "AZALEA_TOWN", op = "travel" },
  { id = "05.1b", map = "AZALEA_TOWN", op = "battle", x = 5, y = 10,
    note = "SCENE_AZALEATOWN_RIVAL_BATTLE trip-wire" },
  -- Enter the forest from AZALEA, not from Route 34.
  --
  -- Ilex Forest is two regions with no walk between them until the tree at
  -- (8,25) is cut, and the whole of section 05 -- the Farfetch'd herd, the
  -- man who hands over HM01, the tree itself -- is in the southern one.  A
  -- plain `travel ILEX_FOREST` is satisfied by either, and the planner
  -- naturally picked the northern gate: the bot arrived in the forest, on the
  -- correct map, with every remaining objective behind a tree it needed CUT to
  -- remove and CUT behind the tree.  Naming the gate is what pins the side.
  { id = "05.2b", map = "ILEX_FOREST_AZALEA_GATE", op = "travel" },
  { id = "05.3",  map = "ILEX_FOREST", op = "travel" },

  -- The Farfetch'd herd.  Nine talks, each moving the bird to the next spot.
  --
  -- Every FarfetchdPositionN script (bar the first) scalls
  -- FarfetchdCryAndCheckFacing, so the direction the PLAYER is facing decides
  -- whether the bird goes onwards or doubles back round the loop.  `facings`
  -- lists the directions that advance it, taken straight from the section-05
  -- branch table; approaching from whichever side happens to be nearest herds
  -- in circles forever.
  --
  --   Pos2 -> Pos3, except DOWN -> Pos8
  --   Pos3 -> Pos4, except LEFT -> Pos2
  --   Pos4 -> Pos5, except UP -> Pos3
  --   Pos5 -> Pos6, except LEFT -> Pos7, UP/RIGHT -> Pos4
  --   Pos6 -> Pos7, except RIGHT -> Pos5
  --   Pos7 -> Pos8, except LEFT -> Pos6, DOWN -> Pos5
  --   Pos8 -> Pos9, except RIGHT -> Pos7, UP/LEFT -> Pos2
  --   Pos9 -> Pos10 (terminal), except RIGHT/DOWN -> Pos8
  { id = "05.5",  map = "ILEX_FOREST", op = "talk", x = 14, y = 31,
    note = "Pos1: no facing check, always advances" },
  { id = "05.6b", map = "ILEX_FOREST", op = "talk", x = 15, y = 25,
    facings = { "up", "left", "right" } },
  { id = "05.6c", map = "ILEX_FOREST", op = "talk", x = 20, y = 24,
    facings = { "up", "down", "right" } },
  { id = "05.6d", map = "ILEX_FOREST", op = "talk", x = 29, y = 22,
    facings = { "down", "left", "right" } },
  { id = "05.6e", map = "ILEX_FOREST", op = "talk", x = 28, y = 31,
    facings = { "down" } },
  { id = "05.6f", map = "ILEX_FOREST", op = "talk", x = 24, y = 35,
    facings = { "up", "down", "left" } },
  { id = "05.6g", map = "ILEX_FOREST", op = "talk", x = 22, y = 31,
    facings = { "up", "right" } },
  { id = "05.6h", map = "ILEX_FOREST", op = "talk", x = 15, y = 29,
    facings = { "down" } },
  { id = "05.6i", map = "ILEX_FOREST", op = "talk", x = 10, y = 35,
    facings = { "up", "left" }, expect = "EVENT_HERDED_FARFETCHD" },

  { id = "05.8",  map = "ILEX_FOREST", op = "talk", x = 5, y = 28,
    expect = "EVENT_GOT_HM01_CUT" },
  { id = "05.9",  map = "ILEX_FOREST", op = "teach", move = "CUT" },
  -- The tree itself is at (8,25); section 05 step 10 writes (8,24), which is
  -- the cell you STAND on to face it (verified against the cache: (8,24) is
  -- plain floor, (8,25) is COLL_CUT_TREE $12).  A field move targets the tile,
  -- so the route names the tree.
  { id = "05.10", map = "ILEX_FOREST", op = "field", move = "CUT", x = 8, y = 25,
    note = "opens the path north; block (4,12) becomes $17" },

  { id = "05.13", map = "ROUTE_34", op = "travel" },
  { id = "05.24", map = "GOLDENROD_CITY", op = "travel" },
  { id = "05.25", map = "GOLDENROD_CITY", op = "heal" },
  -- Two grinds before Whitney, and both are load bearing.
  --
  -- The lead one is obvious: MILTANK is the wall of the first half of the game
  -- and the bot fights with no items and a "hit it with the strongest move"
  -- policy, so it needs the levels the walkthrough's player would have.
  --
  -- The party one is what was missing.  The bot fought every gym with one
  -- Pokemon and a level-7 SLOWPOKE behind it, so the moment the lead fainted
  -- the run was over -- and the SLOWPOKE is not a spare, it is the only mon
  -- that can learn SURF before water hunting opens, so it has to survive as
  -- far as Cianwood either way.  `lead = false` grinds the party MINIMUM,
  -- which is what drags it up.
  { id = "05.g",  map = "ROUTE_34", op = "grind", level = 20, lead = false,
    wipeBudget = 6 },
  { id = "05.g2", map = "ROUTE_34", op = "grind", level = 30, lead = true },
  -- Re-enter Goldenrod from ROUTE_34 specifically.  Its north edge is a direct
  -- connection and the flood fill confirms reachable border cells (x=8..11);
  -- the alternative the planner keeps finding -- Violet -> Route 36 -> Route 35
  -- -- ends at Route 35's SOUTH gate, whose warp is not reachable from the
  -- north border you arrive on, so the bot ping-pongs instead of arriving.
  { id = "05.24b", map = "ROUTE_34", op = "travel" },
  -- Heal between the grind and the leader.  Whitney's MILTANK is the wall of
  -- the first half of the game and the grind that precedes her ends with the
  -- party wherever the wild encounters left it; a run that walks in at half HP
  -- wins the fight and then blacks out on the way to the badge talk, which
  -- costs PLAINBADGE -- and PLAINBADGE gates STRENGTH, the Squirtbottle,
  -- Sudowoodo and ROCK SMASH behind it.
  { id = "05.38", map = "GOLDENROD_CITY", op = "heal" },
  { id = "05.39", map = "GOLDENROD_GYM", op = "travel" },
  { id = "05.44", map = "GOLDENROD_GYM", op = "battle", x = 8, y = 3, talk = true,
    expect = "EVENT_BEAT_WHITNEY" },
  -- Whitney cries afterwards and blocks the door until the trip-wire at (8,5)
  -- runs WhitneyCriesScript; only then does a second talk hand over the badge.
  { id = "05.45", map = "GOLDENROD_GYM", op = "walk", x = 8, y = 5 },
  { id = "05.46", map = "GOLDENROD_GYM", op = "talk", x = 8, y = 3,
    expect = "ENGINE_PLAINBADGE",
    retryFrom = "05.38", retryLimit = 4 },

  { id = "05.46b", map = "ROUTE_34", op = "travel", optional = true },
  { id = "05.47", map = "GOLDENROD_FLOWER_SHOP", op = "travel" },
  { id = "05.47b", map = "GOLDENROD_FLOWER_SHOP", op = "talk", x = 2, y = 4,
    expect = "EVENT_GOT_SQUIRTBOTTLE" },

  -- =========================================================================
  -- Section 06 : Sudowoodo and ROCK SMASH
  -- =========================================================================
  -- Sudowoodo is a hard gate: it stands on the Route 36 tile that leads east to
  -- Violet and north to Ecruteak, and TM08 ROCK SMASH (needed for the Burned
  -- Tower in section 07) is behind having fought it.

  { id = "06.15", map = "ROUTE_36", op = "travel" },
  { id = "06.20", map = "ROUTE_36", op = "battle", x = 35, y = 9, talk = true,
    answers = { "yes" }, expect = "EVENT_FOUGHT_SUDOWOODO" },
  { id = "06.21", map = "ROUTE_36", op = "talk", x = 44, y = 9,
    expect = "EVENT_GOT_TM08_ROCK_SMASH" },
  -- ROCK SMASH is a TM, not an HM, so nothing teaches it as a side effect of
  -- picking it up -- and the Burned Tower's north half is behind a rock.  The
  -- route had the TM and no `teach` row, so `07.20 field ROCK_SMASH` skipped
  -- with "no party mon knows ROCK_SMASH", the beasts were never released and
  -- Morty was fought without them.
  { id = "06.21b", map = "ROUTE_36", op = "teach", move = "ROCK_SMASH" },

  -- =========================================================================
  -- Section 07 : Ecruteak, SURF, the beasts, and Morty
  -- =========================================================================

  { id = "07.6",  map = "ECRUTEAK_CITY", op = "travel" },
  { id = "07.7",  map = "ECRUTEAK_POKECENTER_1F", op = "travel" },
  { id = "07.7b", map = "ECRUTEAK_POKECENTER_1F", op = "settle", budget = 5000,
    note = "Bill / Time Capsule scene fires on load" },
  { id = "07.7c", map = "ECRUTEAK_POKECENTER_1F", op = "heal" },

  -- The five Kimono Girls all have sight 0 and will not start a fight
  -- themselves, so each is an explicit talk.
  { id = "07.12", map = "DANCE_THEATER", op = "travel" },
  { id = "07.13a", map = "DANCE_THEATER", op = "battle", x = 0,  y = 2, talk = true },
  { id = "07.13b", map = "DANCE_THEATER", op = "battle", x = 2,  y = 1, talk = true },
  { id = "07.13c", map = "DANCE_THEATER", op = "battle", x = 6,  y = 2, talk = true },
  { id = "07.13d", map = "DANCE_THEATER", op = "battle", x = 9,  y = 1, talk = true },
  { id = "07.13e", map = "DANCE_THEATER", op = "battle", x = 11, y = 2, talk = true },
  { id = "07.14", map = "DANCE_THEATER", op = "talk", x = 7, y = 10,
    expect = "EVENT_GOT_HM03_SURF" },
  { id = "07.14b", map = "DANCE_THEATER", op = "teach", move = "SURF" },
  -- ops.teach walks the party for the first mon whose tmhm list contains the
  -- move, so the SLOWPOKE caught in section 04 is what picks this up.

  -- Grind and heal BEFORE the tower, not after it.
  --
  -- The Burned Tower is a pit maze whose lower floor has six regions, four of
  -- them one-way pockets, and the bot can and does get stuck in one.  With the
  -- grind and the heal sitting on the far side of it, a tower that went wrong
  -- took Morty with it -- the badge fight was reached at whatever level and
  -- whatever HP the tower left behind, and FOGBADGE gates SURF and everything
  -- after.  Nothing in the tower gates the gym, so it is now a detour that may
  -- fail on its own.
  -- Morty is the hardest fight in Johto for this party.  His GASTLY line is
  -- Ghost/Poison: the starter's Normal moves cannot touch it at all and its
  -- Fire is resisted, so the whole gym is carried by the SLOWPOKE's SURF --
  -- which means the SLOWPOKE has to be a real Pokemon by now, not the level-20
  -- HM caddy it is when it arrives.  Both grinds, and the higher lead target,
  -- are what the fight costs.
  -- A FLY user before the party grind.  Cyndaquil/SLOWPOKE/TOGEPI none of
  -- them learn FLY (TOGETIC would, but the egg never sees a Shiny Stone on
  -- this route).  ROUTE_37's grass is PIDGEY / HOOTHOOT / PIDGEOTTO; catching
  -- here costs no detour and the party-minimum grind that follows levels it.
  { id = "07.g0", map = "ROUTE_37", op = "catch",
    species = { "PIDGEY", "PIDGEOTTO", "HOOTHOOT", "NOCTOWL" },
    ball = "POKE_BALL" },
  { id = "07.g",  map = "ROUTE_37", op = "grind", level = 28, lead = false,
    wipeBudget = 6 },
  { id = "07.g2", map = "ROUTE_37", op = "grind", level = 36, lead = true },

  { id = "07.18", map = "BURNED_TOWER_1F", op = "travel", optional = true },
  -- The rival scene fires on entry, before anything can be driven.
  { id = "07.19", map = "BURNED_TOWER_1F", op = "settle", budget = 8000,
    optional = true },
  -- A smashable rock is an OBJECT, not a tile.  `BURNEDTOWER1F_ROCK1` at (4,3)
  -- is a SPRITEMOVEDATA_SMASHABLE_ROCK whose script is `jumpstd
  -- SmashRockScript` -> `AskRockSmashScript`, so it is TALKED to and answered
  -- YES; World:useFieldMove reads the faced TILE and quite correctly refuses
  -- ("Can't use that here"), which is what the `field` row used to fail with.
  -- No badge is required for ROCK SMASH, only a party mon that knows it.
  { id = "07.20", map = "BURNED_TOWER_1F", op = "talk", x = 4, y = 3,
    answers = { "yes" }, budget = 4000, optional = true,
    note = "opens the north half" },
  { id = "07.21", map = "BURNED_TOWER_1F", op = "battle", x = 8, y = 1,
    optional = true },
  -- Fall through the CENTRE pit (1F warp 9 -> B1F warp 3, landing (10,8)).
  -- The beasts' plateau is its own region and only that landing is on it; a
  -- plain travel used to take the nearest pit, land at (3,3), and leave (9,5)
  -- unreachable.  Getting OUT afterwards is the hop-down ledges to the ladder
  -- at (7,15), which the planner walks now that ledge hops exist.
  { id = "07.22", map = "BURNED_TOWER_1F", op = "warp", x = 10, y = 7,
    to = "BURNED_TOWER_B1F", optional = true },
  { id = "07.23", map = "BURNED_TOWER_B1F", op = "walk", x = 9, y = 5,
    expect = "EVENT_RELEASED_THE_BEASTS", budget = 8000, optional = true },

  -- Walk into the gym healed.  Morty's GASTLY line is immune to the starter's
  -- Normal moves and resists its Fire, so the fight is carried by the SLOWPOKE
  -- and its SURF -- and a SLOWPOKE that arrives at half HP loses to the gym
  -- trainers before the leader is reached.
  { id = "07.26", map = "ECRUTEAK_MART", op = "buy", item = "HYPER_POTION",
    count = 10, optional = true },
  { id = "07.27", map = "ECRUTEAK_CITY", op = "heal" },
  { id = "07.28", map = "ECRUTEAK_GYM", op = "travel" },
  { id = "07.29", map = "ECRUTEAK_GYM", op = "battle", x = 5, y = 1, talk = true,
    expect = "ENGINE_FOGBADGE",
    retryFrom = "07.27", retryLimit = 4 },

  -- WHIRLPOOL / WATERFALL mule.  SLOWPOKE can learn SURF and STRENGTH but its
  -- tmhm list has neither WHIRLPOOL nor WATERFALL -- that is why 11.34b and
  -- 13.10b used to report "no party mon can learn …".  ECRUTEAK_CITY's water
  -- table is POLIWAG / POLIWHIRL only (no grass table at all), FOGBADGE just
  -- opened the pond, and SURF is already taught, so this is a zero-detour
  -- water hunt.  POLIWHIRL also picks up STRENGTH on evolution.
  { id = "07.30", map = "ECRUTEAK_CITY", op = "catch",
    species = { "POLIWAG", "POLIWHIRL" }, ball = "POKE_BALL", water = true },

  -- =========================================================================
  -- Section 08 : Olivine, STRENGTH, the lighthouse, Cianwood, Chuck
  -- =========================================================================

  { id = "08.17", map = "OLIVINE_CITY", op = "travel" },
  { id = "08.18", map = "OLIVINE_CITY", op = "walk", x = 13, y = 12,
    note = "rival scene trip-wire, scene 0" },
  { id = "08.20", map = "OLIVINE_CITY", op = "heal" },
  { id = "08.21", map = "OLIVINE_CAFE", op = "travel" },
  { id = "08.21b", map = "OLIVINE_CAFE", op = "talk", x = 4, y = 3,
    expect = "EVENT_GOT_HM04_STRENGTH" },
  { id = "08.22", map = "OLIVINE_CAFE", op = "teach", move = "STRENGTH" },

  -- Up the lighthouse to Jasmine.  Her explanation is what unlocks the Cianwood
  -- pharmacy, so this visit is required even though nothing here is a fight.
  { id = "08.43", map = "OLIVINE_LIGHTHOUSE_6F", op = "travel" },
  { id = "08.43b", map = "OLIVINE_LIGHTHOUSE_6F", op = "talk", x = 8, y = 8,
    expect = "EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS" },

  { id = "08.50", map = "ROUTE_40", op = "travel" },
  -- Start surfing.  The SLOWPOKE caught in section 04 is the SURF user (the
  -- Cyndaquil line cannot learn it).  (8,8) is water with walkable land at
  -- (8,7), so approachAndFace stands on the beach facing the sea and
  -- World:useFieldMove does the rest.
  { id = "08.51", map = "ROUTE_40", op = "field", move = "SURF", x = 8, y = 8 },
  { id = "08.57", map = "CIANWOOD_CITY", op = "travel" },
  { id = "08.60", map = "CIANWOOD_PHARMACY", op = "travel" },
  { id = "08.60b", map = "CIANWOOD_PHARMACY", op = "talk", x = 2, y = 3,
    expect = "EVENT_GOT_SECRETPOTION_FROM_PHARMACY" },

  -- Chuck's POLIWRATH and PRIMEAPE are the second wall of Johto, and the bot
  -- reaches him having fought four Blackbelts and shoved three boulders on the
  -- way in.  With the lane finally open (rows 08.65a-c) the fight itself became
  -- the blocker, so it gets the same treatment Morty did: bring the whole party
  -- up, then top the lead off, then walk in healed.
  { id = "08.g",  map = "ROUTE_41", op = "grind", level = 32, lead = false,
    wipeBudget = 6 },
  { id = "08.g2", map = "ROUTE_41", op = "grind", level = 40, lead = true },
  { id = "08.61", map = "CIANWOOD_CITY", op = "heal" },
  { id = "08.62", map = "CIANWOOD_GYM", op = "travel" },
  { id = "08.63a", map = "CIANWOOD_GYM", op = "battle", x = 2, y = 12 },
  { id = "08.63b", map = "CIANWOOD_GYM", op = "battle", x = 7, y = 12 },
  { id = "08.64", map = "CIANWOOD_GYM", op = "battle", x = 3, y = 9 },
  -- The boulder lane is the only way to the back of the gym.
  -- The boulder row at y=7 (BOULDER2/3/4 at x=3/4/5) is the only way to the
  -- back of the gym, and it is what STRENGTH is for -- the walkthrough's "use
  -- Strength to push your way to the last trainer before the gym leader".
  -- Shoving the middle one north opens the lane behind it.  This was a
  -- `manual` row that logged and moved on, which meant Chuck was fought from
  -- the wrong side of a rock and STORMBADGE was never earned.
  -- The boulder puzzle, solved sideways.
  --
  -- Row 7 (boulders at x=3/4/5) is the only link between the gym's halves:
  -- rows 6-7 are x=3..5, row 5 narrows to (4,5) and (5,5), Blackbelt Lung
  -- stands on (5,5) and does not leave it, and (4,3) is solid wall.  So
  -- shoving the middle boulder NORTH can never work -- it stays in the one
  -- column the player needs, and its furthest cell (4,4) blocks the last step
  -- into row 4.  Every count from 2 to 6 was tried and every end state is
  -- blocked.
  --
  -- The way through is to empty the row instead of climbing it: push the two
  -- OUTER boulders north (each frees its own cell in row 7 and parks itself in
  -- a dead-end pocket of row 6), then stand where the right-hand one was and
  -- push the middle boulder WEST into the gap the left-hand one left.  Row 7's
  -- middle cell is then clear and the column above it is untouched.
  --
  -- A push does not move the player -- the cart treats a strength boulder like
  -- a solid NPC -- so each of these costs a pair of presses: one to shove the
  -- rock, one to step into the cell it left.  `ops.push` waits for the rock to
  -- stop sliding between presses, because World:tryPushBoulder refuses while
  -- `npc.moving`.
  { id = "08.65a", map = "CIANWOOD_GYM", op = "push", x = 3, y = 7,
    dir = "up", count = 2, note = "left boulder to (3,6); frees (3,7)" },
  { id = "08.65b", map = "CIANWOOD_GYM", op = "push", x = 5, y = 7,
    dir = "up", count = 2, note = "right boulder to (5,6); frees (5,7)" },
  { id = "08.65c", map = "CIANWOOD_GYM", op = "push", x = 4, y = 7,
    dir = "left", count = 2,
    note = "middle boulder west into (3,7); the lane north is now open" },
  { id = "08.66", map = "CIANWOOD_GYM", op = "battle", x = 5, y = 5,
    talk = true, budget = 8000 },
  { id = "08.68", map = "CIANWOOD_GYM", op = "battle", x = 4, y = 1, talk = true,
    expect = "ENGINE_STORMBADGE",
    retryFrom = "08.61", retryLimit = 4,
    -- Rewind OUTSIDE the gym, not to 08.66 one row up.
    --
    -- Chuck sits behind a STRENGTH boulder puzzle, and a puzzle left in a bad
    -- state cannot be retried in place: run 25 pushed the boulders into a
    -- arrangement that sealed the north half, and both 08.66 and 08.68 then answered
    -- "approach: nowhere to stand" instantly -- burning all four laps in a
    -- single frame without ever moving. World:setMap calls restoreBlocks,
    -- which refills the map from ROM, so LEAVING and re-entering is what puts
    -- the boulders back. 08.61 is the Cianwood heal, one map outside the door.
    },
  -- FLY is an optimisation, never a gate: section 09 opens by flying back to
  -- Olivine and travelTo can simply swim the way it came.  Optional so a miss
  -- here cannot cost the badge chain behind it.  The bird from 07.g0 is who
  -- learns it.
  { id = "08.70", map = "CIANWOOD_CITY", op = "talk", x = 10, y = 46,
    optional = true, expect = "EVENT_GOT_HM02_FLY" },
  { id = "08.70b", map = "CIANWOOD_CITY", op = "teach", move = "FLY",
    optional = true },

  -- =========================================================================
  -- Section 09 : back to Olivine, cure Amphy, and Jasmine
  -- =========================================================================
  -- The section opens by flying, which the bot does not need: travelTo can swim
  -- back the way it came.  Flying is strictly an optimisation here.

  { id = "09.14", map = "OLIVINE_LIGHTHOUSE_6F", op = "travel" },
  { id = "09.15", map = "OLIVINE_LIGHTHOUSE_6F", op = "talk", x = 8, y = 8,
    answers = { "yes" }, budget = 6000,
    expect = "EVENT_JASMINE_RETURNED_TO_GYM" },

  { id = "09.17", map = "OLIVINE_CITY", op = "travel" },
  { id = "09.17b", map = "OLIVINE_CITY", op = "heal" },
  { id = "09.g",  map = "ROUTE_39", op = "grind", level = 38, lead = true },
  { id = "09.18", map = "OLIVINE_GYM", op = "travel" },
  { id = "09.20", map = "OLIVINE_GYM", op = "battle", x = 5, y = 3, talk = true,
    budget = 12000, expect = "EVENT_BEAT_JASMINE" },
  { id = "09.21", map = "OLIVINE_GYM", op = "check", expect = "ENGINE_MINERALBADGE" },

  -- =========================================================================
  -- Section 10 : Route 42, Mahogany, Route 43, the Lake of Rage
  -- =========================================================================
  -- No badge here.  What the section is FOR is EVENT_DECIDED_TO_HELP_LANCE,
  -- which arms SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS and is the only way
  -- into the Rocket base -- and therefore the only way to HM06 WHIRLPOOL.

  { id = "10.1",  map = "ECRUTEAK_CITY", op = "travel" },
  { id = "10.3",  map = "ROUTE_42", op = "travel" },
  -- Route 42's two lakes sit across the road east.  The bot surfs on its own
  -- now (Bot:stepDir starts the field move when a planned step enters water),
  -- so this is a plain travel row.
  { id = "10.13", map = "MAHOGANY_TOWN", op = "travel" },
  { id = "10.14", map = "MAHOGANY_TOWN", op = "heal" },
  { id = "10.18", map = "ROUTE_43", op = "travel" },
  { id = "10.26", map = "LAKE_OF_RAGE", op = "travel" },
  { id = "10.g",  map = "ROUTE_43", op = "grind", level = 40, lead = true },

  -- The Red Gyarados.  Its script is `loadwildmon GYARADOS, 30` with
  -- BATTLETYPE_FORCESHINY, so this is a wild fight the bot may simply win; the
  -- RED_SCALE and Lance's appearance are set on a KO as well as a catch.
  { id = "10.33", map = "LAKE_OF_RAGE", op = "battle", x = 18, y = 22,
    talk = true, budget = 12000,
    expect = "EVENT_LAKE_OF_RAGE_RED_GYARADOS" },
  { id = "10.34", map = "LAKE_OF_RAGE", op = "talk", x = 21, y = 28,
    answers = { "yes" }, budget = 8000,
    expect = "EVENT_DECIDED_TO_HELP_LANCE" },

  -- =========================================================================
  -- Section 11 : the Rocket hideout and Pryce
  -- =========================================================================

  { id = "11.2",  map = "MAHOGANY_MART_1F", op = "travel" },
  { id = "11.2b", map = "MAHOGANY_MART_1F", op = "settle", budget = 8000,
    expect = "EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART",
    note = "LanceUncoversStaircaseScript runs unattended on arrival" },

  { id = "11.3",  map = "TEAM_ROCKET_BASE_B1F", op = "travel" },
  -- The security cameras are sight-line scripts on the way west; each is the
  -- same pair of grunts and the bot fights them where it meets them.  The
  -- switch that ends them is a bg event read from (19,12) facing UP.
  { id = "11.10", map = "TEAM_ROCKET_BASE_B1F", op = "talk", x = 19, y = 11,
    facings = { "up" }, budget = 6000,
    expect = "EVENT_TURNED_OFF_SECURITY_CAMERAS" },

  { id = "11.12", map = "TEAM_ROCKET_BASE_B2F", op = "travel" },
  { id = "11.13", map = "TEAM_ROCKET_BASE_B2F", op = "walk", x = 5, y = 14,
    note = "Lance heals the party here; scene 0 -> 1" },
  { id = "11.15", map = "TEAM_ROCKET_BASE_B3F", op = "travel" },
  { id = "11.15b", map = "TEAM_ROCKET_BASE_B3F", op = "settle", budget = 6000,
    expect = "EVENT_TEAM_ROCKET_BASE_B3F_LANCE_PASSWORDS" },
  -- Both passwords are learned by talking: the sight-0 grunt at (21,7) has to
  -- be spoken to TWICE (the first talk is the battle), and the spinning grunt
  -- at (5,15) the same.
  -- Both battle rows carry the trainer's own beat flag: the fight fires on a
  -- sight line DURING the approach, the trainer then stands wherever it
  -- happened, and the approach's own opinion of reaching the (now moved)
  -- object is worthless -- run 3 recorded a FAIL on a fight it had won.
  { id = "11.18", map = "TEAM_ROCKET_BASE_B3F", op = "battle", x = 21, y = 7,
    talk = true, budget = 8000, expect = "EVENT_BEAT_ROCKET_GRUNTF_5" },
  { id = "11.18b", map = "TEAM_ROCKET_BASE_B3F", op = "talk", x = 21, y = 7,
    expect = "EVENT_LEARNED_SLOWPOKETAIL" },
  { id = "11.20", map = "TEAM_ROCKET_BASE_B3F", op = "battle", x = 5, y = 15,
    talk = true, budget = 8000, expect = "EVENT_BEAT_ROCKET_GRUNTM_28" },
  { id = "11.20b", map = "TEAM_ROCKET_BASE_B3F", op = "talk", x = 5, y = 15,
    expect = "EVENT_LEARNED_RATICATE_TAIL" },
  -- Region 1, and only NOW: the two passwords above are learned from grunts at
  -- (21,7) and (5,15), which are in region 3. Pinning region 1 before them put
  -- the bot on the wrong side of a floor it could not cross and both password
  -- rows failed instantly.
  --
  -- Region 1, not "anywhere on B3F".
  --
  -- The floor is three regions that never touch: region 3 (214 cells, the way
  -- in from B1F, warps 2 and 4 on the right), region 1 (57 cells, warps 1 and 3
  -- on the LEFT), and region 2 (46 cells, the boss chamber, sealed until
  -- Giovanni's door opens). Every beat this section needs -- the rival at
  -- (8,10), the locked door at (10,9), Executive 4, HAIL GIOVANNI -- is in
  -- region 1. Arriving anywhere on B3F satisfied a plain `travel`, so the bot
  -- stood in region 3 while row after row reported "no path" to cells on the
  -- same floor. The honest route is a loop: B1F -> B2F r4 -> B3F r3 -> back up
  -- via B3F warp 2 -> B2F r1 -> down B2F warp 2 -> B3F r1.
  --
  -- Region indices come from `tools/goldwalk/mapgraph.lua map <MAP>`; they are
  -- the order in tests/drivers/gold/map_regions.lua and change if the extractor
  -- output changes, so re-check them when regenerating that file.
  -- Heal BEFORE the region-1 loop, then noHeal all the way through HAIL
  -- GIOVANNI.  The rival, Giovanni's door, Executive 4 and the Murkrow are
  -- all in region 1 and the loop into it (11.15r) is a five-hop crossing
  -- through both floors; a between-rows auto-heal after the Executive fight
  -- (which arrives with the party beaten in a continuous run) left the base,
  -- healed at Mahogany, and re-entered in region 3 -- from which (7,2) has no
  -- path.  A wipe on 11.27 still recovers: the whiteout heals, and retryFrom
  -- 11.15r re-runs the loop.
  { id = "11.20h", map = "MAHOGANY_TOWN", op = "heal" },
  { id = "11.15r", map = "TEAM_ROCKET_BASE_B3F", op = "travel", region = 1,
    noHeal = true },
  { id = "11.25", map = "TEAM_ROCKET_BASE_B3F", op = "walk", x = 8, y = 10,
    noHeal = true, note = "rival cutscene, no battle; scene 1 -> 2" },
  { id = "11.26", map = "TEAM_ROCKET_BASE_B3F", op = "talk", x = 10, y = 9,
    facings = { "up" }, budget = 6000, noHeal = true,
    expect = "EVENT_OPENED_DOOR_TO_GIOVANNIS_OFFICE" },
  { id = "11.27", map = "TEAM_ROCKET_BASE_B3F", op = "battle", x = 10, y = 8,
    budget = 12000, noHeal = true, expect = "EVENT_BEAT_ROCKET_EXECUTIVEM_4",
    -- Losable, so it laps. The rewind goes back to the region-1 travel rather
    -- than one row up, because a wipe puts the player in a Pokecenter and the
    -- way back into this half of B3F is the loop through both floors.
    retryFrom = "11.20h", retryLimit = 5 },
  { id = "11.28", map = "TEAM_ROCKET_BASE_B3F", op = "talk", x = 7, y = 2,
    noHeal = true, expect = "EVENT_LEARNED_HAIL_GIOVANNI" },

  -- Back to the B1F side of B2F. Coming out of B3F region 1 lands in B2F
  -- region 1 (top-left, 66 cells); the transmitter door at (14,12) is in region
  -- 4, the half the stairs from B1F open into, and the two do not touch. Same
  -- shape as 11.15r, one floor up.
  -- Via B1F, deliberately, rather than by naming a region index.
  --
  -- The transmitter door's standing cell (14,13) is in the 103-cell half that
  -- the B1F stairs open into, and coming out of B3F region 1 lands in the
  -- 66-cell half instead -- which has no B1F exit at all, only the two back up
  -- to B3F. Going to B1F therefore forces the whole loop, and the plain travel
  -- that follows can only arrive on the right side. A `region =` hint was tried
  -- first and was not reliable here: Bot:currentRegions matches a LIVE flood
  -- fill against the generated seeds, and on this floor it claimed the far
  -- region while standing in the near one, so the travel reported success
  -- without moving.
  -- Heal BEFORE the transmitter room.  Once the Electrode scene arms, the
  -- room cannot be LEFT: Lance's coord events at (12,3)/(12,10)/(12,11) and
  -- the (14/15,12) pair walk the player straight back in (cart behaviour --
  -- RocketBaseLancesSideScript / RocketBaseCantLeaveScript), so a mid-block
  -- auto-heal just bounced off them until the walk gave up and 11.33b/c ran
  -- in whatever state that left.  noHeal through HM06.
  { id = "11.30h", map = "MAHOGANY_TOWN", op = "heal" },
  { id = "11.30q", map = "TEAM_ROCKET_BASE_B1F", op = "travel" },
  { id = "11.30r", map = "TEAM_ROCKET_BASE_B2F", op = "travel", noHeal = true },
  { id = "11.31", map = "TEAM_ROCKET_BASE_B2F", op = "talk", x = 14, y = 12,
    facings = { "up" }, budget = 6000, noHeal = true,
    expect = "EVENT_OPENED_DOOR_TO_ROCKET_HIDEOUT_TRANSMITTER" },
  { id = "11.32", map = "TEAM_ROCKET_BASE_B2F", op = "battle", x = 14, y = 11,
    budget = 12000, noHeal = true, expect = "EVENT_BEAT_ROCKET_EXECUTIVEF_2",
    retryFrom = "11.30h", retryLimit = 5 },
  -- The three Electrodes are wild L23 battles that may Selfdestruct; the third
  -- one ends the base and hands over HM06.
  { id = "11.33a", map = "TEAM_ROCKET_BASE_B2F", op = "battle", x = 7, y = 5,
    talk = true, budget = 8000, noHeal = true },
  { id = "11.33b", map = "TEAM_ROCKET_BASE_B2F", op = "battle", x = 7, y = 7,
    talk = true, budget = 8000, noHeal = true },
  { id = "11.33c", map = "TEAM_ROCKET_BASE_B2F", op = "battle", x = 7, y = 9,
    talk = true, budget = 12000, noHeal = true },
  { id = "11.34", map = "TEAM_ROCKET_BASE_B2F", op = "check", noHeal = true,
    expect = "EVENT_GOT_HM06_WHIRLPOOL",
    -- The whole tail re-runs from the heal when the third Electrode's
    -- handout was missed (a Selfdestruct wipe mid-trio leaves the scene
    -- armed and the room sealed).
    retryFrom = "11.30h", retryLimit = 4 },
  -- WHIRLPOOL and WATERFALL are both water-route gates rather than optional
  -- extras: Route 27 has a whirlpool block on the way to Route 26, and Tohjo
  -- Falls needs the climb.  Taught to the POLIWAG/POLIWHIRL from 07.30 --
  -- SLOWPOKE cannot learn either, despite carrying SURF.
  { id = "11.34b", map = "TEAM_ROCKET_BASE_B2F", op = "teach",
    move = "WHIRLPOOL" },

  { id = "11.36", map = "MAHOGANY_TOWN", op = "travel" },
  { id = "11.36b", map = "MAHOGANY_TOWN", op = "heal" },
  { id = "11.g",  map = "ROUTE_43", op = "grind", level = 43, lead = true },
  { id = "11.36c", map = "MAHOGANY_GYM", op = "travel" },

  -- Mahogany's floor is ice: a press slides until something stops it, so no
  -- cell here can be aimed at and the asm-walk writes the whole gym as a list
  -- of directions.  These two are transcribed from its slide table -- the
  -- first reaches (2,14) beside the pillar, the second the cell below Pryce.
  { id = "11.42", map = "MAHOGANY_GYM", op = "press",
    dirs = { "up", "left", "left", "up", "up" },
    note = "entrance (4,17) -> (2,14); the last three cells are plain floor" },
  { id = "11.43", map = "MAHOGANY_GYM", op = "press",
    dirs = { "up", "up", "right", "down", "left", "up", "right" },
    note = "(2,14) -> (5,4), directly below Pryce at (5,3)" },
  { id = "11.44", map = "MAHOGANY_GYM", op = "battle", x = 5, y = 3, talk = true,
    budget = 14000, expect = "ENGINE_GLACIERBADGE",
    retryFrom = "11.36c", retryLimit = 4 },

  -- =========================================================================
  -- Section 12 : the Radio Tower and the Goldenrod underground
  -- =========================================================================
  -- Seven badges arm ENGINE_ROCKETS_IN_RADIO_TOWER, which is the precondition
  -- for the whole section.  Two passes at the tower with the underground in
  -- between: the Basement Key comes off Executive 3 on 5F, the Card Key from
  -- the Director in the underground warehouse, and only the Card Key opens the
  -- way to the boss.

  -- Mahogany -> Goldenrod the WEST way, surfing across Route 42, not the
  -- eastern loop through the Route 45/46/Dark Cave junction the foot-only graph
  -- prefers (where the live edge-crosser oscillates and teleports).  Route 42
  -- is water-split like Route 27: the Mahogany side and the Ecruteak-gate warp
  -- (0,8) connect only by surf, so name the gate and warp to it -- planPath
  -- surfs the crossing.  From Ecruteak the run to Goldenrod is clean
  -- (Route 37/36/National Park/35).  Same waypoint-the-water-crossing lesson as
  -- TOHJO_FALLS in section 16.
  { id = "12.0a", map = "ROUTE_42", op = "travel" },
  { id = "12.0b", map = "ROUTE_42", op = "warp", x = 0, y = 8,
    to = "ROUTE_42_ECRUTEAK_GATE" },
  { id = "12.0c", map = "ECRUTEAK_CITY", op = "travel" },
  { id = "12.1",  map = "RADIO_TOWER_1F", op = "travel" },
  -- Heal at Goldenrod BEFORE the boss, and lap from here.  Executive 3's four
  -- self-destructing mons can wipe the party, and the whiteout goes to
  -- blackoutMap -- which, walking in from Mahogany, was MAHOGANY_TOWN.  The
  -- recovery travel Mahogany -> Goldenrod then has to cross the Route 45/46/
  -- Dark Cave junction, where the live edge-crosser oscillates and teleports.
  -- Healing at Goldenrod's Pokecenter first sets the spawn HERE (World:
  -- updateWhiteoutSpawn fires on the outdoor->Pokecenter warp), so a wipe lands
  -- next door to the tower and the lap is a two-hop walk, not a cross-Johto
  -- one.  It also enters the fight at full HP, which is half the point.
  { id = "12.8h", map = "GOLDENROD_CITY", op = "heal" },
  { id = "12.9",  map = "RADIO_TOWER_5F", op = "travel" },
  { id = "12.9b", map = "RADIO_TOWER_5F", op = "walk", x = 0, y = 3,
    budget = 14000, expect = "EVENT_BEAT_ROCKET_EXECUTIVEM_3",
    note = "FakeDirectorScript coord event; six mons, four of them explode",
    retryFrom = "12.8h", retryLimit = 6 },

  { id = "12.11", map = "GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES",
    op = "travel" },
  -- Region 1 of the underground (157 cells, warps 1/2/3): the salon side that
  -- holds the Basement Key door at (18,6). The basement side (region 5) is the
  -- OTHER half of the same-map warp pair, and a plain travel can land there
  -- via switch-room warp 1 -- after which (18,6) has nowhere to stand.
  { id = "12.14", map = "GOLDENROD_UNDERGROUND", op = "travel", region = 1 },
  { id = "12.14b", map = "GOLDENROD_UNDERGROUND", op = "talk", x = 18, y = 6,
    expect = "EVENT_USED_BASEMENT_KEY" },
  -- Region 1 of the switch room (91 cells, warp 1 only): the north corridor
  -- with the rival trigger and Switch1/2/3. Ten regions on this map; city
  -- warps land in 9/10 and underground warp 1 lands in 10, none of which can
  -- reach (16,1). Only underground warp 6 (basement side) opens into region 1.
  { id = "12.16", map = "GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES",
    op = "walk", x = 19, y = 4, budget = 14000, region = 1,
    expect = "EVENT_RIVAL_GOLDENROD_UNDERGROUND" },

  -- Heal BEFORE the puzzle.  noHeal from 12.18a through the Card Key:
  -- MAPCALLBACK_NEWMAP on the underground / warehouse zeroes
  -- wUndergroundSwitchPositions, so a heal between Switch3 and Switch2 undoes
  -- the puzzle.  The warehouse grunts are also losable, so arrive full.
  { id = "12.15h", map = "GOLDENROD_CITY", op = "heal" },

  -- Pin region 1 before the switches. 12.16 can be `already satisfied` (the
  -- rival flag survives a wipe / resume), which skips tryReach and leaves the
  -- bot in whichever half of the map a plain hop preferred -- then every
  -- switch reports "nowhere to stand". Same shape as 11.15r.
  { id = "12.17r", map = "GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES",
    op = "travel", region = 1, noHeal = true },

  -- The switch puzzle.  Each switch is a bg event read with A; the shared byte
  -- is a plain sum, and intermediate positions leave some doors untouched, so
  -- order matters.  1-then-2-then-3 opens door 8 (Eddie) but NOT door 5.
  -- 3-then-2-then-1 from the reset state opens doors 3,5,6,8,9,11 -- door 5
  -- at (10,10) is the one that reaches the warehouse warps at (22,10)/(23,10).
  -- See asm-walk section 12, "Consequences a bot needs".
  { id = "12.18a", map = "GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES",
    op = "talk", x = 2, y = 1, budget = 4000, region = 1, noHeal = true,
    note = "Switch3 ON (byte 0->3)" },
  { id = "12.18b", map = "GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES",
    op = "talk", x = 10, y = 1, budget = 4000, region = 1, noHeal = true,
    note = "Switch2 ON (byte 3->5); leaves door 5 open" },
  { id = "12.18c", map = "GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES",
    op = "talk", x = 16, y = 1, budget = 4000, region = 1, noHeal = true,
    note = "Switch1 ON (byte 5->6); warehouse path open" },
  { id = "12.24", map = "GOLDENROD_UNDERGROUND_WAREHOUSE", op = "travel",
    noHeal = true },
  { id = "12.26", map = "GOLDENROD_UNDERGROUND_WAREHOUSE", op = "talk",
    x = 12, y = 8, budget = 12000, noHeal = true,
    expect = "EVENT_RECEIVED_CARD_KEY",
    -- A wipe blacks out to the city and the switch callback has already
    -- zeroed the puzzle, so the rewind re-enters from the heal + region pin.
    retryFrom = "12.15h", retryLimit = 5 },

  -- Out of the warehouse the intended (and only) road is THROUGH the dept
  -- store basement: EVENT_RECEIVED_CARD_KEY's MAPCALLBACK_TILES clears the
  -- box pile at B1F block (8,2) (GoldenrodDeptStoreB1F.asm), joining the
  -- warehouse-stairs pocket to the elevator.  That changeblock is invisible to
  -- the static region graph -- its B1F region 2 lists only the way back -- so
  -- travel alone loops the switch-room pocket and falls back to TELEPORT.
  -- Ride the elevator to 1F and leave by the front door.
  { id = "12.27", map = "GOLDENROD_DEPT_STORE_B1F", op = "travel",
    noHeal = true },
  { id = "12.27b", map = "GOLDENROD_DEPT_STORE_ELEVATOR", op = "travel",
    noHeal = true },
  { id = "12.27c", map = "GOLDENROD_DEPT_STORE_ELEVATOR", op = "elevator",
    x = 3, y = 0, floor = "1F", doorX = 1, doorY = 3,
    to = "GOLDENROD_DEPT_STORE_1F" },
  { id = "12.28", map = "RADIO_TOWER_3F", op = "travel" },
  { id = "12.29", map = "RADIO_TOWER_3F", op = "talk", x = 14, y = 2,
    facings = { "up" }, budget = 6000,
    expect = "EVENT_USED_THE_CARD_KEY_IN_THE_RADIO_TOWER" },
  { id = "12.g",  map = "ROUTE_35", op = "grind", level = 45, lead = true },
  -- 5F is two regions that never touch: region 1 (35 cells, warp 1 from the
  -- west stairs) and region 2 (44 cells, warp 2 from 4F's east stairs). The
  -- boss coord at (16,5) is in region 2, and the only way onto that half is
  -- 3F warp 3 (behind the Card Key shutter) -> 4F region 2 -> 5F warp 2.
  -- A plain travel lands at 5F (0,0) in region 1, where (16,5) has no path.
  { id = "12.32", map = "RADIO_TOWER_5F", op = "travel", region = 2 },
  { id = "12.33", map = "RADIO_TOWER_5F", op = "walk", x = 16, y = 5,
    budget = 20000, region = 2, expect = "EVENT_CLEARED_RADIO_TOWER",
    note = "the script walks the player two cells left, then EXECUTIVEM_1",
    retryFrom = "12.32", retryLimit = 5 },

  -- =========================================================================
  -- Section 13 : the Ice Path, Clair and the Rising Badge
  -- =========================================================================

  { id = "13.1",  map = "MAHOGANY_TOWN", op = "travel" },
  { id = "13.1b", map = "MAHOGANY_TOWN", op = "heal" },
  { id = "13.9",  map = "ICE_PATH_1F", op = "travel" },
  { id = "13.10", map = "ICE_PATH_1F", op = "talk", x = 31, y = 7,
    expect = "EVENT_GOT_HM07_WATERFALL" },
  -- Same mule as 11.34b: the POLIWAG/POLIWHIRL from 07.30.
  { id = "13.10b", map = "ICE_PATH_1F", op = "teach", move = "WATERFALL" },
  { id = "13.11", map = "ICE_PATH_B1F", op = "travel" },

  -- Four boulders onto four holes (stonetable warp N+2).  Each straight shove
  -- of N cells uses count = 2*N - 1: the player does not move with the rock, so
  -- every other press is the step into the cell it vacated (same pairing
  -- Cianwood's 08.65* rows use).  A hole-ending segment stops on the falling
  -- push so the bot does not walk into the pit afterward.
  --
  -- Order matters: the spawn boulders seal each other's stand cells, and the
  -- old single-row "push up 5 from spawn" rows could not even stand south of
  -- boulder 1.  Solved against the extracted collision + player reachability.

  -- B3 (8,9) -> hole (5,12) = EVENT_BOULDER_IN_ICE_PATH_3
  { id = "13.12a", map = "ICE_PATH_B1F", op = "push", x = 8, y = 9, dir = "right",
    count = 1 },
  { id = "13.12b", map = "ICE_PATH_B1F", op = "push", x = 9, y = 9, dir = "down",
    count = 11 },
  { id = "13.12c", map = "ICE_PATH_B1F", op = "push", x = 9, y = 15, dir = "left",
    count = 5 },
  { id = "13.12d", map = "ICE_PATH_B1F", op = "push", x = 6, y = 15, dir = "up",
    count = 1 },
  { id = "13.12e", map = "ICE_PATH_B1F", op = "push", x = 6, y = 14, dir = "left",
    count = 1 },
  { id = "13.12", map = "ICE_PATH_B1F", op = "push", x = 5, y = 14, dir = "up",
    count = 3, expect = "EVENT_BOULDER_IN_ICE_PATH_3" },

  -- B4 (17,7) -> hole (12,13) = EVENT_BOULDER_IN_ICE_PATH_4
  { id = "13.13a", map = "ICE_PATH_B1F", op = "push", x = 17, y = 7, dir = "left",
    count = 1 },
  { id = "13.13b", map = "ICE_PATH_B1F", op = "push", x = 16, y = 7, dir = "down",
    count = 7 },
  { id = "13.13c", map = "ICE_PATH_B1F", op = "push", x = 16, y = 11, dir = "right",
    count = 1 },
  { id = "13.13d", map = "ICE_PATH_B1F", op = "push", x = 17, y = 11, dir = "down",
    count = 3 },
  { id = "13.13", map = "ICE_PATH_B1F", op = "push", x = 17, y = 13, dir = "left",
    count = 9, expect = "EVENT_BOULDER_IN_ICE_PATH_4" },

  -- B1 (11,7) -> hole (11,2) = EVENT_BOULDER_IN_ICE_PATH_1
  -- Approaches the hole from the west: (11,4) is wall, so the last shove is
  -- right from (10,2) (see tests/drivers/gold_icepath_boulder.lua).
  { id = "13.14a", map = "ICE_PATH_B1F", op = "push", x = 11, y = 7, dir = "up",
    count = 3 },
  { id = "13.14b", map = "ICE_PATH_B1F", op = "push", x = 11, y = 5, dir = "left",
    count = 1 },
  { id = "13.14c", map = "ICE_PATH_B1F", op = "push", x = 10, y = 5, dir = "up",
    count = 5 },
  { id = "13.14", map = "ICE_PATH_B1F", op = "push", x = 10, y = 2, dir = "right",
    count = 1, expect = "EVENT_BOULDER_IN_ICE_PATH_1" },

  -- B2 (7,8) -> hole (4,7) = EVENT_BOULDER_IN_ICE_PATH_2
  { id = "13.15a", map = "ICE_PATH_B1F", op = "push", x = 7, y = 8, dir = "left",
    count = 1 },
  { id = "13.15b", map = "ICE_PATH_B1F", op = "push", x = 6, y = 8, dir = "up",
    count = 9 },
  { id = "13.15c", map = "ICE_PATH_B1F", op = "push", x = 6, y = 3, dir = "left",
    count = 1 },
  { id = "13.15d", map = "ICE_PATH_B1F", op = "push", x = 5, y = 3, dir = "down",
    count = 7 },
  { id = "13.15", map = "ICE_PATH_B1F", op = "push", x = 5, y = 7, dir = "left",
    count = 1, expect = "EVENT_BOULDER_IN_ICE_PATH_2" },

  { id = "13.26", map = "BLACKTHORN_CITY", op = "travel" },
  { id = "13.27", map = "BLACKTHORN_CITY", op = "heal" },
  -- Two FULL RESTOREs for Clair.  Her lead DRAGONAIR opens with THUNDER WAVE,
  -- and a paralyzed Fire lead loses the KINGDRA war (half speed, quarter of
  -- its turns skipped, super-effective SURF, plus Clair's own HYPER POTION).
  -- FULL RESTORE is the only status cure the port implements as a battle item,
  -- and A.statusCure spends one to un-paralyse -- after which a level-58
  -- TYPHLOSION outspeeds and wins.  Bought at Blackthorn's mart; the Elite
  -- Four buys its own later, so this does not raid that budget.
  { id = "13.26b", map = "BLACKTHORN_MART", op = "buy", item = "FULL_RESTORE",
    count = 2, optional = true },
  -- 52 lead: the fighter usually arrives higher from the switch grinds, and
  -- 13.g re-checks as satisfied then.  The Clair retry loop cannot grow the
  -- party (same reason), so the real lever is the paralysis cure above.
  { id = "13.g",  map = "ROUTE_45", op = "grind", level = 52, lead = true },
  { id = "13.28", map = "BLACKTHORN_GYM_1F", op = "travel" },
  -- Clair's island is its own region on 1F.  EVENT_BOULDER_IN_BLACKTHORN_GYM_1
  -- and _3 (with _2 for the full intended bridge) are painted by the 1F
  -- MAPCALLBACK_TILES when the matching 2F boulders fall; without them the
  -- right-stairs landing never reaches (5,3).
  { id = "13.28b", map = "BLACKTHORN_GYM_2F", op = "travel" },

  -- Cody and Fran FIRST, then heal, then run the boulders in one unbroken
  -- visit.  The full run wiped the lead on their sight lines mid-sequence,
  -- the between-rows auto-heal left the gym, and the map reload respawned
  -- every unfallen boulder under the remaining rows -- 13.29c/13.29a2 then
  -- had no stand cell.  Beaten trainers stay beaten, so the fights are safe
  -- to take early; noHeal below keeps the sequence unbroken.
  { id = "13.28c", map = "BLACKTHORN_GYM_2F", op = "battle", x = 4, y = 1,
    talk = true, budget = 10000, optional = true,
    expect = "EVENT_BEAT_COOLTRAINERM_CODY" },
  { id = "13.28d", map = "BLACKTHORN_GYM_2F", op = "battle", x = 4, y = 11,
    talk = true, budget = 10000, optional = true,
    expect = "EVENT_BEAT_COOLTRAINERF_FRAN" },
  { id = "13.28h", map = "BLACKTHORN_CITY", op = "heal" },
  { id = "13.28r", map = "BLACKTHORN_GYM_2F", op = "travel" },

  -- Cody at (4,1) seals the top row, so the stand cell south of B2 (2,2) is
  -- unreachable until B4 is parked north out of the (3,2)/(3,3) corridor.
  { id = "13.29a0", map = "BLACKTHORN_GYM_2F", op = "push", x = 3, y = 3, dir = "up",
    count = 3, optional = true, noHeal = true,
    note = "B4 to (3,1); opens the path to (2,2)" },
  -- B2 (2,3) -> (2,4), then into hole (2,5) after B1 (order from the solver)
  { id = "13.29a", map = "BLACKTHORN_GYM_2F", op = "push", x = 2, y = 3, dir = "down",
    count = 1, optional = true, noHeal = true },
  -- B5 (6,1) park.  optional so a Clair retry can soft-miss.
  { id = "13.29b", map = "BLACKTHORN_GYM_2F", op = "push", x = 6, y = 1, dir = "right",
    count = 5, optional = true, noHeal = true },
  -- B6 (8,14) clears the south corridor for B3.
  { id = "13.29d", map = "BLACKTHORN_GYM_2F", op = "push", x = 8, y = 14, dir = "down",
    count = 5, optional = true, noHeal = true },
  -- B3 (6,16) up to (6,7), then one right to (7,7) while B1/B2 finish.
  { id = "13.29e", map = "BLACKTHORN_GYM_2F", op = "push", x = 6, y = 16, dir = "up",
    count = 17, optional = true, noHeal = true },
  { id = "13.29e2", map = "BLACKTHORN_GYM_2F", op = "push", x = 6, y = 7, dir = "right",
    count = 1, optional = true, noHeal = true },
  -- B1 (8,2) -> hole (8,3)
  { id = "13.29c", map = "BLACKTHORN_GYM_2F", op = "push", x = 8, y = 2, dir = "down",
    count = 1, noHeal = true, expect = "EVENT_BOULDER_IN_BLACKTHORN_GYM_1" },
  -- B2 (2,4) -> hole (2,5)
  { id = "13.29a2", map = "BLACKTHORN_GYM_2F", op = "push", x = 2, y = 4, dir = "down",
    count = 1, noHeal = true, expect = "EVENT_BOULDER_IN_BLACKTHORN_GYM_2" },
  -- B3 (7,7) -> hole (8,7)
  { id = "13.29f", map = "BLACKTHORN_GYM_2F", op = "push", x = 7, y = 7, dir = "right",
    count = 1, noHeal = true, expect = "EVENT_BOULDER_IN_BLACKTHORN_GYM_3" },

  -- Come down the RIGHT stairs so we land in the bridged region.  The door
  -- from the city is the OTHER region and cannot reach Clair even with every
  -- bridge painted -- only warp 2 / hole landings 6 and 7 can.
  { id = "13.29g", map = "BLACKTHORN_GYM_2F", op = "warp", x = 7, y = 9,
    to = "BLACKTHORN_GYM_1F", noHeal = true },
  -- Clair is the hardest single fight in the Johto half for a mono-Fire lead:
  -- a bulky Water/Dragon KINGDRA that resists Fire and SURFs super-effectively,
  -- THUNDER WAVE paralysis off her DRAGONAIRs, and her own HYPER POTION.  A
  -- level-58 TYPHLOSION wins it about one lap in five, so the lever is laps.
  -- retryFrom the FULL RESTORE buy so a paralysis cure is restocked while
  -- there is money (a lost lap halves it -- Gen 2 -- so the cure mostly lands
  -- on the first attempt); verified beaten within budget from RESUME=13.
  -- retryLimit 26, not 12: each lost lap KEEPS the EXP from beating her three
  -- DRAGONAIRs before KINGDRA (resolveFaints awards it before the loss check),
  -- so the lead climbs ~1 level every ~3 laps -- but her level-37 mons give a
  -- level-58 TYPHLOSION so little that 12 laps only bought +3 (to 61), short of
  -- what out-races KINGDRA + her HYPER POTION under paralysis.  ~26 laps buys
  -- ~+8, which wins reliably; most runs land it in well under a dozen and stop
  -- early.  (This is the same lose-to-grind loop the Elite Four rides, only
  -- against much weaker mons, hence the higher count.)
  { id = "13.30", map = "BLACKTHORN_GYM_1F", op = "battle", x = 5, y = 3,
    talk = true, budget = 16000, expect = "EVENT_BEAT_CLAIR",
    retryFrom = "13.26b", retryLimit = 26 },

  -- The badge is not Clair's to give until the Dragon's Den test: the Dragon
  -- Fang at the shrine is what sets RISINGBADGE.
  { id = "13.32", map = "DRAGONS_DEN_B1F", op = "travel" },
  { id = "13.33", map = "DRAGONS_DEN_B1F", op = "talk", x = 35, y = 16,
    budget = 12000, expect = "EVENT_DRAGONS_DEN_B1F_DRAGON_FANG" },
  { id = "13.33b", map = "DRAGONS_DEN_B1F", op = "check",
    expect = "ENGINE_RISINGBADGE" },

  -- =========================================================================
  -- Section 16 : east to Kanto's door
  -- =========================================================================
  -- Eight badges, SURF, WATERFALL and WHIRLPOOL are all in hand by here, which
  -- is what makes Route 27 and Tohjo Falls crossable at all.

  -- Waypointed through Route 46 so the Route 45 descent is two short legs, not
  -- one Blackthorn -> New Bark plan that flip-flopped at the seam.  The
  -- crossing itself needed the edgeTarget fix: coming onto Route 45's top strip
  -- (region 3), the west border cells nearest the landing are region 1/2 and
  -- unreachable, and the old nearest-16 reachability cap never scanned down to
  -- region 3's own Route 46 cells (Bot:edgeTarget).
  { id = "16.22a", map = "ROUTE_46", op = "travel" },
  { id = "16.22b", map = "ROUTE_29", op = "travel" },
  { id = "16.23", map = "NEW_BARK_TOWN", op = "travel" },
  { id = "16.24", map = "ELMS_LAB", op = "travel", optional = true },
  { id = "16.24b", map = "ELMS_LAB", op = "talk", x = 5, y = 2, optional = true,
    expect = "EVENT_GOT_MASTER_BALL_FROM_ELM" },
  { id = "16.27", map = "ROUTE_27", op = "travel" },
  { id = "16.28", map = "ROUTE_27", op = "settle", budget = 8000,
    note = "FirstStepIntoKantoScene is unskippable" },
  -- Route 27 is split by water and by TOHJO FALLS: the west half (where the
  -- New Bark crossing lands, itself over water -- asm-walk map row 4, "the
  -- crossing itself is water, so SURF") does not touch the east edge that
  -- connects to Route 26.  The intended path is through the falls -- surf to
  -- warp 2, climb inside with WATERFALL, exit warp 3 onto the east half -- and
  -- the static region graph is foot-only, so `travel ROUTE_26` from the west
  -- tries the unreachable east edge and oscillates into a teleport.  Naming
  -- TOHJO_FALLS forces the surf-and-climb; the east half then reaches Route 26.
  { id = "16.42", map = "TOHJO_FALLS", op = "travel" },
  -- Leave by the EAST warp (25,15 -> Route 27 warp 3), not the west one we came
  -- in through.  Reaching it means climbing the falls inside -- warp 1's pool
  -- (region 6) and warp 2's ledge (region 7) touch only up the WATERFALL -- so
  -- this exercises the HM07 climb.  A plain `travel ROUTE_27` picked the nearest
  -- warp, which was the west one straight back into the pocket.
  { id = "16.42b", map = "TOHJO_FALLS", op = "warp", x = 25, y = 15,
    to = "ROUTE_27" },
  { id = "16.43", map = "ROUTE_26", op = "travel" },
  { id = "16.54", map = "VICTORY_ROAD_GATE", op = "travel" },
  { id = "16.55", map = "VICTORY_ROAD_GATE", op = "walk", x = 10, y = 11,
    budget = 6000, note = "the badge check; eight badges walks straight through" },

  -- =========================================================================
  -- Section 17 : Victory Road
  -- =========================================================================

  { id = "17.2",  map = "VICTORY_ROAD", op = "travel" },
  { id = "17.11", map = "VICTORY_ROAD", op = "walk", x = 13, y = 8,
    budget = 16000, expect = "EVENT_RIVAL_VICTORY_ROAD",
    note = "the rival ambush; there is no way past it" },
  { id = "17.15", map = "ROUTE_23", op = "travel" },

  -- =========================================================================
  -- Section 18 : the Pokemon League
  -- =========================================================================
  -- One-way.  Every room seals behind you and the Pokecenter's own
  -- MAPCALLBACK_NEWMAP wipes every EVENT_BEAT_ELITE_4_*, so a heal after Will
  -- restarts the gauntlet -- which is why the only heal row is before the door.

  { id = "18.4",  map = "INDIGO_PLATEAU_POKECENTER_1F", op = "travel" },
  -- The gauntlet is five fights with no heal between them (the Pokecenter's
  -- MAPCALLBACK_NEWMAP wipes every EVENT_BEAT_ELITE_4_*), so everything the
  -- party will ever have has to be bought and earned before the door.  Run 13
  -- earned all eight badges and then lost Koga and Bruno on level and
  -- attrition alone.
  -- Grind on VICTORY_ROAD, not Route 26, and only the lead.
  --
  -- Johto's wilds cap around level 30, so a target of 78 on Route 26's
  -- low-twenties encounters is a number the bot can never reach -- it spent
  -- 160k frames gaining nothing and then failed on its wipe budget.  Victory
  -- Road is the highest-level ground actually reachable before the door.
  -- The party-minimum grind is dropped here on purpose: it rotates the WEAKEST
  -- mon to the front, and at this point in the game that mon is wiped by the
  -- wilds faster than it can earn anything.
  { id = "18.g",  map = "VICTORY_ROAD", op = "grind", level = 62, lead = true,
    wipeBudget = 8 },
  -- Cheap heals FIRST, and only then the expensive one.
  --
  -- This bought FULL_RESTORE first at Y3000 each, which with a lap's ~Y9000
  -- meant a bag of exactly three items and nothing left for HYPER_POTIONs. The
  -- bot then spent all three topping up in Will's, Koga's and Bruno's rooms and
  -- walked into LANCE with an empty bag -- it was killing five of his six and
  -- losing to the last DRAGONITE with no answer. Five HYPER_POTIONs (Y6000) and
  -- one FULL_RESTORE (Y3000) is the same money for twice the heals, and it is
  -- the shape A.bestHeal's rationing wants: something cheap to spend between
  -- 0.35 and 0.6, and one good thing held back for below it.
  { id = "18.g3", map = "INDIGO_PLATEAU_POKECENTER_1F", op = "buy",
    item = "HYPER_POTION", count = 4, optional = true },
  { id = "18.g4", map = "INDIGO_PLATEAU_POKECENTER_1F", op = "buy",
    item = "FULL_RESTORE", count = 4, optional = true },
  { id = "18.g5", map = "INDIGO_PLATEAU_POKECENTER_1F", op = "buy",
    item = "REVIVE", count = 10, optional = true },
  { id = "18.4b", map = "INDIGO_PLATEAU_POKECENTER_1F", op = "travel" },
  { id = "18.4c", map = "INDIGO_PLATEAU_POKECENTER_1F", op = "heal" },

  -- Every fight from here to the Champion carries `retryFrom = "18.g3"`.
  --
  -- Losing costs half the money and nothing else -- the experience earned on
  -- the way to the wipe is kept -- so a lost gauntlet is not a dead end, it is
  -- a grind that pays better than any grass in the game.  Will's mons are in
  -- the forties; a lap that dies to Bruno still banks Xatu, Jynx, Exeggutor,
  -- Slowbro, Ariados, Venomoth, Muk, Forretress and Hitmontop.
  --
  -- The rewind lands on 18.g3 (the shop) rather than on Will's door because
  -- IndigoPlateauPokecenter1F's MAPCALLBACK_NEWMAP clears all five BEAT flags
  -- AND all ten room ENTRANCE/EXIT flags, so after a wipe the gauntlet really
  -- does start over at Will -- and the restock and heal have to happen again
  -- with it.  See maps/IndigoPlateauPokecenter1F.asm.
  { id = "18.7",  map = "WILLS_ROOM", op = "travel" },
  { id = "18.8",  map = "WILLS_ROOM", op = "settle", budget = 6000,
    expect = "EVENT_WILLS_ROOM_ENTRANCE_CLOSED", retryFrom = "18.g3" },
  { id = "18.9",  map = "WILLS_ROOM", op = "battle", x = 5, y = 7, talk = true,
    budget = 20000, expect = "EVENT_BEAT_ELITE_4_WILL", retryFrom = "18.g3" },

  { id = "18.11", map = "KOGAS_ROOM", op = "travel" },
  { id = "18.11b", map = "KOGAS_ROOM", op = "settle", budget = 6000 },
  { id = "18.11c", map = "KOGAS_ROOM", op = "battle", x = 5, y = 7, talk = true,
    budget = 20000, expect = "EVENT_BEAT_ELITE_4_KOGA", retryFrom = "18.g3" },

  { id = "18.13", map = "BRUNOS_ROOM", op = "travel" },
  { id = "18.13b", map = "BRUNOS_ROOM", op = "settle", budget = 6000 },
  -- 18 laps, not the default 12: Bruno is the wall when the party arrives
  -- light, and a lost gauntlet lap is the best-paying grind in the game --
  -- the extra laps cost frames, running out of them costs the run.
  { id = "18.13c", map = "BRUNOS_ROOM", op = "battle", x = 5, y = 7, talk = true,
    budget = 20000, expect = "EVENT_BEAT_ELITE_4_BRUNO", retryFrom = "18.g3",
    retryLimit = 18 },

  { id = "18.15", map = "KARENS_ROOM", op = "travel" },
  { id = "18.15b", map = "KARENS_ROOM", op = "settle", budget = 6000 },
  { id = "18.15c", map = "KARENS_ROOM", op = "battle", x = 5, y = 7, talk = true,
    budget = 20000, expect = "EVENT_BEAT_ELITE_4_KAREN", retryFrom = "18.g3" },

  { id = "18.17", map = "LANCES_ROOM", op = "travel" },
  { id = "18.17b", map = "LANCES_ROOM", op = "settle", budget = 8000,
    expect = "EVENT_LANCES_ROOM_ENTRANCE_CLOSED", retryFrom = "18.g3" },
  -- The coord event at (4,5) is the Champion fight; the script walks the
  -- player in, so this is a walk row rather than a talk.
  -- No `expect` on the walk itself, and this is not laziness.
  --
  -- LancesRoom.asm sets EVENT_BEAT_CHAMPION_LANCE, prints two more pages of
  -- text, opens the door with `changeblock` and only then lets the player
  -- north.  The bot walks through that door the moment it opens, so the `walk`
  -- op ends with "left LANCES_ROOM for HALL_OF_FAME" -- and a postcondition
  -- checked at that instant raced the script.  Run 20 beat Lance ("CHAMPION
  -- LANCE was defeated!", ¥5000 prize) NINE times and the row failed all nine,
  -- each time rewinding the bot back out of the Hall of Fame to refight the
  -- whole gauntlet.  The win was real every time; the oracle was wrong.
  --
  -- So the walk just triggers the fight, and the finish line is measured where
  -- it actually happens: standing in the HALL OF FAME with the flag its own
  -- script sets.
  { id = "18.18", map = "LANCES_ROOM", op = "walk", x = 4, y = 5,
    budget = 30000, expect = "EVENT_BEAT_CHAMPION_LANCE",
    retryFrom = "18.g3" },
  -- No row here with `map = "HALL_OF_FAME"` that is allowed to fail softly.
  -- One was tried and it manufactured a false win: the runner reaches a row's
  -- map before running it, could not walk to the Hall of Fame from the
  -- Pokecenter it had just whited out to, and fell back to the harness
  -- TELEPORT shortcut -- so a run that LOST to Lance still finished with
  -- "final map: HALL_OF_FAME", and 18.20 then read `already satisfied` off an
  -- EVENT_BEAT_ELITE_FOUR left over in the checkpoint.  18.18 is the gate.
  { id = "18.20", map = "HALL_OF_FAME", op = "settle", budget = 20000,
    expect = "EVENT_BEAT_ELITE_FOUR",
    note = "Lance's speech, the roster, the credits: the finish line" },
}
