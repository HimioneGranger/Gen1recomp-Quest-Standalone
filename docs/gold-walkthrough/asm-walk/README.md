# ASM Walk index

One document per walkthrough section, each mapping that section's beats onto the
pokegold disassembly: map constants and asm files, verbatim warp / coord / bg /
object event tables, script control flow with the `EVENT_*` and `ENGINE_*` flags
each label reads and writes, trainer party labels, wild encounter tables, the code
that enforces each progress gate, an ordered bot checklist, and a port-coverage
audit against `src/world/gen2/`, `src/script/gen2/`, `src/core/gen2/` and
`src/battle/gen2/`.

Written against:

- Walkthrough source: `docs/gold-walkthrough/section-NN-*.txt`
- Disassembly: `../pokegold` (paths in these docs are relative to that checkout root)
- Symbols: `../pokegold-symbols/pokegold.sym`

Output shape is defined in [_TEMPLATE.md](_TEMPLATE.md).

## Sections

### 00. [chikorita cyndaquil or totodile](section-00-chikorita-cyndaquil-or-totodile.md)

Covers the Pokemon Gold opening: new game, InitClock time set, Oak speech and player naming, the bedroom spawn at SPAWN_HOME, Mom's Pokegear cutscene, New Bark Town and the first rival encounter, and Elm's Lab through the starter choice and the aide's Potion. Documents every warp/coord/bg/object row for the four maps, the scene-id gates that block progress, the starter givepoke data, and where each beat lands (or does not land) in this repo's Gen 2 port.

**Maps:** `MAP_PLAYERS_HOUSE_2F`, `MAP_PLAYERS_HOUSE_1F`, `MAP_NEW_BARK_TOWN`, `MAP_ELMS_LAB`

**Gates:**

- SCENE_ELMSLAB_CANT_LEAVE (scene 1) coord events at ElmsLab (4,6)/(5,6) -> LabTryToLeaveScript pushes the player back up; released only by ElmDirectionsScript's setscene SCENE_ELMSLAB_AIDE_GIVES_POTION
- SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU (scene 0) coord events at NewBarkTown (1,8)/(1,9) -> NewBarkTown_TeacherStopsYouScene1/2 drag the player back east; released by ElmDirectionsScript's setmapscene NEW_BARK_TOWN, SCENE_NEWBARKTOWN_NOOP
- EVENT_GOT_A_POKEMON_FROM_ELM (constants/event_flags.asm:35) is the section's terminal flag, set by ElmDirectionsScript after any starter is taken
- InitClock (engine/rtc/timeset.asm:4) must be answered plus confirmed twice before the world is created
- MeetMomScript's DST yesorno pair loops back to .SetDayOfWeek on a 'no' confirm - the Pokegear/ENGINE_POKEGEAR flags are not set until it exits
- Aide's POTION is scene-gated (SCENE_ELMSLAB_AIDE_GIVES_POTION at ElmsLab (4,8)/(5,8)), not flag-gated
- EVERSTONE requires EVENT_SHOWED_TOGEPI_TO_ELM (ElmGiveEverstoneScript, maps/ElmsLab.asm:338-347) - unreachable in this section despite the walkthrough listing it

**Unresolved (6):**

- Walkthrough lists Everstone as a New Bark Town item; the only local Everstone is ElmGiveEverstoneScript gated on EVENT_SHOWED_TOGEPI_TO_ELM (hatched Togepi), many sections later
- Walkthrough says Oak greets you then asks the time; in engine/menus/intro_menu.asm:494 OakSpeech's first instruction is farcall InitClock, so the clock screen comes first
- Walkthrough treats the Pokegear as a received item; MeetMomScript only does setflag ENGINE_POKEGEAR / ENGINE_PHONE_CARD, nothing enters the bag
- 'the time will keep running even with the GBA off' is an RTC hardware claim with no disassembly counterpart
- data/maps/attributes.asm:121 gives NEW_BARK_TOWN a connection east to ROUTE_27 with no guarding coord event; whether the shoreline in maps/NewBarkTown.blk blocks it pre-Surf was not decoded
- Only (1,8) and (1,9) carry the teacher coord events; whether the west connection strip is reachable at any other y was not verified against collision data

### 01. [cherrygrove city and routes 29 31](section-01-cherrygrove-city-and-routes-29-31.md)

Maps the Cherrygrove/Routes 29-31 walkthrough stretch onto pokegold: every warp, coord event, bg event and object event row transcribed verbatim from maps/Route29.asm, CherrygroveCity.asm, Route30.asm, Route31.asm, Route46.asm, MrPokemonsHouse.asm and the surrounding houses/gates, plus map headers, wild tables, trainer parties and the EVENT_/ENGINE_ flags each script reads and writes. Adds a 30-step bot checklist, the enforcing code for every progress gate, and an honest port-coverage table that flags item balls as unimplemented and the MAP CARD flag as not reaching the Pokegear.

**Milestones:** No badge earned in this section; ENGINE_MAP_CARD (Guide Gent tour, CherrygroveCityGuideGent); ENGINE_POKEDEX (MrPokemonsHouse_OakScript); MYSTERY_EGG obtained then delivered -> EVENT_GAVE_MYSTERY_EGG_TO_ELM; Rival battle 1 won (RIVAL1 id 1/2/3, level 5 starter); ENGINE_FLYPOINT_CHERRYGROVE + blackoutmod CHERRYGROVE_CITY

**Maps:** `MAP_ROUTE_29`, `MAP_ROUTE_29_ROUTE_46_GATE`, `MAP_ROUTE_46`, `MAP_CHERRYGROVE_CITY`, `MAP_CHERRYGROVE_POKECENTER_1F`, `MAP_CHERRYGROVE_MART`, `MAP_GUIDE_GENTS_HOUSE`, `MAP_CHERRYGROVE_GYM_SPEECH_HOUSE`, `MAP_CHERRYGROVE_EVOLUTION_SPEECH_HOUSE`, `MAP_ROUTE_30`, `MAP_ROUTE_30_BERRY_HOUSE`, `MAP_MR_POKEMONS_HOUSE`, `MAP_ROUTE_31`, `MAP_ROUTE_31_VIOLET_GATE`, `MAP_NEW_BARK_TOWN`, `MAP_ELMS_LAB`, `MAP_PLAYERS_HOUSE_1F`, `MAP_DARK_CAVE_VIOLET_ENTRANCE (mouth only)`, `MAP_VIOLET_CITY (next section, one line)`

**Gates:**

- New Bark west exit blocked pre-starter: NewBarkTown.asm coord events (1,8)/(1,9) under SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU; cleared by ElmsLab.asm:ElmDirectionsScript setmapscene NEW_BARK_TOWN, SCENE_NEWBARKTOWN_NOOP
- Elm's Lab exit blocked pre-starter: LabTryToLeaveScript at coord events (4,6)/(5,6) under SCENE_ELMSLAB_CANT_LEAVE
- Route 30 west fork blocked by the three EVENT_ROUTE_30_BATTLE objects at (5,24)/(5,25)/(5,26); ElmAfterTheftScript sets that event (hiding them) and clears EVENT_ROUTE_30_YOUNGSTER_JOEY (spawning Joey)
- Cherrygrove east exit trip-wire: coord events (33,6)/(33,7) under SCENE_CHERRYGROVECITY_MEET_RIVAL, armed by MrPokemonsHouse_OakScript; BATTLETYPE_CANLOSE so a loss still advances
- Elm's Lab cop scene: coord events (4,5)/(5,5) under SCENE_ELMSLAB_MEET_OFFICER -> CopScript (special NameRival)
- POKE BALLs not sold until EVENT_GAVE_MYSTERY_EGG_TO_ELM: CherrygroveMartClerkScript picks MART_CHERRYGROVE vs MART_CHERRYGROVE_DEX
- Route 29 catch tutorial needs SCENE_ROUTE29_CATCH_TUTORIAL, set only by ElmAfterTheftScript
- Dark Cave unusable: engine/events/overworld.asm FlashFunction/.CheckUseFlash requires ENGINE_ZEPHYRBADGE plus DARKNESS_PALSET
- PINK BOW unobtainable here: Route29TuscanyCallback requires ENGINE_ZEPHYRBADGE and VAR_WEEKDAY == TUESDAY
- Route 31 MAPCALLBACK_NEWMAP fires SPECIALCALL_WORRIED unless EVENT_TALKED_TO_MOM_AFTER_MYSTERY_EGG_QUEST is set by MomScript

**Unresolved (10):**

- Walkthrough's Route 30 'Antidote' does not exist in maps/Route30.asm - the only ground item is a hidden POTION bg_event at (14,9)
- Walkthrough's Route 31 'Potion left of Dark Cave' is actually itemball ANTIDOTE at (29,5); no POTION object exists on Route 31
- Youngster Mikey is L2 PIDGEY + L4 RATTATA in parties.asm, not two Rattata
- Hoppip listed for Route 29 is absent from def_grass_wildmons ROUTE_29
- Zubat and Poliwag listed for Routes 30/31 are not in those grass tables (Poliwag is water/fish, Zubat is Dark Cave)
- Weedle/Kakuna listed for Routes 30-31 are inside the ELIF DEF(_SILVER) arm; a Gold run gets Caterpie/Metapod
- Violet City claims (Onix, TM31, PRZCure Berry) unverified - maps/VioletCity.asm belongs to the next section and was not opened
- Whether the three EVENT_ROUTE_30_BATTLE objects fully seal the west lane depends on maps/Route30.blk collision, which was not decoded
- Port gap: setflag ENGINE_MAP_CARD lands in save.engineFlags while src/ui/gen2/Pokegear.lua reads save.pokegearFlags; no bridge found by grep
- Port gap: OBJECTTYPE_ITEMBALL objects are extracted (obj.itemball) but no runtime code consumes them, so Route 29/31/46 ground items appear un-takeable

### 02. [sprout tower and violet city gym](section-02-sprout-tower-and-violet-city-gym.md)

Maps the Sprout Tower climb (three floors of sages, the elder/rival cutscene coord event at 3F (11,9), Sage Li and HM05 Flash) and the Violet City Gym run (Bird Keepers Abe and Rod, Falkner, ZEPHYRBADGE and TM31 Mud-Slap) onto pokegold, with verbatim warp/coord/bg/object tables, map headers, script control flow, trainer parties with verified prize money, and the Sprout Tower 2F/3F wild tables including the morn/day/nite split. Includes a 28-row bot checklist keyed to asm cell coordinates and a port-coverage audit that flags Poke Ball item pickup as the one genuinely missing runtime path.

**Milestones:** ZEPHYRBADGE (ENGINE_ZEPHYRBADGE, set by VioletGymFalknerScript in maps/VioletGym.asm); HM05 Flash (EVENT_GOT_HM05_FLASH, verbosegiveitem HM_FLASH in SageLiScript, maps/SproutTower3F.asm); TM31 Mud-Slap (EVENT_GOT_TM31_MUD_SLAP, VioletGymFalknerScript.FightDone); Sprout Tower rival cutscene cleared (EVENT_RIVAL_SPROUT_TOWER, scene id -> SCENE_SPROUTTOWER3F_NOOP)

**Maps:** `MAP_SPROUT_TOWER_1F`, `MAP_SPROUT_TOWER_2F`, `MAP_SPROUT_TOWER_3F`, `MAP_VIOLET_CITY`, `MAP_VIOLET_POKECENTER_1F`, `MAP_VIOLET_GYM`

**Gates:**

- Sage Li battle gates HM05 Flash: maps/SproutTower3F.asm:SageLiScript, checkevent EVENT_GOT_HM05_FLASH / iftrue .GotFlash; loadtrainer SAGE, LI then verbosegiveitem HM_FLASH (return NOT checked, a full bag loses the HM)
- Coord event at SPROUT_TOWER_3F (11,9) armed by SCENE_SPROUTTOWER3F_RIVAL_ENCOUNTER (=0, macro-generated in maps/SproutTower3F.asm:12) fires SproutTower3FRivalScene; it is a cutscene with no battle and self-disarms via setscene SCENE_SPROUTTOWER3F_NOOP
- Falkner one-shot: maps/VioletGym.asm:VioletGymFalknerScript, checkevent EVENT_BEAT_FALKNER / iftrue .FightDone
- Out-of-battle Flash requires BOTH ENGINE_ZEPHYRBADGE and wTimeOfDayPalset == DARKNESS_PALSET: engine/events/overworld.asm FlashFunction.CheckUseFlash (03:48f1); the .notadarkcave arm fails the move even with the badge
- ZEPHYRBADGE attack boost / obedience mask: engine/battle/core.asm:6566
- Object visibility polarity: engine/overworld/map_objects_2.asm CheckObjectFlag masks an object when its event flag is SET; Script_disappear sets it (engine/overworld/scripting.asm:887). Applies to EVENT_RIVAL_SPROUT_TOWER and every item ball flag in this section
- Elm's aide in Violet Pokecenter stays hidden all section: EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER is set at new game (engine/events/std_scripts.asm:468) and only cleared by the SPECIALCALL_ASSISTANT phone call queued by beating Falkner (engine/phone/scripts/elm.asm:84)
- No field-move, key-item or NPC-tile blocker exists anywhere in this section; the only hard requirement is winning battles

**Unresolved (8):**

- Walkthrough's Sprout Tower item list says X Accuracy; the asm has only itemball X_DEFEND at SPROUT_TOWER_2F (3,1) (SproutTower2FXDefend). The prose 'X Defense' is right, the header list is wrong.
- Walkthrough claims the item right of the monk on 3F is first a Level 3 Rattata and only later an Escape Rope. Nothing supports this: the object at (14,1) is a plain OBJECTTYPE_ITEMBALL whose label SproutTower3FEscapeRope is a bare 'itemball ESCAPE_ROPE'. No wildbattle, no second object, no branch on EVENT_GOT_HM05_FLASH. Reads like a Gen 1 Rocket Hideout Voltorb import.
- Walkthrough lists Bellsprout as a Sprout Tower wild encounter. data/wild/johto_grass.asm has no SPROUT_TOWER_1F entry at all, and 2F/3F are Rattata (morn/day) and Gastly+Rattata (nite). Bellsprout only appears as sage party members.
- Sage Li's party order differs: walkthrough says Bellsprout 7 / Hoothoot 10 / Bellsprout 7; parties.asm SageGroup 'LI' is Bellsprout 7 / Bellsprout 7 / Hoothoot 10. The quoted 320G only works with the asm order (last party level x base 8 x 4).
- Gym trainer walk order (Abe then Rod) is the reverse of the object_const order in maps/VioletGym.asm (VIOLETGYM_YOUNGSTER1 = Rod, YOUNGSTER2 = Abe). Do not index by object const when following the prose.
- Walkthrough's 'you need the 1st badge to use Flash' is incomplete; the darkness-palset half of FlashFunction.CheckUseFlash is unmentioned.
- Per-Pokemon EXP figures quoted by the walkthrough (54, 108, 126, 217, ...) are computed at runtime from base stats, not stored as constants, so they were not pinned to a single asm line. All seven money figures WERE verified as base reward x last party level x 4.
- PORT GAP (not a walkthrough issue, but load-bearing): OBJECTTYPE_ITEMBALL pickup is unimplemented. src/import/RomExtractorGen2.lua:2969 writes obj.itemball and nothing in src/ reads it; World:interact() (src/world/gen2/World.lua:5257) has no itemball branch and CallAsm.lua:550 stubs TryReceiveItem out deliberately. Every Poke Ball in this section (Parlyz Heal, X Defend, Potion, Escape Rope, PP Up, Rare Candy) renders and masks correctly but cannot be picked up.

### 03. [ruins of alph and union cave](section-03-ruins-of-alph-and-union-cave.md)

Maps the walkthrough's Violet City egg pickup, Ruins of Alph (Kabuto puzzle, Inner Chamber Unown, Research Center #DEX upgrade), the full Route 32 trainer gauntlet, Union Cave 1F/B1F and Route 33 onto pokegold's map asm, with verbatim warp/coord/bg/object tables, map headers, trainer parties, wild tables and the exact flag checks each script performs. Includes a 39-step bot checklist, a gate table citing the enforcing code, and an honest port-coverage table for this repo's Gen 2 work.

**Milestones:** No badge is earned in this section; Togepi EGG obtained (EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE); First Unown puzzle solved (EVENT_SOLVED_KABUTO_PUZZLE / ENGINE_UNLOCKED_UNOWNS_A_TO_K); UNOWN #DEX mode unlocked (ENGINE_UNOWN_DEX); MIRACLE_SEED, TM05 ROAR, OLD_ROD, TM39 SWIFT, POISON_BARB (Friday)

**Maps:** `MAP_VIOLET_POKECENTER_1F`, `MAP_ROUTE_36_RUINS_OF_ALPH_GATE`, `MAP_RUINS_OF_ALPH_OUTSIDE`, `MAP_RUINS_OF_ALPH_KABUTO_CHAMBER`, `MAP_RUINS_OF_ALPH_AERODACTYL_CHAMBER`, `MAP_RUINS_OF_ALPH_INNER_CHAMBER`, `MAP_RUINS_OF_ALPH_RESEARCH_CENTER`, `MAP_ROUTE_32_RUINS_OF_ALPH_GATE`, `MAP_ROUTE_32`, `MAP_ROUTE_32_POKECENTER_1F`, `MAP_UNION_CAVE_1F`, `MAP_UNION_CAVE_B1F`, `MAP_UNION_CAVE_B2F`, `MAP_ROUTE_33`

**Gates:**

- Route 32 coord_event 18,8 SCENE_ROUTE32_COOLTRAINER_M_BLOCKS pushes the player back to Violet until VioletPokecenter1F's setmapscene ROUTE_32, SCENE_ROUTE32_OFFER_SLOWPOKETAIL fires on taking the Togepi EGG
- Elm's Aide only exists after maps/VioletGym.asm:38 specialphonecall SPECIALCALL_ASSISTANT lands and engine/phone/scripts/elm.asm:84 clears EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER
- MIRACLE_SEED needs both ENGINE_ZEPHYRBADGE and EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE (Route32CooltrainerMScript)
- Kabuto chamber floor holes closed by RuinsOfAlphKabutoChamberHiddenDoorsCallback until EVENT_SOLVED_KABUTO_PUZZLE
- Unown never spawn until any ENGINE_UNLOCKED_UNOWNS_* bit is set (engine/overworld/wildmons.asm:341-347); letters filtered by CheckUnownLetter (engine/battle/core.asm:6219)
- Unown #DEX scientist requires VAR_UNOWNCOUNT > 2 plus EVENT_MADE_UNOWN_APPEAR_IN_RUINS and ENGINE_UNOWN_DEX clear (RuinsOfAlphOutsideScientistCallback)
- Aerodactyl chamber needs SURF + ENGINE_FOGBADGE (engine/events/overworld.asm:490)
- Union Cave B1F boulder at 7,10 needs STRENGTH + ENGINE_PLAINBADGE (engine/events/overworld.asm:1033 TryStrengthOW)
- Union Cave Lapras and Route 32 Frieda both require VAR_WEEKDAY == FRIDAY; Lapras additionally once-ever via ENGINE_UNION_CAVE_LAPRAS
- FLASH is NOT required: all three Union Cave floors are PALETTE_NITE, not PALETTE_DARK

**Unresolved (10):**

- Walkthrough lists a Repel on Route 32; maps/Route32.asm has no REPEL anywhere. Likely conflated with data/items/mom_phone.asm MomItems_2 'momitem 4000, 270, MOM_ITEM, REPEL'
- Walkthrough lists Ekans on Routes 32 and 33; EKANS only appears in the ELIF DEF(_SILVER) branches of data/wild/johto_grass.asm. Gold has RATTATA in that slot
- Walkthrough claims Unown has 28 forms including ? and !; constants/pokemon_constants.asm:308 is NUM_UNOWN EQU 26 and forms stop at UNOWN_Z
- Walkthrough says 'talk to the two people inside' the Kabuto chamber; only one object_event exists (RUINSOFALPHKABUTOCHAMBER_RECEPTIONIST at 5,5)
- RuinsOfAlphOutside declares five object consts but only two object_event rows; FISHER/YOUNGSTER2/YOUNGSTER3 are dead
- Walkthrough's Union Cave species list omits SANDSHREW and ONIX, which are in the Gold table; and Route 32 Wooper is morn/nite only, absent from the day table
- Walkthrough's 'X Attack below Bill' and 'Potion to the far left' do not match the coordinates (Bill 15,15; X Attack 4,17; Potion 4,2)
- Could not locate a SPECIALCALL_* scheduler in this repo's port; without it EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER never clears and Route 32 stays permanently blocked
- Did not confirm src/battle/gen2/Encounter.lua reproduces the wUnlockedUnowns == 0 -> no encounter short-circuit from engine/overworld/wildmons.asm
- Route32Pokecenter1FFishingGuruScript sets EVENT_GOT_OLD_ROD without an iffalse bag-full guard after verbosegiveitem (asm behaviour, not a port bug)

### 04. [slowpoke well azalea town gym](section-04-slowpoke-well-azalea-town-gym.md)

Maps the Azalea Town / Slowpoke Well / Azalea Gym stretch onto pokegold: every warp, coord, bg and object row transcribed verbatim from maps/AzaleaTown.asm, maps/KurtsHouse.asm, maps/AzaleaPokecenter1F.asm, maps/SlowpokeWellB1F.asm, maps/SlowpokeWellB2F.asm and maps/AzaleaGym.asm, plus headers, dimensions, connections, all four Rocket grunts and six gym trainers resolved to data/trainers/parties.asm, the wild tables, and the exact EVENT_/ENGINE_ flag chain that Kurt1 and TrainerGruntM1.Script write. Adds derived collision grids decoded from the .blk files so a bot has real walkable routes and proof of the two NPC chokepoints and the Surf-only B2F.

**Milestones:** HIVEBADGE (ENGINE_HIVEBADGE, set by AzaleaGymBugsyScript in maps/AzaleaGym.asm); EVENT_CLEARED_SLOWPOKE_WELL (set by TrainerGruntM1.Script in maps/SlowpokeWellB1F.asm); EVENT_BEAT_BUGSY; EVENT_GOT_TM49_FURY_CUTTER (TM49 Fury Cutter); EVENT_KURT_GAVE_YOU_LURE_BALL (free Lure Ball); ENGINE_FLYPOINT_AZALEA (AzaleaTownFlypointCallback)

**Maps:** `MAP_AZALEA_TOWN`, `MAP_KURTS_HOUSE`, `MAP_AZALEA_POKECENTER_1F`, `MAP_SLOWPOKE_WELL_B1F`, `MAP_SLOWPOKE_WELL_B2F`, `MAP_AZALEA_GYM`

**Gates:**

- Rocket object const 2 at AzaleaTown 31,9 (EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET) is the only walkable cell reaching the Slowpoke Well ladder at 31,7; cleared by talking to Kurt once (Kurt1 first-visit arm setevent)
- Rocket object const 12 at AzaleaTown 10,16 (EVENT_SLOWPOKE_WELL_ROCKETS) is the only walkable cell adjacent to the Azalea Gym warp at 10,15; cleared by the four disappear calls in TrainerGruntM1.Script
- Field CUT requires ENGINE_HIVEBADGE - engine/events/overworld.asm CutFunction.CheckAble (03:47e1) and TryCutOW (03:5193) - so the west exit to Ilex Forest is badge-gated (HM01 itself is section 05)
- L30 obedience gated on the HIVEBADGE bit, engine/battle/core.asm:6566
- SLOWPOKE_WELL_B2F warp at B1F 7,11 sits in a chamber whose only outside neighbour is water at 7,14: Surf-only (King's Rock, TM Rain Dance)
- Strength boulder at SlowpokeWellB1F 3,2 (jumpstd StrengthBoulderScript) - out of section, nothing required behind it

**Unresolved (6):**

- Walkthrough gives Bug Catcher Al 200G; asm formula (base 4 x L12 x 4, engine/battle/read_trainer_party.asm ComputeTrainerReward + the ld c,4 loop and two .DoubleReward calls at engine/battle/core.asm:2340-2361) yields 192G. All eight other money figures match exactly.
- Walkthrough calls Bugsy 'her'/'she'; AzaleaGymGuideText in maps/AzaleaGym.asm says 'his knowledge of bug #MON'.
- Walkthrough's Liz-the-Picnicker Moo Moo Milk phone call could not be located: LizPhoneCallerScript (engine/phone/scripts/trainers.asm:234-254) is generic greet/rematch/random only, and no MOOMOO string exists under engine/phone/.
- Walkthrough lists TM49 under 'Items found in Azalea Town'; it is verbosegiveitem TM_FURY_CUTTER inside AzaleaGymBugsyScript, i.e. in MAP_AZALEA_GYM.
- Walkthrough's 'up the stairs' / 'down the stairs' inside Slowpoke Well has no LADDER/STAIRCASE collision to match - the only two ladder cells on B1F are the two warps (17,15 and 7,11). The trainer order it describes does match the geometry.
- Surf-only B2F access and the claim that Josh/Al/the twins can be walked past in Azalea Gym are both derived from the .blk collision decode plus object sight fields, not asserted by any asm check (the retroactive setevent block in AzaleaGymBugsyScript.FightDone is the only direct evidence that skipping the gym trainers is an anticipated state).

### 05. [ilex forest and goldenrod city gym](section-05-ilex-forest-and-goldenrod-city-gym.md)

Maps the walkthrough's Azalea-rival-through-Whitney stretch onto pokegold: the Azalea Town rival trip-wire, the full ten-position Ilex Forest Farfetch'd herding branch table and the single cuttable block, Route 34 and the Day-Care, then the Goldenrod hub (underground, bike shop, radio tower quiz, dept store, game corner) and the Goldenrod Gym. Every warp, coord, bg and object row is transcribed verbatim from the map asm, with trainer parties, wild tables, badge/field-move gates and a 47-step bot checklist.

**Milestones:** PLAINBADGE (ENGINE_PLAINBADGE) from Whitney in GOLDENROD_GYM; HM01 Cut (EVENT_GOT_HM01_CUT) from the Ilex Forest charcoal master; TM02 Headbutt (EVENT_GOT_TM02_HEADBUTT); TM12 Sweet Scent (EVENT_GOT_TM12_SWEET_SCENT); TM45 Attract (EVENT_GOT_TM45_ATTRACT); BICYCLE (EVENT_GOT_BICYCLE); COIN_CASE (EVENT_GOLDENROD_UNDERGROUND_COIN_CASE); Radio Card (ENGINE_RADIO_CARD); Rival battle 2 cleared (EVENT_RIVAL_AZALEA_TOWN); ENGINE_FLYPOINT_GOLDENROD / ENGINE_REACHED_GOLDENROD

**Maps:** `MAP_AZALEA_TOWN`, `MAP_ILEX_FOREST_AZALEA_GATE`, `MAP_ILEX_FOREST`, `MAP_ROUTE_34_ILEX_FOREST_GATE`, `MAP_ROUTE_34`, `MAP_DAY_CARE`, `MAP_GOLDENROD_CITY`, `MAP_GOLDENROD_POKECENTER_1F`, `MAP_GOLDENROD_DEPT_STORE_1F`, `MAP_GOLDENROD_DEPT_STORE_2F`, `MAP_GOLDENROD_DEPT_STORE_3F`, `MAP_GOLDENROD_DEPT_STORE_4F`, `MAP_GOLDENROD_DEPT_STORE_5F`, `MAP_GOLDENROD_DEPT_STORE_6F`, `MAP_BILLS_FAMILYS_HOUSE`, `MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES`, `MAP_GOLDENROD_UNDERGROUND`, `MAP_GOLDENROD_BIKE_SHOP`, `MAP_GOLDENROD_MAGNET_TRAIN_STATION`, `MAP_RADIO_TOWER_1F`, `MAP_GOLDENROD_GAME_CORNER`, `MAP_GOLDENROD_FLOWER_SHOP`, `MAP_GOLDENROD_GYM`

**Gates:**

- Azalea rival coord events at (5,10)/(5,11) require SCENE_AZALEATOWN_RIVAL_BATTLE, armed by maps/SlowpokeWellB1F.asm:58 after clearing Slowpoke Well
- Ilex Forest Farfetch'd quest and apprentice only exist after EVENT_CLEARED_SLOWPOKE_WELL (SlowpokeWellB1F clears EVENT_ILEX_FOREST_FARFETCHD_1 / EVENT_ILEX_FOREST_APPRENTICE)
- Charcoal master (HM01 giver) only spawns after FarfetchdPosition9 fall-through runs `appear 13` + setevent EVENT_CHARCOAL_KILN_BOSS / EVENT_HERDED_FARFETCHD
- Ilex Forest cut tree: block $0f at block (4,12) = map (8-9,24-25); needs a party mon with CUT and ENGINE_HIVEBADGE (engine/events/overworld.asm CutFunction.CheckAble / TryCutOW)
- Whitney withholds PLAINBADGE while EVENT_MADE_WHITNEY_CRY is set; must walk the coord event at GOLDENROD_GYM (8,5) to run WhitneyCriesScript, then talk again
- Strength field move needs ENGINE_PLAINBADGE (engine/events/overworld.asm StrengthFunction.TryStrength)
- Squirtbottle at GOLDENROD_FLOWER_SHOP needs ENGINE_PLAINBADGE (FlowerShopTeacherScript)
- Route 34 beach trainers Irene/Jenn/Kate and SOFT_SAND need SURF + ENGINE_FOGBADGE
- Goldenrod Underground basement door blocked by changeblock 18,6,$3d until BASEMENT_KEY (BasementDoorScript)
- Bill / Eevee gated on EVENT_MET_BILL (set in Ecruteak); only the phone number is reachable now
- Game Corner prizes need COIN_CASE from the underground item ball at (7,25)
- Officer Keith on Route 34 only battles under checktime NITE
- Underground salon / bargain / bitter merchants gated on VAR_WEEKDAY (and MORN for the bargain merchant)

**Unresolved (11):**

- Bug Catcher Wayne (L8 Ledyba / L10 Paras) is not in pokegold at all - maps/IlexForest.asm has zero OBJECTTYPE_TRAINER rows; only BIKER DWAYNE on Route 8 matches the grep
- X Attack and Antidote claimed in Ilex Forest do not exist; the map holds only a REVIVE item ball at (20,32) and hidden ETHER (27,1), SUPER_POTION (17,7), FULL_HEAL (9,17)
- Walkthrough lists Weedle in Ilex Forest, but Weedle/Kakuna are the ELIF DEF(_SILVER) arm; Gold gets Caterpie/Metapod
- "Youngster Ian will want to trade phone numbers" contradicts TrainerYoungsterIan.Script, which has no askforphonenumber; only Todd and Gina register numbers on Route 34
- Rival party order printed as Gastly/starter/Zubat; Rival1Group entries 4-6 are Gastly L12, Zubat L14, starter L16
- "There's a PC in the corner of the Daycare" - maps/DayCare.asm has no PC bg event or object
- Dept Store 5F "TM02, TM33, TM41, TM48" is conditional: MART_GOLDENROD_5F_1 default is only TM41/TM48/TM33; TM02 needs EVENT_GOT_TM02_HEADBUTT and TM08 needs EVENT_GOT_TM08_ROCK_SMASH
- Whether the Azalea Town rival coord events at (5,10)/(5,11) can be walked around was not verified - requires decoding AzaleaTown.blk collision
- Concrete approach tiles for each Farfetch'd position (turning "do not face <DIR>" into a walkable route) were not derived - needs IlexForest.blk collision
- data/wild/fish.asm has no ILEX_FOREST or ROUTE_34 rows; fishing comes from the header FISHGROUP_* and those group tables were not transcribed
- Money/EXP payouts quoted by the walkthrough are runtime-computed and were not verified against any table

### 06. [bug catching contest and sudowoodo](section-06-bug-catching-contest-and-sudowoodo.md)

Maps the Goldenrod-to-Violet stretch (Squirtbottle, Route 35, National Park and the Bug-Catching Contest, Routes 36/37 and Sudowoodo) onto pokegold, with verbatim warp/coord/bg/object tables, map headers, wild tables, the full contest rule set from engine/events/bug_contest/, and every trainer party resolved to its data/trainers/parties.asm line. Records the four real progress gates (PLAINBADGE for the Squirtbottle, SQUIRTBOTTLE for Sudowoodo, EVENT_FOUGHT_SUDOWOODO for TM08, weekday for the Contest) plus a Route 35 CUT tree located by parsing Route35.blk against data/collision/field_move_blocks.asm.

**Milestones:** No badge earned in this section; SQUIRTBOTTLE key item (EVENT_GOT_SQUIRTBOTTLE); EVENT_FOUGHT_SUDOWOODO - opens Route 36 west<->east; TM08 ROCK SMASH (EVENT_GOT_TM08_ROCK_SMASH); Bug-Catching Contest run: SUN_STONE / EVERSTONE / GOLD_BERRY / BERRY, ENGINE_DAILY_BUG_CONTEST; TM04 ROLLOUT, TM28 DIG, QUICK CLAW, HARD STONE (Thursday), KENYA the SPEAROW + FLOWER MAIL

**Maps:** `MAP_GOLDENROD_FLOWER_SHOP`, `MAP_ROUTE_35_GOLDENROD_GATE`, `MAP_ROUTE_35`, `MAP_ROUTE_35_NATIONAL_PARK_GATE`, `MAP_NATIONAL_PARK`, `MAP_NATIONAL_PARK_BUG_CONTEST`, `MAP_ROUTE_36_NATIONAL_PARK_GATE`, `MAP_ROUTE_36`, `MAP_ROUTE_37`

**Gates:**

- ENGINE_PLAINBADGE gates the SQUIRTBOTTLE - maps/GoldenrodFlowerShop.asm:FlowerShopTeacherScript (57:52d1)
- SQUIRTBOTTLE in the PACK gates Sudowoodo - maps/Route36.asm:SudowoodoScript (4b:61aa) checkitem SQUIRTBOTTLE; the object at cell (35,9) is a solid NPC until disappeared
- engine/events/squirtbottle.asm:_Squirtbottle (14:4763) .CheckCanUseSquirtbottle requires map ROUTE_36 and a faced object with SPRITEMOVEDATA_SUDOWOODO
- EVENT_FOUGHT_SUDOWOODO gates TM08 - maps/Route36.asm:Route36RockSmashGuyScript (4b:61f7)
- ENGINE_HIVEBADGE + CUT gates the east half of Route 35 (block $5b at block(8,3) = cells x16-17 y6-7 in maps/Route35.blk; engine/events/overworld.asm:133 CutFunction.CheckAble)
- VAR_WEEKDAY must be TUESDAY/THURSDAY/SATURDAY and ENGINE_DAILY_BUG_CONTEST clear for the Contest - Route35OfficerScriptContest (56:5e0c) / Route36OfficerScriptContest (56:67cc)
- Contest entry also needs a non-EGG, non-fainted lead and party-or-box room (VAR_PARTYCOUNT / VAR_BOXSPACE / CheckFirstMonIsEgg / ContestDropOffMons)
- VAR_PARTYCOUNT < PARTY_LENGTH gates Kenya - maps/Route35GoldenrodGate.asm:RandyScript (56:59ce)
- checktime NITE gates Officer Dirk - maps/Route35.asm:TrainerOfficerDirk
- VAR_WEEKDAY THURSDAY gates Arthur (Route36ArthurCallback 4b:619e); SUNDAY gates Sunny (Route37SunnyCallback)

**Unresolved (11):**

- Floria running off to fetch the Squirtbottle after being talked to on Route 36 - no such script exists in pokegold; FlowerShopFloriaScript and Route36LassScript are both text-only and the Squirtbottle is gated on ENGINE_PLAINBADGE alone. Looks like Crystal behaviour
- Contest species/levels: walkthrough says Nincada/Volbeat/Wurmple at lv28-31; data/wild/bug_contest_mons.asm has CATERPIE/WEEDLE/METAPOD/KAKUNA/BUTTERFREE/BEEDRILL/VENONAT/PARAS/SCYTHER/PINSIR at lv7-18 (VENOMOTH 30-40 sits on the unreachable -1 terminator row)
- "20 Sport Balls" - the item is PARK_BALL (constants/item_constants.asm:185), BUG_CONTEST_BALLS = 20
- "you can win a Shiny Stone" - first place gives SUN_STONE (std_scripts.asm:346); no Shiny Stone exists in Gen 2
- "a Scyther at full HP may be worth around 342 points" - the formula in ContestScore (04:7cbc) is confirmed but the specific number was not computed
- National Park species list includes Butterfree/Weedle/Kakuna/Beedrill/Paras/Venonat/Scyther/Pinsir; none are in def_grass_wildmons NATIONAL_PARK - they are Contest-only
- The "Routes 36 & 37" item/species lists merge two maps: the apricorns and Ledyba/Spinarak/Pidgeotto are all Route 37, which this section never enters
- "talk to Arnie for HER phone number" - ARNIE1 uses the male phone std scripts
- Liz's Route 32 rematch offer is a phone event on no map in this section; not resolved
- EVENT_FOUGHT_SUDOWOODO is set BEFORE the DRAW check and both branches disappear the tree, so fleeing or fainting it still clears the road and unlocks TM08 - contradicts "catch it or else". A mid-battle black-out was not checked
- maps/NationalParkBugContest.asm warps 2 and 4 both target destination warp 1 (lines 228, 230) rather than 2 - transcribed verbatim, not a typo on my part

### 07. [burned tower and ecruteak city gym](section-07-burned-tower-and-ecruteak-city-gym.md)

Maps the walkthrough's Route 37 -> Ecruteak City -> Goldenrod (Bill's Eevee) -> Dance Theater -> Burned Tower -> Ecruteak Gym stretch onto the pokegold disassembly, with verbatim warp/coord/bg/object tables, map headers and dimensions, script control-flow summaries with their EVENT_*/ENGINE_* flags, resolved trainer parties, and the Route 37 and Burned Tower wild tables. It adds derived collision maps for Burned Tower 1F and Ecruteak Gym that pin the two Rock Smash chokepoints and the exact invisible-floor zig-zag, plus a 31-step bot checklist and an honest port-coverage table.

**Milestones:** FOGBADGE (ENGINE_FOGBADGE, set by EcruteakGymMortyScript after MORTY/MORTY1); HM03 SURF (EVENT_GOT_HM03_SURF, DanceTheaterSurfGuy after all five Kimono Girls); ITEMFINDER (EVENT_GOT_ITEMFINDER, EcruteakItemfinderGuy); TM30 SHADOW BALL (EVENT_GOT_TM30_SHADOW_BALL, EcruteakGymMortyScript.FightDone); EEVEE L20 (EVENT_GOT_EEVEE, BillScript givepoke); TIME CAPSULE (ENGINE_TIME_CAPSULE, Ecruteak Pokecenter Bill cutscene); ENGINE_FLYPOINT_ECRUTEAK (EcruteakCityFlypointCallback); EVENT_RELEASED_THE_BEASTS plus special InitRoamMons (BurnedTowerB1F ReleaseTheBeasts)

**Maps:** `ROUTE_37`, `ECRUTEAK_CITY`, `ECRUTEAK_POKECENTER_1F`, `DANCE_THEATER`, `ECRUTEAK_ITEMFINDER_HOUSE`, `BILLS_FAMILYS_HOUSE`, `BURNED_TOWER_1F`, `BURNED_TOWER_B1F`, `ECRUTEAK_GYM`, `ECRUTEAK_TIN_TOWER_ENTRANCE`

**Gates:**

- EVENT_MET_BILL is set at new game and masks Bill in BILLS_FAMILYS_HOUSE; only the Ecruteak Pokecenter scene-0 cutscene (EcruteakPokcenter1FBillActivatesTimeCapsuleScript) clears it, hard-locking Eevee behind visiting Ecruteak first
- BillScript readvar VAR_PARTYCOUNT / ifequal PARTY_LENGTH -> .NoRoom: a free party slot is required for the Eevee givepoke
- DanceTheaterSurfGuy checks all five EVENT_BEAT_KIMONO_GIRL_{NAOKO,SAYO,ZUKI,KUNI,MIKI} before .GetSurf gives HM_SURF
- Field SURF needs ENGINE_FOGBADGE (engine/events/overworld.asm:340 SurfFunction.TrySurf CheckBadge; :490 TrySurfOW CheckEngineFlag)
- ROCK_SMASH (party move, no badge - AskRockSmashScript / callasm HasRockSmash) is required to smash BurnedTower1F rock at (4,3), the only route to the (10,7) centre pit and therefore to the B1F (9,5) ReleaseTheBeasts coord event
- Second BurnedTower1F rock at (16,13) gates the east loop: Firebreather Ned (16,8) and the BURN_HEAL ball (15,2)
- BURNED_TOWER_B1F has exactly one exit: the LADDER warp at (7,15); warps 1-5 sit on non-warp collisions and cannot be re-entered upward
- Ecruteak Gym invisible floor: 30 warp rows on COLL_PIT tiles all dumping to warp 3 at (4,14); only the exact zig-zag reaches Morty
- EVENT_RIVAL_BURNED_TOWER masks the Burned Tower rival and is set by maps/GoldenrodUndergroundSwitchRoomEntrances.asm:125, which also setmapscenes BURNED_TOWER_1F past the battle - Burned Tower must be done first
- Tin Tower stays sage-blocked until EcruteakGymMortyScript does setmapscene ECRUTEAK_TIN_TOWER_ENTRANCE, SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP
- B1F Strength boulder at (17,4) needs STRENGTH plus PLAINBADGE (AskStrengthScript / TryStrengthOW); nothing required here is behind it
- Bike-shop 'keep the bicycle' call needs STATUSFLAGS2_BIKE_SHOP_CALL_F, PLAYER_BIKE, phone service, and wBikeStep >= HIGH(1024) (engine/overworld/events.asm:1267 DoBikeStep)

**Unresolved (12):**

- Walkthrough says the rival fight is after 'the spiral'; the asm runs BurnedTower1FRivalBattleScene as scene 0 via sdefer on map load, with the rival at (9,12) three cells from the (9,15) door
- Walkthrough says Rock Smash yields 'the HP Up at the northeastern part of the floor'; the NE 1F ball is BURN_HEAL at (15,2), the HP_UP is B1F (4,3) via the NW pits
- Rock Smash being mandatory to reach the beasts is a flood-fill result derived from BurnedTower1F.blk plus tower_collision.asm, not a line of asm; verify on emulator
- EcruteakGym (6,7) has a warp_event row but FLOOR collision (dead row); (6,4) is a PIT with no warp row (safe to stand on). Both derived from the .blk and look like one transposed source row
- Morty's second mon is L21 HAUNTER in MortyGroup, not the walkthrough's L23, so its 567 EXP figure is suspect
- DanceTheaterSurfGuy.GetSurf has no iffalse after verbosegiveitem HM_SURF, unlike every other give in the section - a failed give would still set EVENT_GOT_HM03_SURF
- Both Route 37 twins share EVENT_BEAT_TWINS_ANN_AND_ANNE; EVENT_BEAT_TWINS_ANN_AND_ANNE2 exists but is unreferenced, so only one battle ever happens
- Route 37 twins are declared SPRITE_WEIRD_TREE (consts ROUTE37_WEIRD_TREE1/2), which the new-game init variablesprites to SPRITE_SUDOWOODO; what actually renders was not verified
- BurnedTower1F item ball one-time flags are crossed: the BURN_HEAL ball carries EVENT_BURNED_TOWER_1F_X_SPEED and vice versa
- Ledge (HOP_*) traversal, which Burned Tower B1F is built on, could not be located in the port (no HOP_ matches under src/world/gen2/)
- EcruteakGymActivateRockets branches on VAR_BADGES == 6/7; unexercised on a linear run but a badge-skipping bot will trip it
- Walkthrough EXP and prize-money figures were not checked against engine/battle/ and are deliberately not reproduced

### 08. [olivine lighthouse and cianwood city gym](section-08-olivine-lighthouse-and-cianwood-city-gym.md)

Maps the Route 38 -> Route 39 -> Olivine City -> Olivine Lighthouse -> Route 40 -> Route 41 -> Cianwood City -> Cianwood Gym stretch onto pokegold, with verbatim warp/coord/bg/object tables for all 25 maps, full trainer party data, wild/fish/headbutt/rock-smash tables, and the flag chains behind Moomoo Farm, the Good Rod, HM04 Strength, the Jasmine -> pharmacist Secretpotion gate, Shuckie, the Storm Badge and HM02 Fly. Includes a 71-step bot checklist keyed to raw cell coordinates and an honest port-coverage table for this repo's Gen 2 engine.

**Milestones:** Storm Badge (ENGINE_STORMBADGE) from CianwoodGymChuckScript, maps/CianwoodGym.asm

**Maps:** `MAP_ROUTE_38_ECRUTEAK_GATE`, `MAP_ROUTE_38`, `MAP_ROUTE_39`, `MAP_ROUTE_39_BARN`, `MAP_ROUTE_39_FARMHOUSE`, `MAP_OLIVINE_CITY`, `MAP_OLIVINE_POKECENTER_1F`, `MAP_OLIVINE_GOOD_ROD_HOUSE`, `MAP_OLIVINE_CAFE`, `MAP_OLIVINE_MART`, `MAP_OLIVINE_LIGHTHOUSE_1F`, `MAP_OLIVINE_LIGHTHOUSE_2F`, `MAP_OLIVINE_LIGHTHOUSE_3F`, `MAP_OLIVINE_LIGHTHOUSE_4F`, `MAP_OLIVINE_LIGHTHOUSE_5F`, `MAP_OLIVINE_LIGHTHOUSE_6F`, `MAP_ROUTE_40`, `MAP_ROUTE_41`, `MAP_CIANWOOD_CITY`, `MAP_MANIAS_HOUSE`, `MAP_CIANWOOD_PHARMACY`, `MAP_CIANWOOD_PHOTO_STUDIO`, `MAP_CIANWOOD_POKECENTER_1F`, `MAP_CIANWOOD_LUGIA_SPEECH_HOUSE`, `MAP_CIANWOOD_GYM`

**Gates:**

- Surf to leave Olivine westward: engine/events/overworld.asm:490 TrySurfOW / :340 SurfFunction.TrySurf require ENGINE_FOGBADGE plus a party mon knowing SURF
- Cianwood Gym boulders (3,7)/(4,7)/(5,7): CianwoodGymBoulder -> jumpstd StrengthBoulderScript -> engine/events/overworld.asm:1038 TryStrengthOW requires ENGINE_PLAINBADGE plus STRENGTH; HM04 comes from OlivineCafeStrengthSailorScript in this section
- Secretpotion: maps/CianwoodPharmacy.asm CianwoodPharmacist checks EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS, which is only set by talking to Jasmine on OLIVINE_LIGHTHOUSE_6F
- HM02 Fly: maps/CianwoodCity.asm CianwoodCityChucksWife checks EVENT_BEAT_CHUCK
- Using Fly in the field: engine/events/overworld.asm:545 FlyFunction.TryFly requires ENGINE_STORMBADGE
- Moomoo berries: maps/Route39Barn.asm MoomooScript refuses berries until EVENT_TALKED_TO_FARMER_ABOUT_MOOMOO; TM13 needs EVENT_HEALED_MOOMOO (7 berries)
- Shuckie: maps/ManiasHouse.asm special GiveShuckle fails on a full party
- Olivine rival cut-scene: coord_event (13,12)/(13,13) armed by SCENE_OLIVINECITY_RIVAL_ENCOUNTER = 0, disarmed by setscene SCENE_OLIVINECITY_NOOP
- Ordering trap: CianwoodGymChuckScript.FightDone sets EVENT_BEAT_BLACKBELT_YOSHI/LAO/NOB/LUNG when you take TM01, so the four blackbelts must be fought before Chuck
- Route 41 whirlpools need ENGINE_GLACIERBADGE (engine/events/overworld.asm:1077) but are NOT required to reach Cianwood

**Unresolved (12):**

- Beauty Olivia on Route 38 does not exist in pokegold: no OLIVIA in constants/trainer_constants.asm, no OLIVIA party, and maps/Route38.asm has only five trainer objects
- Voltorb listed as found in Olivine City: the map has no grass table and its water table (data/wild/johto_water.asm:239) is Tentacool/Tentacool/Tentacruel
- Shuckle listed for Route 41: Route 41 is absent from RockMonMaps, has TREEMON_SET_NONE, and its Route41Rock script is marked unreferenced; only Route 40 and Cianwood City carry TREEMON_SET_ROCK (10% Shuckle 15)
- Swimmer Charlie's Tentacool is level 19 in data/trainers/parties.asm, not 21 as the walkthrough says
- Bird Keeper Denis party order is 18 SPEAROW / 20 FEAROW / 18 SPEAROW, not Spearow/Spearow/Fearow
- Swimmer Kaylee (SWIMMERF 3) at ROUTE_41 (17,4) is never mentioned by the walkthrough
- Whether the lighthouse x=16/17 warp pairs are one-way drops or two-way passages cannot be settled from the warp tables (they are symmetric); it depends on TILESET_LIGHTHOUSE block collision and the .blk files, which were not decoded
- Whether Bird Keeper Theo on 3F can actually be avoided depends on the 3F .blk geometry, not the object table
- Route 41's left/right branch split is blk geometry only; no asm data pins the walkthrough's routing prose
- Phone-call beats (Arnie, Liz, Todd, Mom's doll) come from CheckPhoneCall plus data/phone/*.asm and are random; nothing in these maps schedules them
- The 3000G prize from Chuck is computed from data/trainers/attributes.asm, not written in maps/CianwoodGym.asm; arithmetic not verified
- TM23 listed under Olivine City items is Jasmine's gym reward in maps/OlivineGym.asm (section 09), not obtainable on MAP_OLIVINE_CITY

### 09. [olivine city gym](section-09-olivine-city-gym.md)

Maps the Olivine Gym stretch of the Gold walkthrough onto pokegold: the optional Goldenrod Underground haircut detour, the second Olivine Lighthouse climb that hands Jasmine the SECRETPOTION, and the Jasmine gym battle that yields MINERALBADGE and TM23 Iron Tail. Every cited map's warp/coord/bg/object tables are transcribed verbatim, the lighthouse ladder-vs-pit navigation graph is decoded from the .blk files against the tileset collision, and the 3500G payout and 571/1470 EXP claims are derived from the actual reward and base-exp data.

**Milestones:** MINERALBADGE (ENGINE_MINERALBADGE, engine flag id 30); EVENT_BEAT_JASMINE (0x4c1); TM_IRON_TAIL / TM23 (EVENT_GOT_TM23_IRON_TAIL, 0x0d); EVENT_JASMINE_RETURNED_TO_GYM (0x20) - Amphy cured on Lighthouse 6F; 6th-badge trigger: GoldenrodRocketsScript clears EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER

**Maps:** `MAP_GOLDENROD_CITY`, `MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES`, `MAP_GOLDENROD_UNDERGROUND`, `MAP_OLIVINE_CITY`, `MAP_OLIVINE_LIGHTHOUSE_1F`, `MAP_OLIVINE_LIGHTHOUSE_2F`, `MAP_OLIVINE_LIGHTHOUSE_3F`, `MAP_OLIVINE_LIGHTHOUSE_4F`, `MAP_OLIVINE_LIGHTHOUSE_5F`, `MAP_OLIVINE_LIGHTHOUSE_6F`, `MAP_OLIVINE_GYM`

**Gates:**

- EVENT_OLIVINE_GYM_JASMINE must be CLEAR for Jasmine to exist in the gym; set at new game by InitializeEventsScript (engine/events/std_scripts.asm:511), cleared only by OlivineLighthouseJasmine (maps/OlivineLighthouse6F.asm:69)
- SECRETPOTION key item required: checkitem SECRETPOTION at maps/OlivineLighthouse6F.asm:14, and the yesorno at line 29 must be answered Yes (iffalse .Refused aborts, setting nothing)
- ENGINE_STORMBADGE gates FLY at all (engine/events/overworld.asm:544-547, FlyFunction.TryFly -> CheckBadge), plus ENGINE_FLYPOINT_OLIVINE (id 70) / ENGINE_FLYPOINT_GOLDENROD (id 69) set by each town's MAPCALLBACK_NEWMAP
- Lighthouse 4F: the (13,3) ladder is a dead end - you must step into the pit at 4F (8,3)/(9,3) (block $28, PIT collision) and re-climb via 3F warp 3 at (9,5)
- Haircut is weekday-gated: GoldenrodUndergroundCheckDayOfWeekCallback + readvar VAR_WEEKDAY; the 500 older brother exists only TUE/THU/SAT, and ENGINE_GOLDENROD_UNDERGROUND_GOT_HAIRCUT (id 89) allows one cut per day
- TM pocket must have room: verbosegiveitem TM_IRON_TAIL -> iffalse .NoRoomForIronTail leaves EVENT_GOT_TM23_IRON_TAIL unset (retryable by re-talking)

**Unresolved (5):**

- The exact walking path between ladders/pits on Lighthouse 3F/4F/5F was not flood-filled; the ladder and pit coordinates are decoded and verified, but the intermediate route in checklist steps 8-14 is geometric inference
- The walkthrough's 'second/middle shop' is ambiguous because GoldenrodUndergroundCheckDayOfWeekCallback hides different merchants each day; the unambiguous identifier is the 500 price (older brother at (7,14)), and the walkthrough never mentions the TUE/THU/SAT restriction
- The walkthrough implies the 500 cut is the better happiness buy; data/events/happiness_probabilities.asm + happiness_changes.asm show the younger brother's 300 cut has a strictly better jackpot row (+10 vs +5)
- The 571 / 1470 EXP figures reproduce from base-exp bytes via the standard base*level/7*3/2 formula, but the EXP-award routine itself was not opened, so the *3/2 trainer multiplier is arithmetic agreement rather than a code citation
- Jasmine's row in data/trainers/attributes.asm was located by its '; Jasmine' comment (the file has no per-class labels); the 3500G derivation depends on that comment matching constants/trainer_constants.asm ordering

### 10. [the lake of rage and shiny gyarados](section-10-the-lake-of-rage-and-shiny-gyarados.md)

Maps the Ecruteak -> Route 42 -> Mahogany Town -> Route 43 -> Lake of Rage stretch onto pokegold, with verbatim warp/coord/bg/object tables, the trainer party rows, the Gold/Silver-split wild tables, and the flag state that decides who is actually on each map during this section (Lance, the Lake of Rage trainers and the TM36 officer are all masked at this point). Ends on the Red Gyarados encounter (loadwildmon GYARADOS 30 + BATTLETYPE_FORCESHINY, unguarded giveitem RED_SCALE) and LakeOfRageLanceScript, which sets EVENT_DECIDED_TO_HELP_LANCE and arms SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS for the next section.

**Milestones:** No badge in this section; ENGINE_FLYPOINT_MAHOGANY (MahoganyTownFlypointCallback); ENGINE_FLYPOINT_LAKE_OF_RAGE (LakeOfRageFlypointCallback); EVENT_LAKE_OF_RAGE_RED_GYARADOS (Red Gyarados caught or beaten); RED_SCALE obtained; EVENT_DECIDED_TO_HELP_LANCE (arms SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS); EVENT_GOT_TM10_HIDDEN_POWER; EVENT_GOT_BLACKBELT_FROM_WESLEY (Wednesdays only)

**Maps:** `MAP_ECRUTEAK_CITY`, `MAP_ROUTE_42_ECRUTEAK_GATE`, `MAP_ROUTE_42`, `MAP_MAHOGANY_TOWN`, `MAP_MAHOGANY_MART_1F`, `MAP_MAHOGANY_RED_GYARADOS_SPEECH_HOUSE`, `MAP_MAHOGANY_POKECENTER_1F`, `MAP_ROUTE_43_MAHOGANY_GATE`, `MAP_ROUTE_43`, `MAP_ROUTE_43_GATE`, `MAP_LAKE_OF_RAGE`, `MAP_LAKE_OF_RAGE_HIDDEN_POWER_HOUSE`, `MAP_LAKE_OF_RAGE_MAGIKARP_HOUSE`

**Gates:**

- SURF across the two Route 42 lakes and onto the Lake of Rage water: engine/events/overworld.asm:322 SurfFunction .TrySurf checks ENGINE_FOGBADGE via CheckBadge (:50)
- CUT for the Route 42 apricorn trees and the Lake of Rage north-west/north-east item paths: engine/events/overworld.asm:117 CutFunction .CheckAble checks ENGINE_HIVEBADGE then CheckMapForSomethingToCut
- Mahogany east exit to Route 44 blocked unconditionally: maps/MahoganyTown.asm coord_event 19,8 and 19,9 on SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR plus the MAHOGANYTOWN_POKEFAN_M object at (19,8); only engine/events/std_scripts.asm:261 RadioTowerRocketsScript lifts it
- Mahogany Gym door (6,13) blocked by the MAHOGANYTOWN_FISHER object at (6,14) while EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM is clear; maps/TeamRocketBaseB2F.asm:303 sets it
- Route 43 gate toll: maps/Route43Gate.asm scene 0 sdefer Route43GateRocketTakeoverScript, re-armed by Route43CheckIfRocketsScene; takemoney YOUR_MONEY, 1000 runs in BOTH the rich and broke branches (soft gate, always passable)
- Lance not talkable until RedGyarados runs appear LAKEOFRAGE_LANCE (EVENT_LAKE_OF_RAGE_LANCE is set by InitializeEventsScript, engine/events/std_scripts.asm:516)
- Wesley / BLACKBELT_I gated on readvar VAR_WEEKDAY == WEDNESDAY in LakeOfRageWesleyCallback
- Lake of Rage trainers (Andre, Raymond, Aaron, Lois) and the Route43Gate TM36 officer masked by EVENT_LAKE_OF_RAGE_CIVILIANS, set at init and cleared only in maps/TeamRocketBaseB2F.asm:305
- Mahogany Town Lass and Mahogany Mart Granny masked by EVENT_MAHOGANY_MART_OWNERS (set at init)
- Magikarp length contest and its ETHER reward gated behind EVENT_CLEARED_ROCKET_HIDEOUT in MagikarpLengthRaterScript
- RED_SCALE is handed over by an unguarded giveitem in RedGyarados: a full bag loses it silently

**Unresolved (14):**

- Walkthrough calls the Lake of Rage item ball TM43 Secret Power; in GS it is itemball TM_DETECT and the add_tm ladder puts DETECT at TM43
- Walkthrough lists TM16 under 'Items found in Mahogany Town'; no TM16 appears in maps/MahoganyTown.asm (TM16 is ICY_WIND, Pryce's gym reward, a later section)
- Camper Spencer's second mon: walkthrough says L18 Sandslash, data/trainers/parties.asm:2817 says L17
- Walkthrough places Wesley on Route 43's left path; he is object_event 4,4 on MAP_LAKE_OF_RAGE
- Walkthrough says the Route 43 Max Ether is 'to the right of Picnicker Tiffany'; ball is (12,32), Tiffany is (9,29)
- Which tiles are Cut trees / Surf entry points on Route 42 and Lake of Rage is block data (maps/Route42.blk, maps/LakeOfRage.blk) read by CheckMapForSomethingToCut, not any event table; the claim that Route 43's west grass path bypasses ROUTE_43_GATE is likewise unverified from asm
- Mom's phone call on Route 43 is a generic SPECIALCALL, not anything in maps/Route43.asm; which call fires was not pinned down
- Fisher Marvin's L15 Gyarados EXP is left '?' by the walkthrough and is a derived number, not asm data
- LakeOfRage_MapScripts' two scene scripts are commented '; unusable' and RedGyarados does setscene 0 on a map with no scene variable; a port modelling setscene as a per-map byte write should confirm this is harmless
- Route43Gate warp 4 (5,7) points at ROUTE_43 warp 3, the same as warp 3 (4,7) - transcribed as written
- RedGyarados' ifequal LOSE, .NotBeaten only skips the disappear, so giveitem RED_SCALE and appear LAKEOFRAGE_LANCE run even on a loss; reads like a cart quirk but not observed on hardware
- Port gap found while checking coverage: World.lua:4591 sets opts.battleType but World:startBattle (:4420) never reads it, so BATTLETYPE_FORCESHINY does not make the Red Gyarados shiny (only BATTLETYPE_FORCEITEM is handled, at :4576)
- Port gap: movement byte $4c (teleport_from, Lance's exit) has no case in src/script/gen2/Movement.lua decodeByte and falls through to nop
- Port gap: no tests/drivers/gold_* driver covers this stretch

### 11. [team rocket hideout and mahogany town gym](section-11-team-rocket-hideout-and-mahogany-town-gym.md)

Maps the Mahogany Town / Team Rocket Hideout / Mahogany Gym stretch onto pokegold: every warp, coord event, bg event and object event for the six maps, the full B1F trap and camera coordinate tables, the three-floor stairwell topology derived by flood-filling the .blk files, and the decoded Mahogany Gym ice floor with a verified slide-by-slide route to every trainer and to Pryce. Also records the trainer parties, item balls and hidden items, the flag/scene ordering that gates the two password doors and the Electrode room, and an honest port-coverage table flagging BGEVENT_IFNOTSET dispatch and ice sliding as missing.

**Milestones:** GLACIERBADGE (ENGINE_GLACIERBADGE, badge 7, from PRYCE1 in MahoganyGymPryceScript); TM16 Icy Wind (EVENT_GOT_TM16_ICY_WIND); HM06 Whirlpool (EVENT_GOT_HM06_WHIRLPOOL, from RocketBaseElectrodeScript); EVENT_CLEARED_ROCKET_HIDEOUT + clearflag ENGINE_ROCKET_SIGNAL_ON_CH20; EVENT_LEARNED_SLOWPOKETAIL / EVENT_LEARNED_RATICATE_TAIL / EVENT_LEARNED_HAIL_GIOVANNI

**Maps:** `MAP_MAHOGANY_TOWN`, `MAP_MAHOGANY_POKECENTER_1F`, `MAP_MAHOGANY_MART_1F`, `MAP_TEAM_ROCKET_BASE_B1F`, `MAP_TEAM_ROCKET_BASE_B2F`, `MAP_TEAM_ROCKET_BASE_B3F`, `MAP_MAHOGANY_GYM`

**Gates:**

- Hideout entrance: MahoganyMart1FStaircaseCallback needs EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART; the cutscene needs SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS, set by maps/LakeOfRage.asm in the previous section
- B3F Giovanni's office door (bg_event 10,9 / 11,9, TeamRocketBaseB3FLockedDoor) requires BOTH EVENT_LEARNED_SLOWPOKETAIL (GRUNTF_5 at 21,7, sight 0 so she must be talked to) and EVENT_LEARNED_RATICATE_TAIL (GRUNTM_28 at 5,15)
- B2F transmitter door (bg_event 14,12 / 15,12, TeamRocketBaseB2FLockedDoor) requires EVENT_LEARNED_HAIL_GIOVANNI from the Murkrow object at B3F 7,2
- B2F ExecutiveF ambush coord events only exist on SCENE_TEAMROCKETBASEB2F_ROCKET_BOSS, reached only by tripping LanceHealsScript1/2 at 5,14 or 4,13 first
- Electrode room exit blocked by RocketBaseCantLeaveScript / RocketBaseLancesSideScript until all three EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_n are set
- Mahogany Gym door blocked by SPRITE_FISHER at 6,14 until EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM is set by RocketBaseElectrodeScript (object event flags MASK when set, per engine/overworld/map_objects_2.asm CheckObjectFlag)
- Whirlpool field use gated on ENGINE_GLACIERBADGE in engine/events/overworld.asm WhirlpoolFunction.TryWhirlpool (03:4da0) and TryWhirlpoolOW (03:4e41)
- Mahogany Gym floor is COLL_ICE ($23) throughout; crossing it requires the STEP_ICE forced-slide rule in engine/overworld/player_movement.asm

**Unresolved (8):**

- Walkthrough's floor labels are wrong after the first password: it calls the rival encounter and Giovanni's office 'Negative Floor 1' but both are on TEAM_ROCKET_BASE_B3F (left region, reached via B2F warp 2 at 3,2). Verified by flood-filling the .blk files - B2F and B3F are each split into disconnected rooms.
- Boarder Ronald's party order differs (walkthrough Seel/Seel/Dewgong, asm SEEL 24, DEWGONG 25, SEEL 24); same for GRUNTM_18 (walkthrough Rattata/Rattata/Zubat, asm RATTATA 17, ZUBAT 17, RATTATA 17).
- Walkthrough's hideout item list omits the B3F FULL_HEAL (1,12) and DIRE_HIT (3,12) item balls from its header block, and never mentions the two hidden items: REVIVE at B1F 3,11 and FULL_HEAL at B2F 26,7.
- Walkthrough implies two statues on B1F; there are five bg_event statues (24,1 / 6,1 / 24,5 / 8,15 / 22,15) with eight trigger cells, i.e. up to ten camera-grunt battles.
- EVENT_TEAM_ROCKET_BASE_POPULATION is read by all eight SecurityCamera* scripts and is the shared visibility flag of eleven base NPCs, but a full-tree grep finds nothing that ever sets it - those checkevent arms are dead and the base never empties.
- Lance's three right-hand Electrodes (22,5 / 22,7 / 22,9) are never battled; RocketElectrodeN disappears both members of a mirrored pair and the right-hand objects point at the no-op ObjectEvent script.
- Facing direction needed to read the secret switch at B1F 19,11 was inferred from collision (19,11 is WALL, 19,12 is FLOOR) rather than observed; the event is BGEVENT_READ so any adjacent facing should work.
- The Mahogany Gym slide table was produced by simulating the ice rule against the decoded MahoganyGym.blk with NPCs as blockers. It reproduces every direction string in the walkthrough but was not executed in an emulator.

### 12. [team rocket radio tower](section-12-team-rocket-radio-tower.md)

Maps the Team Rocket Radio Tower arc onto pokegold: the 7-badge trigger that spawns the Rockets, all five Radio Tower floors, the Basement Key trip through the Goldenrod Underground into the switch-room shutter puzzle and the Underground Warehouse, and the Card Key return to 3F/4F/5F. Transcribes every warp/coord/bg/object table verbatim, resolves all 27 trainer constants to their party data, derives the shutter puzzle from the wUndergroundSwitchPositions position table, and audits the port for what actually works.

**Milestones:** No badge earned in this section; BASEMENT_KEY (FakeDirectorScript, RADIO_TOWER_5F); CARD_KEY (GoldenrodUndergroundWarehouseDirectorScript); EVENT_CLEARED_RADIO_TOWER + EVENT_TEAM_ROCKET_DISBANDED; RAINBOW_WING (Gold) / SILVER_WING (Silver) from RadioTower5FRocketBossScript; Rival battle 4 (RIVAL1_4_*) in the Goldenrod Underground

**Maps:** `MAP_GOLDENROD_CITY`, `MAP_RADIO_TOWER_1F`, `MAP_RADIO_TOWER_2F`, `MAP_RADIO_TOWER_3F`, `MAP_RADIO_TOWER_4F`, `MAP_RADIO_TOWER_5F`, `MAP_GOLDENROD_UNDERGROUND`, `MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES`, `MAP_GOLDENROD_UNDERGROUND_WAREHOUSE`, `MAP_GOLDENROD_DEPT_STORE_B1F`

**Gates:**

- 7th badge: <Gym>ActivateRockets -> engine/events/std_scripts.asm:255 RadioTowerRocketsScript (readvar VAR_BADGES, ifequal 7) sets ENGINE_ROCKETS_IN_RADIO_TOWER and clears EVENT_RADIO_TOWER_ROCKET_TAKEOVER
- RADIO_TOWER_2F stairs at (0,0): RADIOTOWER2F_BLACK_BELT1 at (0,1), masked by EVENT_RADIO_TOWER_BLACKBELT_BLOCKS_STAIRS (SET = hidden)
- RADIO_TOWER_3F east shutter: bg_event 14,2 BGEVENT_UP -> CardKeySlotScript, checkitem CARD_KEY, sets EVENT_USED_THE_CARD_KEY_IN_THE_RADIO_TOWER; RadioTower3FCardKeyShutterCallback replays the changeblocks
- GOLDENROD_UNDERGROUND locked door at (18,6): BasementDoorScript, checkitem BASEMENT_KEY, sets EVENT_USED_BASEMENT_KEY
- Switch-room shutters: GoldenrodUndergroundSwitchRoomEntrances_UpdateDoors driven by wUndergroundSwitchPositions (01:d6a8); reset to 0 by MAPCALLBACK_NEWMAP on GOLDENROD_UNDERGROUND / GOLDENROD_UNDERGROUND_WAREHOUSE
- RADIO_TOWER_5F boss: coord_event 16,5 only on SCENE_RADIOTOWER5F_ROCKET_BOSS, set by FakeDirectorScript after EXECUTIVEM_3
- EXECUTIVEM_2 at (14,1) physically guards RADIO_TOWER_4F warp 3 (12,0) to 5F
- GOLDENROD_DEPT_STORE_B1F crate layout: EVENT_RECEIVED_CARD_KEY plus EVENT_GOLDENROD_DEPT_STORE_B1F_LAYOUT_1/2/3, frozen until EVENT_GOLDENROD_UNDERGROUND_WAREHOUSE_BLOCKED_OFF is cleared
- No HM field move is required anywhere in this section

**Unresolved (8):**

- Walkthrough says the director gives a Clear Bell; the asm gives RAINBOW_WING (Gold) / SILVER_WING (Silver) via checkver. Clear Bell is a Crystal item.
- Walkthrough claims the shutters remember switch ORDER; wUndergroundSwitchPositions is a plain sum (1+2+3 = 3+2+1 = 6). The real difference is which doors the intermediate positions leave untouched (door 5 at 10,10). Derivation done by hand from the .PositionN arms and should be re-checked on hardware.
- Party orderings differ: walkthrough lists GRUNTF_4 as Ekans/Ekans/Gloom/Oddish (asm: 21 Ekans, 23 Oddish, 21 Ekans, 24 Gloom) and EXECUTIVEF_1 as Arbok/Murkrow/Vileplume (asm: Arbok, Vileplume, Murkrow).
- "the northwesternmost building" resolved by geometry to GoldenrodCity warp 14 at (9,5) plus the UndergroundSignNorth bg_event at (8,6); the walkthrough never names it.
- EXP and money figures in the walkthrough were not verified against the trainer class base-money table.
- EVENT_TEAM_ROCKET_DISBANDED is set only on the Gold branch of RadioTower5FRocketBossScript (line 130), not the Silver branch; its only consumer is the TIN_TOWER_1F sage object mask. Looks intentional but is flagged rather than asserted.
- verbosegiveitem BASEMENT_KEY and verbosegiveitem CARD_KEY have no iffalse bag-full guard.
- Whether (16,6) on RADIO_TOWER_3F is truly unreachable before the shutter opens was not checked against the .blk collision data.

### 13. [ice path and blackthorn city gym](section-13-ice-path-and-blackthorn-city-gym.md)

Maps the Route 44 -> Ice Path -> Blackthorn City -> Blackthorn Gym -> Dragon's Den stretch onto the pokegold disassembly, with verbatim warp/coord/bg/object tables for all sixteen maps, both Strength stone tables, every EVENT_*/ENGINE_* flag the route touches, all thirteen trainer parties and the wild/fish tables. It pins down that the Rising Badge is granted in DragonsDenB1F rather than the gym, that the Den crossing needs Whirlpool rather than Waterfall, and that the port's only structural gap is ice-tile sliding.

**Milestones:** RISINGBADGE (ENGINE_RISINGBADGE, set in maps/DragonsDenB1F.asm DragonsDenB1FDragonFangScript, NOT in the gym); EVENT_BEAT_CLAIR (gym battle won, badge withheld); EVENT_GOT_HM07_WATERFALL (HM07 Waterfall, ICE_PATH_1F (31,7)); EVENT_GOT_TM24_DRAGONBREATH (TM24 Dragonbreath); ENGINE_FLYPOINT_BLACKTHORN (Fly point, BlackthornCityFlypointCallback)

**Maps:** `MAP_ROUTE_44`, `MAP_ICE_PATH_1F`, `MAP_ICE_PATH_B1F`, `MAP_ICE_PATH_B2F_MAHOGANY_SIDE`, `MAP_ICE_PATH_B3F`, `MAP_ICE_PATH_B2F_BLACKTHORN_SIDE`, `MAP_BLACKTHORN_CITY`, `MAP_BLACKTHORN_POKECENTER_1F`, `MAP_BLACKTHORN_MART`, `MAP_BLACKTHORN_EMYS_HOUSE`, `MAP_MOVE_DELETERS_HOUSE`, `MAP_BLACKTHORN_DRAGON_SPEECH_HOUSE`, `MAP_BLACKTHORN_GYM_1F`, `MAP_BLACKTHORN_GYM_2F`, `MAP_DRAGONS_DEN_1F`, `MAP_DRAGONS_DEN_B1F`

**Gates:**

- Blackthorn Gym door (18,11) blocked by BLACKTHORNCITY_SUPER_NERD1 on (18,12) until EVENT_BLACKTHORN_CITY_SUPER_NERD_BLOCKS_GYM is set by maps/RadioTower5F.asm:111-112 (previous section)
- Dragon's Den entrance (20,1) blocked by BLACKTHORNCITY_GRAMPS1 on (20,2) until maps/BlackthornGym1F.asm:54-55 runs after EVENT_BEAT_CLAIR
- Ice Path B1F requires HM04 STRENGTH (ENGINE_PLAINBADGE, engine/events/overworld.asm:941 StrengthFunction.TryStrength) plus the four-boulder stone table in IcePathB1FSetUpStoneTableCallback.StoneTable (boulder N onto warp N+2)
- Ice Path B3F Nevermeltice gated by the SMASHABLE_ROCK at (6,6) -> jumpstd SmashRockScript; ROCK SMASH needs the move only, no badge
- Dragon's Den B1F needs SURF (ENGINE_FOGBADGE) and WHIRLPOOL (ENGINE_GLACIERBADGE, engine/events/overworld.asm:1077); single $07 whirlpool block at maps/DragonsDenB1F.blk block (5,10) = walk cells x10-11 y20-21
- WATERFALL unusable for the whole section: engine/events/overworld.asm:618 checks ENGINE_RISINGBADGE, which this section awards last
- Dragon Fang needs a free bag slot: DragonsDenB1FDragonFangScript giveitem/.BagFullDragonFang aborts the entire badge scene silently
- Master Ball in ElmsLab gated on checkflag ENGINE_RISINGBADGE (maps/ElmsLab.asm:60); specialphonecall SPECIALCALL_MASTERBALL queued in the Den

**Unresolved (10):**

- Route 44 'Max Repel' east of the trainer: the asm ball at (30,8) is Route44MaxRevive -> itemball MAX_REVIVE; no Max Repel object exists on the map
- Psychic Phil's Kadabra is db 26, KADABRA in data/trainers/parties.asm PSYCHIC_T (8); walkthrough says Level 24
- 'Protein' in the Ice Path: no PROTEIN in any of the five Ice Path map files; only IRON (B1F (5,35)) and hidden CARBOS (B2F Mahogany (0,17))
- Clair's party order: asm ClairGroup is Dragonair, Dragonair, Dragonair, Kingdra; walkthrough puts Kingdra third
- All ice-maze direction strings ('up, left, up, right...') and all boulder push counts are .blk block geometry plus CheckIceTile, not map-asm data; not verified
- Walkthrough says Dragon's Den needs Surf and Waterfall; the asm gate is Surf and Whirlpool, and Waterfall is not even usable until the badge this trip awards
- Money rewards (832G, 1000G, 1200G, ...) are computed at runtime from base money x level; no static table located, none verified
- Route 44 and Ice Path item lists in the walkthrough omit MAX_REVIVE, hidden ELIXER, B2F Mahogany MAX_POTION, hidden MAX_POTION, hidden CARBOS and hidden ICE_HEAL
- Which 1F<->2F warp pair the walkthrough means by 'use the warps to return to the entrance' in Blackthorn Gym is ambiguous
- File is section-13 but its own heading reads '---- 19 > Ice Path and Blackthorn City Gym ----'

### 14. [ho oh gold and lugia silver](section-14-ho-oh-gold-and-lugia-silver.md)

Maps the walkthrough's Gold (Tin Tower / Ho-Oh) and Silver (Whirl Islands / Lugia) legendary runs onto pokegold, transcribing every warp, coord, bg and object event row for the Ecruteak Tin Tower entrance corridor, Tin Tower 1F-9F and Roof, and all eight Whirl Islands maps plus Route 41's four island doors. It pins the two one-shot legendary callbacks (RAINBOW_WING / SILVER_WING in bag plus EVENT_FOUGHT_* clear), the checkver level split (L40 in your own version, L70 in the other), every item ball and hidden item with its EVENT_* latch, the Rattata/Gastly and Krabby/Zubat/Seel wild tables, and the real badge checks behind Flash, Surf, Whirlpool, Strength and Waterfall.

**Milestones:** No badge awarded in this section; EVENT_FOUGHT_HO_OH (Gold, TinTowerRoof:TinTowerHoOh, 5b:6913) - one-shot level 40 Ho-Oh holding SACRED_ASH; EVENT_FOUGHT_LUGIA (Silver, WhirlIslandLugiaChamber:Lugia, 47:41a0) - one-shot level 40 Lugia

**Maps:** `MAP_ECRUTEAK_TIN_TOWER_ENTRANCE`, `MAP_ECRUTEAK_TIN_TOWER_BACK_ENTRANCE`, `MAP_TIN_TOWER_1F`, `MAP_TIN_TOWER_2F`, `MAP_TIN_TOWER_3F`, `MAP_TIN_TOWER_4F`, `MAP_TIN_TOWER_5F`, `MAP_TIN_TOWER_6F`, `MAP_TIN_TOWER_7F`, `MAP_TIN_TOWER_8F`, `MAP_TIN_TOWER_9F`, `MAP_TIN_TOWER_ROOF`, `MAP_ROUTE_41`, `MAP_WHIRL_ISLAND_NE`, `MAP_WHIRL_ISLAND_NW`, `MAP_WHIRL_ISLAND_SW`, `MAP_WHIRL_ISLAND_SE`, `MAP_WHIRL_ISLAND_CAVE`, `MAP_WHIRL_ISLAND_B1F`, `MAP_WHIRL_ISLAND_B2F`, `MAP_WHIRL_ISLAND_LUGIA_CHAMBER`

**Gates:**

- ENGINE_FOGBADGE - Ecruteak Gym runs `setmapscene ECRUTEAK_TIN_TOWER_ENTRANCE, SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP` (maps/EcruteakGym.asm:34), which disarms the two sage-blocking coord events at (4,7)/(5,7); the sage's own script only changes its text
- EVENT_TEAM_ROCKET_DISBANDED - TINTOWER1F_SAGE stands on warp 3 at (10,2) (maps/TinTower1F.asm:56) and is only masked once the flag is set at maps/RadioTower5F.asm:130, one opcode after verbosegiveitem RAINBOW_WING
- RAINBOW_WING in bag - TinTowerRoofHoOhCallback (checkitem) refuses to appear Ho-Oh otherwise
- SILVER_WING in bag - WhirlIslandLugiaChamberLugiaCallback (checkitem) refuses to appear Lugia otherwise
- ENGINE_FOGBADGE + SURF - engine/events/overworld.asm:322 SurfFunction, required to reach Route 41 at all
- ENGINE_GLACIERBADGE + WHIRLPOOL - engine/events/overworld.asm:1077 / :1171, the whirlpools ringing the Whirl Islands (badge 7, not 8)
- ENGINE_ZEPHYRBADGE + FLASH - engine/events/overworld.asm:271 FlashFunction, every Whirl Islands map is PALETTE_DARK (data/maps/maps.asm:136-143)
- ENGINE_PLAINBADGE + STRENGTH - WhirlIslandB1FBoulder at (23,26) jumpstd StrengthBoulderScript
- ENGINE_RISINGBADGE + WATERFALL - only to climb back UP the B2F waterfall; descending is free via COLL_WATERFALL forcing DOWN in engine/overworld/player_movement.asm .water_table
- EVENT_FOUGHT_HO_OH / EVENT_FOUGHT_LUGIA are set BEFORE startbattle, so fleeing or blacking out burns the encounter permanently - save first

**Unresolved (9):**

- Walkthrough says Whirlpool needs eight badges; the asm checks ENGINE_GLACIERBADGE (badge 7, Pryce) in both WhirlpoolFunction.TryWhirlpool and TryWhirlpoolOW, and nothing reads VAR_BADGES
- Walkthrough gives Ho-Oh 'Safeguard, Ancient Power, Punishment, Sacred Fire'; HoOhEvosAttacks makes a level 40 Ho-Oh know Sacred Fire, Safeguard, Gust, Recover. AncientPower is level 88 and Punishment does not exist as a Gen 2 move constant
- Walkthrough's Tin Tower items do not match: it lists a PP Up (asm has SUPER_POTION at TinTower4F (17,14)), a Max Potion and Full Heal on the bridge floor (TIN_TOWER_6F has no objects and no bg events at all), and an HP Up (8F has NUGGET and FULL_RESTORE). No PP_UP or HP_UP appears in any TinTower*.asm
- Walkthrough lists 'Max Revive x2' for the Whirl Islands; the asm has exactly one, on B2F at (6,4). It also omits B1F's Full Restore, Carbos and Nugget, the three B1F hidden items, and B2F's Full Restore and Max Elixer
- Every hop/ledge/bridge step sequence is block-layout geometry in the .blk files (TinTower4F.blk..TinTower9F.blk, WhirlIslandB1F.blk, WhirlIslandB2F.blk); I did not decode block data, so those routes are unverified. Warp coordinates are the verified part
- 'The whirlpool just northwest of Swimmer Kara' could not be pinned to an asm row: whirlpool tiles are COLL_WHIRLPOOL entries inside maps/Route41.blk with no coordinate list in maps/Route41.asm. Kara's position (44,28) is verified
- 'The Ho-Oh in-game music' is not a legendary battle theme: engine/battle/start_battle.asm has no legendary case, so the fight uses MUSIC_JOHTO_WILD_BATTLE. The distinctive track is the map's MUSIC_TIN_TOWER, and Whirl Islands play MUSIC_UNION_CAVE
- The '~2% catch rate' figure is unverified (I derived the rate formula inputs, not the shake check): base catch rate 3, Ultra Ball x2, sleep/freeze +10, and burn/poison/paralysis worth nothing due to the reproduced PokeBallEffect bug
- Port gaps found: no forced-tile movement (COLL_WATERFALL / COLL_CURRENT_*) anywhere in src/world/gen2, so the B2F waterfall descent to Lugia's chamber has no implementation; and src/battle/gen2/Catching.lua sets every Apricorn ball multiplier to a flat 1 with no caller supplying conditions, so the Heavy Ball advantage on Lugia is not reproduced. No tests/drivers/gold_* driver exercises either legendary

### 15. [mount mortar and dark cave](section-15-mount-mortar-and-dark-cave.md)

Maps the walkthrough's optional Mt. Mortar and Dark Cave detour onto pokegold, transcribing every warp/coord/bg/object row for the four Mt. Mortar floors and both Dark Cave halves, plus the Kiyo Tyrogue script, the Blackglasses pharmacist script, wild tables and the Flash/Surf/Waterfall/Strength/Rock Smash gates. No badge is won here; the section's only lasting rewards are the free level 10 Tyrogue and the Blackglasses, and nothing in it blocks any later section.

**Milestones:** No badge in this section; EVENT_BEAT_BLACKBELT_KIYO (Blackbelt Kiyo, BLACKBELT_T/KIYO, L34 Hitmonlee + L34 Hitmonchan); EVENT_GOT_TYROGUE_FROM_KIYO (givepoke TYROGUE, 10 - the only Tyrogue in the game); EVENT_GOT_BLACKGLASSES_IN_DARK_CAVE (verbosegiveitem BLACKGLASSES)

**Maps:** `MAP_MOUNT_MORTAR_1F_OUTSIDE`, `MAP_MOUNT_MORTAR_1F_INSIDE`, `MAP_MOUNT_MORTAR_2F_INSIDE`, `MAP_MOUNT_MORTAR_B1F`, `MAP_DARK_CAVE_BLACKTHORN_ENTRANCE`, `MAP_DARK_CAVE_VIOLET_ENTRANCE`, `MAP_MAHOGANY_TOWN`, `MAP_ROUTE_42`, `MAP_BLACKTHORN_CITY`, `MAP_ROUTE_45`, `MAP_ROUTE_31`, `MAP_ROUTE_46`

**Gates:**

- Darkness: all six maps are PALETTE_DARK (data/maps/maps.asm:127-130,148-149); ReplaceTimeOfDayPals .NeedsFlash (23:43e9) forces DARKNESS_PALSET unless STATUSFLAGS_FLASH_F is set. FlashFunction.CheckUseFlash (03:48f1) needs ENGINE_ZEPHYRBADGE. ResetFlashIfOutOfCave (00:2f1d) clears the bit on any ROUTE/TOWN map, so Flash must be re-cast after every exit and every Fly.
- SURF (ENGINE_FOGBADGE, SurfFunction 03:493b / TrySurfOW 03:4a06): Mt. Mortar middle entrance (ROUTE_42 warp 4 at 28,9), the 1F Outside lake, and both Dark Cave water crossings.
- WATERFALL (ENGINE_RISINGBADGE, WaterfallFunction.TryWaterfall 03:4af6 / TryWaterfallOW 03:4b5f): the only route to MOUNT_MORTAR_1F_OUTSIDE warp 4 at (17,5) -> 2F. CheckMapCanWaterfall requires facing UP with wTileUp a waterfall tile.
- STRENGTH (ENGINE_PLAINBADGE, AskStrengthScript 03:4d4e / TryStrengthOW 03:4d7b): boulders at MOUNT_MORTAR_1F_INSIDE (21,43) and MOUNT_MORTAR_B1F (9,10). BIKEFLAGS_STRENGTH_ACTIVE_F is cleared on every map load, so Strength must be re-activated per floor.
- ROCK SMASH (no badge check; HasRockSmash 03:4f7f): the four SPRITEMOVEDATA_SMASHABLE_ROCK objects in DARK_CAVE_VIOLET_ENTRANCE at (16,14), (27,6), (7,14), (36,31).
- Party count: MountMortarB1FKiyoScript does readvar VAR_PARTYCOUNT / ifequal PARTY_LENGTH, .NoRoom - a full party defers the Tyrogue (recoverable, EVENT_BEAT_BLACKBELT_KIYO stays set).
- FLY (ENGINE_STORMBADGE, engine/events/overworld.asm:545) plus ENGINE_FLYPOINT_MAHOGANY / ENGINE_FLYPOINT_BLACKTHORN for the two hops the walkthrough takes.
- Nothing in this section gates any later section - both caves are fully optional.

**Unresolved (12):**

- Walkthrough's Mt. Mortar item list is the HGSS list: Carbos, PP Up, Max Ether and Iron do not exist on any MountMortar*.asm map. TM40 is the right number but the move is TM_DEFENSE_CURL (constants/item_constants.asm:261), not Aerial Ace.
- 'grab the free Iron on the cliff' on 1F Inside has no matching object; nearest are MAX_REVIVE (16,10) and hidden MAX_REPEL (31,9).
- 'surf clockwise around and reach a Hyper Potion and a Max Ether' - no MAX_ETHER in Mt. Mortar. B1F pairs HYPER_POTION (31,17) with FULL_HEAL (4,16); 2F has ELIXER (8,9). Which the author meant is undetermined.
- Kiyo's 816G prize and 1012/1020 EXP figures not verified - money comes from data/trainers/attributes.asm, which was not opened. Party itself is verified.
- 'two items ... Hyper Potion and Escape Rope' in the giant room: MOUNT_MORTAR_1F_INSIDE actually holds three balls plus a hidden MAX_REPEL, though MAX_REVIVE and the hidden item are only reachable from the 2F side.
- 'west entrance and east entrance lead to each other' - all three Route 42 doors land on MOUNT_MORTAR_1F_OUTSIDE; the link runs via MOUNT_MORTAR_1F_INSIDE warp pairs 5/6 and 8/9. The .blk files were not decoded, so only the warp graph is verified, not the walkable path.
- Dark Cave Pokemon list omits DUNSPARCE (slot 7 of DARK_CAVE_VIOLET_ENTRANCE).
- Dark Cave item list places Full Heal (36,22) and Hyper Potion (35,9) on a lobe this route does not pass, omits the hidden ELIXER at (26,3), and omits the POTION (6,8) named in its own prose.
- The rock-smash TREEMON_SET_ROCK table at DARK_CAVE_VIOLET_ENTRANCE (90% Krabby L15, 10% Shuckle L15) is real and unmentioned by the walkthrough.
- MOUNT_MORTAR_1F_OUTSIDE object 2 is itemball GUARD_SPEC but its flag is EVENT_MOUNT_MORTAR_1F_OUTSIDE_REVIVE - verbatim disassembly naming mismatch, not a transcription error.
- Mahogany Town and Blackthorn City interiors were not opened; only their maps.asm header rows and spawn_points.asm entries.
- Port gaps found while writing: OBJECTTYPE_ITEMBALL pickup has no arm in World:interact (all 15 Poke Balls here are unobtainable in the port), ROCK SMASH has no field-move path (CallAsm.lua:526 stubs RockMonEncounter), and ESCAPE_ROPE/DIG are absent from World:useFieldItem.

### 16. [routes 45 46 26 and 27](section-16-routes-45-46-26-and-27.md)

Maps the post-eighth-badge stretch from Blackthorn down Routes 45 and 46, back through New Bark Town for Elm's Master Ball and Everstone, then east across Route 27 and Tohjo Falls to Route 26 and the Victory Road gate badge check. Transcribes every warp/coord/bg/object row verbatim, resolves all 20 trainers to their parties.asm entries, records the wild tables with the Gold/Silver splits, and pins each field-move and script gate to its enforcing label.

**Milestones:** No badge earned in this section; MASTER BALL from Prof. Elm (gated on ENGINE_RISINGBADGE); EVERSTONE from Prof. Elm (gated on EVENT_SHOWED_TOGEPI_TO_ELM); TM37 SANDSTORM (lead-mon happiness >= 150); TM22 SOLARBEAM (Route 27 whirlpool island); MOON STONE (Tohjo Falls); Victory Road Gate eight-badge check passed -> SCENE_VICTORYROADGATE_NOOP

**Maps:** `MAP_ROUTE_45`, `MAP_ROUTE_46`, `MAP_NEW_BARK_TOWN`, `MAP_ELMS_LAB`, `MAP_ROUTE_27`, `MAP_TOHJO_FALLS`, `MAP_ROUTE_27_SANDSTORM_HOUSE`, `MAP_ROUTE_26`, `MAP_ROUTE_26_HEAL_HOUSE`, `MAP_DAY_OF_WEEK_SIBLINGS_HOUSE`, `MAP_VICTORY_ROAD_GATE`, `MAP_DARK_CAVE_BLACKTHORN_ENTRANCE`, `MAP_DARK_CAVE_VIOLET_ENTRANCE`, `MAP_ROUTE_29_ROUTE_46_GATE`

**Gates:**

- SURF + ENGINE_FOGBADGE to cross New Bark Town -> Route 27 and the Route 27 east water (engine/events/overworld.asm TrySurfOW)
- WATERFALL + ENGINE_RISINGBADGE for Tohjo Falls (engine/events/overworld.asm TryWaterfallOW + CheckMapCanWaterfall)
- WHIRLPOOL + ENGINE_GLACIERBADGE for the Route 27 island with TM22 and Bird Keeper Jose (engine/events/overworld.asm TryWhirlpoolOW)
- Master Ball: maps/ElmsLab.asm ElmCheckMasterBall -> checkflag ENGINE_RISINGBADGE, plus a free bag slot for verbosegiveitem
- Everstone: maps/ElmsLab.asm ElmCheckEverstone -> Togepi/Togetic must be IN THE PARTY (special FindPartyMonThatSpeciesYourTrainerID), not in the PC
- TM37 SANDSTORM: maps/Route27SandstormHouse.asm SandstormHouseWoman -> special GetFirstPokemonHappiness / ifgreater 150 - 1 (first non-egg party member only)
- Victory Road Gate: maps/VictoryRoadGate.asm _VictoryRoadGateBadgeCheckScript -> readvar VAR_BADGES / ifgreater NUM_JOHTO_BADGES - 1; soft fail pushes the player one step DOWN
- SCENE_ROUTE27_FIRST_STEP_INTO_KANTO coord events at (18,10) and (19,10) are unskippable on first entry

**Unresolved (10):**

- Camper Quentin (27 Fearow / 30 Primeape / 30 Tauros) does not exist anywhere in pokegold; no camper object on Route 45. The unmentioned trainer there is Hiker Michael.
- The 'Nugget' the walkthrough puts on Route 45 does not exist; the only hidden item is hiddenitem PP_UP, EVENT_ROUTE_45_HIDDEN_PP_UP at (13, 80).
- Route 27 Rare Candy is at cell (53, 12), well east of both Tohjo Falls entrances, but the walkthrough places it before entering the falls. Water continuity from the landing point was not verified against Route27.blk.
- Cooltrainer Gaven's second mon is KINGLER in data/trainers/parties.asm, not Krabby.
- Cooltrainer Reena's asm party order is STARMIE / NIDOQUEEN / STARMIE, not STARMIE / STARMIE / NIDOQUEEN.
- Hiker Erik's asm party order is MACHOP / GRAVELER / MACHOP, not Machop / Machop / Graveler.
- Walkthrough wild lists are a Gold/Silver merge: Route 46 also has Jigglypuff, Tohjo Falls also has Zubat/Golbat/Raticate/Goldeen, and Arbok is Silver-only on Routes 26/27 where Gold has Sandslash and Dodrio.
- The Tohjo Falls MOON STONE item ball at (2, 6) is never mentioned by the walkthrough.
- 'Head down the other waterfall' has no engine equivalent; descent is a COLL_CURRENT_DOWN ($3b) tile. Whether the port's World:waterfallStep handles the descend direction was not verified.
- Port gap, not a walkthrough gap: OBJECTTYPE_ITEMBALL objects are extracted (obj.itemball) but nothing in src/world/ consumes them, so all nine item balls in this section are unobtainable in the port today.

### 17. [victory road](section-17-victory-road.md)

Documents Gold/Silver Victory Road, which is a single 10x36-block map (20x72 cells) whose "floors" are self-warps, plus the VictoryRoadGate badge check that guards it: full warp / coord / bg / object tables, the rival ambush scripts and their three starter-dependent RIVAL1 parties, all seven items, the Kanto-table wild data, and a decoded per-cell collision map that pins every ladder, pit and one-way ledge. Port coverage is data-driven through RomExtractorGen2 and the Gen 2 VM, but Poke Ball pickup and ledge hops are missing in the port and no driver walks this map.

**Milestones:** No badge in this section; Final RIVAL1 battle won (EVENT_RIVAL_VICTORY_ROAD set, wVictoryRoadSceneID -> SCENE_VICTORYROAD_NOOP); TM26 Earthquake obtained (EVENT_VICTORY_ROAD_TM_EARTHQUAKE); North exit onto Route 23 reached; Route23FlypointCallback sets ENGINE_FLYPOINT_INDIGO_PLATEAU

**Maps:** `MAP_VICTORY_ROAD`, `MAP_VICTORY_ROAD_GATE`, `MAP_ROUTE_23 (exit only, next section)`

**Gates:**

- 8 Johto badges: VictoryRoadGateBadgeCheckScript / _VictoryRoadGateBadgeCheckScript in maps/VictoryRoadGate.asm reads VAR_BADGES (engine/overworld/variables.asm:80 .CountBadges, CountSetBits over 2 bytes) and requires ifgreater NUM_JOHTO_BADGES - 1; failure applies one step DOWN. Coord event (10,11) is a mandatory chokepoint (row 11 walkable only at x=8, occupied by the officer, and x=10)
- Rival ambush: coord events (12,8) and (13,8) gated on SCENE_VICTORYROAD_RIVAL_BATTLE cover the entire corridor to the exit warp at (13,5)
- TM26 Earthquake at (3,28) is geometry-gated: the y=26..30 pocket has exactly one entrance, the COLL_PIT at (0,11) (warp 8, one-way; warp 9 at (0,27) sits on COLL_FLOOR and never fires)
- Full Restore at (18,29) is geometry-gated: the shelf is entered only via warp 7 (17,19) -> (17,33), and exited only by the one-way HOP_DOWN ledge at y=34, x=16..19
- Reaching ladder (17,19) on the cart requires the one-way HOP_RIGHT at (8,20)/(8,21)
- No field move gate at all: no cut tree, water, boulder or whirlpool tiles, and the header palette is PALETTE_NITE not PALETTE_DARK, so Flash is not required
- VictoryRoadGate black belts at (7,5) and (12,5) physically plug the only east-west corridor (gate row 5) until EVENT_OPENED_MT_SILVER / EVENT_FOUGHT_SNORLAX (later sections)

**Unresolved (10):**

- FAQ says Level 34 Magneton; asm has 35 in RIVAL1 (13) and (14), 34 only in RIVAL1 (15) (the Feraligatr set)
- FAQ lists the rival's starter fourth; asm order is Sneasel, Golbat, Magneton, Haunter, Kadabra, starter last
- FAQ's 2280G prize and per-mon EXP were not verified (trainer class attribute / base money table not opened)
- FAQ wild list omits Onix (L34 and L36) and Gold's Ursaring (L33), which Silver replaces with Donphan
- FAQ item list omits the hidden Max Potion at (3,29) and conflates the itemball Full Heal (15,48) with the hidden Full Heal (3,65)
- FAQ's "stairway" has no COLL_STAIRCASE anywhere in the decoded map; only ladders, one pit and five ledges exist
- FAQ's "head back up the ladder" after TM26 has no ladder in that pocket; the two exits are HOP_RIGHT at (8,28)/(8,29) and HOP_DOWN at (2,30)/(3,30)
- X Special ball at (7,38) sits on a COLL_HOP_LEFT tile walled on both sides and above; reachable by walking north from (7,42) because ledge tiles are LAND_TILE, but worth confirming in an emulator
- Gate black belts as physical blockers is inferred from the decoded gate collision plus NPC solidity, not stated in any script
- Port object masking polarity (hidden when the event flag is SET, per CheckObjectFlag) was not tested against src/world/gen2/Npc.lua

### 18. [pok mon league](section-18-pok-mon-league.md)

Maps the Pokémon League stretch (Victory Road exit -> Route 23 -> Indigo Plateau Pokecenter -> Will/Koga/Bruno/Karen/Lance rooms -> Hall of Fame -> credits) onto pokegold, with verbatim warp/coord/bg/object tables, map headers, the door-lock changeblock mechanics, every EVENT_/ENGINE_/SCENE_ flag the run touches, and the five Elite Four parties with class items, DVs and the real GS prize money. Also records the port's coverage (data-driven maps/scripts/battles are in, the post-credits SPAWN_NEW_BARK respawn is coded but has no caller, and no Gold driver walks the League) and flags that the walkthrough's parties, held items, move sets and money figures are HeartGold/SoulSilver values that contradict the asm.

**Milestones:** No badge awarded in this section; EVENT_BEAT_ELITE_4_WILL; EVENT_BEAT_ELITE_4_KOGA; EVENT_BEAT_ELITE_4_BRUNO; EVENT_BEAT_ELITE_4_KAREN; EVENT_BEAT_CHAMPION_LANCE; EVENT_BEAT_ELITE_FOUR (durable League-cleared flag, set in HallOfFameEnterScript); STATUSFLAGS_HALL_OF_FAME_F (Hall of Fame induction; unlocks Kanto Pokegear map); ENGINE_FLYPOINT_INDIGO_PLATEAU (fly point, also gates the Kanto Fly map)

**Maps:** `MAP_ROUTE_23`, `MAP_INDIGO_PLATEAU_POKECENTER_1F`, `MAP_WILLS_ROOM`, `MAP_KOGAS_ROOM`, `MAP_BRUNOS_ROOM`, `MAP_KARENS_ROOM`, `MAP_LANCES_ROOM`, `MAP_HALL_OF_FAME`

**Gates:**

- 8 Johto badges at maps/VictoryRoadGate.asm:_VictoryRoadGateBadgeCheckScript (readvar VAR_BADGES / ifgreater NUM_JOHTO_BADGES - 1) - precondition set in the previous section
- Each Elite Four room seals its south door on entry: <Room>DoorLocksBehindYouScript changeblock 4,14,$2a (Lance: 4,22,$34) + EVENT_*_ROOM_ENTRANCE_CLOSED, re-applied by MAPCALLBACK_TILES - no retreat to the lobby to heal
- Each room's north door needs that member beaten: <X>Script_Battle changeblock 4,2,$16 + EVENT_*_ROOM_EXIT_OPEN
- Lance is only reachable via the coord events at (4,5)/(5,5) gated on SCENE_LANCESROOM_APPROACH_LANCE, which only the entry lock script sets
- IndigoPlateauPokecenter1FPrepareElite4Callback (MAPCALLBACK_NEWMAP) clears all five EVENT_BEAT_ELITE_4_* and re-arms every door-lock scene - re-entering the lobby restarts the gauntlet
- Losing is a full blackout: every fight uses winlosstext <win>, 0 with no BATTLETYPE_CANLOSE
- No HM field move is required anywhere in this section
- Hazard, not a gate: PlateauRivalBattle1/2 at (16,4)/(17,4) fire only with EVENT_BEAT_RIVAL_IN_MT_MOON set, ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT clear, and VAR_WEEKDAY in {MONDAY, WEDNESDAY}

**Unresolved (13):**

- Walkthrough says 'Route 32' for the map between Victory Road and the Plateau; it is MAP_ROUTE_23 (constants/map_constants.asm:322)
- Elite Four send-out orders differ: asm Will is Xatu/Jynx/Exeggutor/Slowbro/Xatu, Koga is Ariados/Venomoth/Forretress/Muk/Crobat, Bruno is Hitmontop/Hitmonlee/Hitmonchan/Onix/Machamp - the FAQ lists HGSS orders
- Prize money: FAQ quotes 4200/4400/4600/4700/5000G (100 x level, HGSS). GS pays base reward 25 x last mon level = 1050/1100/1150/1175/1250 (ComputeTrainerReward, engine/battle/read_trainer_party.asm:300)
- Held/AI items: FAQ claims Koga and Lance carry three Full Restores, Karen one, plus Sitrus Berries on Houndoom and a Dragonite. GS parties are TRAINERTYPE_MOVES (no held-item field) and the class rows are Will/Bruno MAX_POTION, Karen FULL_HEAL+MAX_POTION (no Full Restore), Koga/Champion FULL_HEAL+FULL_RESTORE. Sitrus Berry does not exist in Gen 2
- FAQ's 'Dragon Rush' on Lance's Dragonites is a Gen 4 move; GS movesets are Thunder Wave/Twister/Thunder-or-Blizzard/Hyper Beam and Fire Blast/Safeguard/Outrage/Hyper Beam
- Per-Pokemon EXP figures in the FAQ were not checked against data/pokemon/base_stats/ and are presumed HGSS
- 'Routes 46 and 47' - ROUTE_47 does not exist in pokegold (constants/map_constants.asm has ROUTE_45 and ROUTE_46 only)
- Move Deleter claim: maps/MoveDeletersHouse.asm exists and is reached from maps/BlackthornCity.asm, but its script was not read
- The Indigo Plateau 'Abra' object is declared SPRITE_JYNX (maps/IndigoPlateauPokecenter1F.asm:324) with script AbraScript and cry ABRA; no SPRITE_ABRA exists and no variablesprite rewrites it in std_scripts.asm's init block
- EVENT_LANCES_ROOM_EXIT_OPEN is read by LancesRoomDoorsCallback and cleared by the lobby callback but never set by any script; the champion's door is opened by a bare changeblock 4,0,$0b that does not survive a reload
- LancesRoomLanceScript re-sets EVENT_LANCES_ROOM_ENTRANCE_CLOSED after the battle, where EVENT_LANCES_ROOM_EXIT_OPEN was apparently intended
- PlateauRivalPostBattle's setscene writes 0 over 0 (the map declares one scene), so the rival coord events stay armed; only the engine flag and weekday check actually gate the fight
- Port gap: HallOfFame.consumePostGameSpawn (src/core/gen2/HallOfFame.lua:254) is unit-tested but has no caller in src/, so the post-credits SPAWN_NEW_BARK respawn does not happen in the port

### 19. [s s aqua and vermilion city gym](section-19-s-s-aqua-and-vermilion-city-gym.md)

Maps the walkthrough's post-Hall-of-Fame stretch (Elm's S.S. Ticket, the Fast Ship S.S. Aqua crossing from Olivine to Vermilion, and the Vermilion City gym) onto the pokegold disassembly, with verbatim warp/coord/bg/object tables for all fourteen maps involved, the script control flow and EVENT_*/ENGINE_* flags each beat reads and writes, resolved trainer parties, and the wild/fishing tables at both ports. Also records the exact cut-tree block and collision quad in Vermilion City, which contradicts the walkthrough's claim that the tree blocks the gym.

**Milestones:** THUNDERBADGE (ENGINE_THUNDERBADGE) from LT_SURGE/LT_SURGE1 in VermilionGymSurgeScript; S_S_TICKET from ElmGiveTicketScript (EVENT_GOT_SS_TICKET_FROM_ELM); METAL_COAT from SSAquaMetalCoatAndDocking (EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA); RARE_CANDY from PokemonFanClubChairmanScript (EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT); ENGINE_FLYPOINT_VERMILION via VermilionPortFlypointCallback / VermilionCityFlypointCallback; First Kanto crossing completed: EVENT_FAST_SHIP_FIRST_TIME set by VermilionPortLeaveShipScript

**Maps:** `MAP_NEW_BARK_TOWN`, `MAP_ELMS_LAB`, `MAP_OLIVINE_CITY`, `MAP_OLIVINE_PORT_PASSAGE`, `MAP_OLIVINE_PORT`, `MAP_FAST_SHIP_1F`, `MAP_FAST_SHIP_CABINS_NNW_NNE_NE`, `MAP_FAST_SHIP_CABINS_SW_SSW_NW`, `MAP_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN`, `MAP_FAST_SHIP_B1F`, `MAP_VERMILION_PORT`, `MAP_VERMILION_PORT_PASSAGE`, `MAP_VERMILION_CITY`, `MAP_POKEMON_FAN_CLUB`, `MAP_VERMILION_GYM`

**Gates:**

- EVENT_BEAT_ELITE_FOUR required before ProfElmScript reaches ElmGiveTicketScript (set by maps/HallOfFame.asm:33)
- checkitem S_S_TICKET in OlivinePortWalkUpToShipScript / OlivinePortSailorAfterHOFScript gates boarding
- EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME must be clear for the boarding sailor to exist (HallOfFame.asm:38); before that OlivinePortSailorBeforeHOFScript refuses entry
- VAR_WEEKDAY gate on repeat trips: Monday/Friday from Olivine, Wednesday/Sunday from Vermilion; bypassed on the maiden voyage via EVENT_FAST_SHIP_FIRST_TIME
- FastShipB1F sailor object at (30,6)/(31,6) plus coord events (30,7)/(31,7) under SCENE_FASTSHIPB1F_SAILOR_BLOCKS; cleared by FastShipLazySailorScript setmapscene SCENE_FASTSHIPB1F_NOOP
- EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR set at new game hides the lazy sailor until FastShipB1FSailorScript clears it
- Ship will not dock on the maiden voyage until SSAquaMetalCoatAndDocking sets EVENT_FAST_SHIP_HAS_ARRIVED / EVENT_FAST_SHIP_FOUND_GIRL; FastShip1FSailor1Script checks EVENT_FAST_SHIP_HAS_ARRIVED and FastShipBed.CanArrive needs FOUND_GIRL or FIRST_TIME
- PokemonFanClubChairmanScript yesorno: answering No skips the RARE_CANDY entirely
- ENGINE_THUNDERBADGE checkflag makes VermilionGymSurgeScript one-shot
- ENGINE_HIVEBADGE + CUT required for the Vermilion City cut tree (engine/events/overworld.asm:133/:169) - optional, only exposes the hidden FULL_HEAL
- special SnorlaxAwake blocks VermilionCity warp 10 to DIGLETTS_CAVE (out of scope for this section)

**Unresolved (10):**

- Walkthrough says a tree blocks the Vermilion Gym; the only cut tree is TILESET_KANTO block $35 at block (6,9), CUT_TREE quadrant cell (13,18), while the gym door is cell (10,19) with FLOOR tiles south of it - the tree gates nothing but the hidden FULL_HEAL at (12,19)
- "Meal Coat" is a typo for METAL_COAT
- Lt. Surge party order differs: asm is Raichu/Electrode/Magneton/Electrode/Electabuzz, walkthrough lists Raichu/Magneton/Electabuzz/Electrode/Electrode
- Juggler Fritz party order differs: asm is Mr. Mime/Magmar/Machoke, walkthrough says Mr. Mime/Machoke/Magmar
- "Lt. Surge has a Full Restore" could not be confirmed - his party entry is TRAINERTYPE_MOVES and carries no held item; AI item lists in data/trainers/attributes.asm were not opened
- Prize money (1056G, 4600G, etc.) and EXP values are runtime calculations, not table literals; not reproduced
- EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT_BUT_BAG_WAS_FULL is read by PokemonFanClubChairmanScript but never set anywhere found by grep
- "New Pokemon music for Kanto" - the Vermilion maps use MUSIC_VERMILION_CITY; not checked against the audio engine
- FastShipB1F prose route order ("head left, then down") was not re-walked tile by tile
- Water/fishing encounter handling at the ports was not verified against src/battle/gen2/Encounter.lua in this pass

### 20. [saffron city gym](section-20-saffron-city-gym.md)

Maps the walkthrough's Route 6 -> Saffron City -> Saffron Gym stretch onto the pokegold disassembly, with verbatim warp/bg/object tables for all eleven maps, the full 30-pad Saffron Gym teleporter graph resolved to landing coordinates, and the scripts, flags, items and trainer parties each beat depends on. Ends with a 23-step bot checklist, the gate list (Underground Path NPC body, Magnet Train power event, gym maze), and an honest port-coverage audit against src/world/gen2, src/script/gen2 and src/battle/gen2.

**Milestones:** MARSHBADGE (ENGINE_MARSHBADGE, constants/engine_flags.asm:52, set by SaffronGymSabrinaScript at maps/SaffronGym.asm:35); ENGINE_FLYPOINT_SAFFRON unlocked by SaffronCityFlypointCallback (MAPCALLBACK_NEWMAP, maps/SaffronCity.asm:17); EVENT_BEAT_SABRINA plus the four gym-trainer flags force-set by the Sabrina script

**Maps:** `MAP_ROUTE_6`, `MAP_ROUTE_6_UNDERGROUND_PATH_ENTRANCE`, `MAP_ROUTE_6_SAFFRON_GATE`, `MAP_SAFFRON_CITY`, `MAP_MR_PSYCHICS_HOUSE`, `MAP_SILPH_CO_1F`, `MAP_SAFFRON_MAGNET_TRAIN_STATION`, `MAP_SAFFRON_MART`, `MAP_FIGHTING_DOJO`, `MAP_SAFFRON_GYM`, `MAP_SAFFRON_POKECENTER_1F`

**Gates:**

- Underground Path shut: ROUTE6_POKEFAN_M object body at Route 6 (17,4) sits on the door at (17,3); masked only when EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH is set by maps/PowerPlant.asm:164 (CheckObjectFlag, engine/overworld/map_objects_2.asm:32)
- Magnet Train dead: SaffronMagnetTrainStationOfficerScript checks EVENT_RESTORED_POWER_TO_KANTO then checkitem PASS (maps/SaffronMagnetTrainStation.asm:19,30); both false in this section
- Silph Co upper floors permanently blocked: SILPHCO1F_OFFICER at (13,1) with event flag -1 and no stairs warp in SilphCo1F's def_warp_events
- Saffron Gym maze: 30 teleport-panel warps (maps/SaffronGym.asm:296-326); the only pad reaching Sabrina is (1,5) -> (11,9), the only exit is (11,9) -> (1,5). No badge or flag check anywhere in the gym
- MARSHBADGE re-fight guard: checkflag ENGINE_MARSHBADGE / iftrue .FightDone at maps/SaffronGym.asm:17
- No HM field move is required anywhere in this section

**Unresolved (7):**

- Psychic Jared's third Pokemon is L35 EXEGGCUTE in data/trainers/parties.asm:2573, not L32 as the walkthrough claims (asm contradicts walkthrough)
- Per-Pokemon EXP figures (765, 1237, 1149, 735, 672, 720, 1264, 1941, 1339, 1912) were not checked against data/pokemon/base_stats/
- 'PokeMart in the upper-right corner' - the mart door is warp 3 at (25,11) on a 40x36-cell map, north-of-centre rather than the corner
- 'Silph Co, the multi-story building above the Pokemon Center' - Silph warp is (18,21), Pokecenter (9,29), so north-east not above; SilphCo1F has no stairs warp and no upper floor exists in Gen 2
- 'You now have 10 badges' - ENGINE_MARSHBADGE is bit 5 of wKantoBadges, the 6th Kanto badge in flag order; the count of 10 depends on the FAQ's chapter order, which nothing in the asm enforces
- The vague mid-maze heal route ('left/right whichever way works till you find Franklin') was not reduced to a pad sequence; the post-heal route it gives does resolve and is recorded
- The 'too weak to move your own boulders' taunt has no counterpart in Route6PokefanMText, which only mentions the Power Plant

### 21. [power plant and cerulean city gym](section-21-power-plant-and-cerulean-city-gym.md)

Maps the Kanto Machine Part chain and the Cerulean Gym onto pokegold: Route 5 (Cleanse Tag house) north to Cerulean, east across Route 9 to Route 10 North, Surf to the Power Plant, then the grunt cutscene in Cerulean Gym, the Route 24 Rocket battle, Route 25's six-pack trainers plus Kevin, Bill's grandpa, and finally Misty for CASCADEBADGE. Every warp/coord/bg/object table is transcribed verbatim, with the EVENT_TRAINERS_IN_CERULEAN_GYM / EVENT_CERULEAN_GYM_ROCKET / EVENT_ROUTE_24_ROCKET / EVENT_ROUTE_25_MISTY_BOYFRIEND state machine traced through InitializeEventsScript, PowerPlantManager, CeruleanGymGruntRunsOutScript and Route25MistyDate1Script.

**Milestones:** CASCADEBADGE (ENGINE_CASCADEBADGE, set by CeruleanGymMistyScript in maps/CeruleanGym.asm); EVENT_BEAT_MISTY; EVENT_MET_MANAGER_AT_POWER_PLANT (starts the Machine Part chain); EVENT_MET_ROCKET_GRUNT_AT_CERULEAN_GYM; EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM (hidden MACHINE_PART obtained at CeruleanGym 3,8); EVENT_CLEARED_NUGGET_BRIDGE (Kevin's Nugget on Route 25); EVENT_GOT_CLEANSE_TAG

**Maps:** `MAP_ROUTE_5`, `MAP_ROUTE_5_SAFFRON_GATE`, `MAP_ROUTE_5_CLEANSE_TAG_HOUSE`, `MAP_ROUTE_5_UNDERGROUND_PATH_ENTRANCE`, `MAP_CERULEAN_CITY`, `MAP_CERULEAN_GYM`, `MAP_ROUTE_9`, `MAP_ROUTE_10_NORTH`, `MAP_POWER_PLANT`, `MAP_ROUTE_24`, `MAP_ROUTE_25`, `MAP_BILLS_HOUSE`

**Gates:**

- CUT at the Route 9 west entrance and the Route 25 tree above Super Nerd Pat: engine/events/overworld.asm:117 CutFunction .CheckAble checks ENGINE_HIVEBADGE then CheckCutCollision (engine/overworld/tile_events.asm:76)
- SURF to reach the Power Plant door at ROUTE_10_NORTH warp 2 (3,9): engine/events/overworld.asm:322 SurfFunction .TrySurf checks ENGINE_FOGBADGE; overworld A-press path TrySurfOW at :469
- FLY back to Cerulean twice: engine/events/overworld.asm:529 FlyFunction checks ENGINE_STORMBADGE at :545; destination needs ENGINE_FLYPOINT_CERULEAN set by CeruleanCityFlypointCallback
- Cerulean Gym is empty until Route 25: all gym object rows carry EVENT_TRAINERS_IN_CERULEAN_GYM, set by InitializeEventsScript (engine/events/std_scripts.asm:550), cleared only by Route25MistyDate1Script/Route25MistyDate2Script (maps/Route25.asm:48/:74)
- Cerulean Gym Rocket grunt does not exist until PowerPlantManager clears EVENT_CERULEAN_GYM_ROCKET and does setmapscene CERULEAN_GYM, SCENE_CERULEANGYM_GRUNT_RUNS_OUT (maps/PowerPlant.asm:146-148)
- Route 24 grunt does not exist until CeruleanGymGruntRunsOutScript clears EVENT_ROUTE_24_ROCKET (maps/CeruleanGym.asm:47)
- Route 25 Misty date coord events at (42,6)/(42,7) are inert until setmapscene ROUTE_25, SCENE_ROUTE25_MISTYS_DATE (maps/CeruleanGym.asm:50) and EVENT_ROUTE_25_MISTY_BOYFRIEND is cleared
- Hidden MACHINE_PART at CeruleanGym bg_event 3,8 yields nothing until PowerPlantManager clears EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM (maps/PowerPlant.asm:147)
- Route 5 Underground Path door (17,15) blocked by the Pokefan standing on 17,16; only cleared post-section by setevent EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH in PowerPlantManager .FoundMachinePart (maps/PowerPlant.asm:164)
- Bill's grandpa hands over one stone per map load: EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1 forces .JustShowedSomething until the player leaves and re-enters

**Unresolved (9):**

- Cut tree coordinates on Route 9 and Route 25 are block data in maps/Route9.blk / maps/Route25.blk, not events; no coordinate exists in the asm text to cite
- The walkthrough omits Kevin's battle entirely - TrainerCooltrainermKevin gives the NUGGET then fights with L38 RHYHORN / L35 CHARMELEON / L35 WARTORTLE
- Walkthrough wild lists are abridged: Route 24 also has VENONAT/SUNKERN/ODDISH/VENOMOTH, Route 25 also has PIDGEY/PIDGEOTTO/VENONAT/WEEPINBELL/ODDISH/VENOMOTH, and Route 5's table is not listed at all
- The exact surf path across the ROUTE_9 / ROUTE_10_NORTH connection to the Power Plant door was not traced (block data)
- Per-mon EXP numbers in the walkthrough have no asm source; money values were all reproduced as base reward x last-mon level x 4 and check out
- '11th gym badge' is walkthrough prose - the asm has only the ENGINE_CASCADEBADGE bit, no ordinal
- Route 5 'old Day Care Center' is ROUTE_5_CLEANSE_TAG_HOUSE, whose sign reads 'House for Sale... Nobody lives here'; nothing in Gen 2 calls it a Day Care
- maps/Route5.asm bg_event 10,11 (HouseForSaleSign) shares its tile with warp_event 10,11 into the Cleanse Tag house - bg-event vs warp priority worth checking in the port
- maps/PowerPlant.asm names the fifth NPC POWERPLANT_GYM_GUIDE3 but its script is PowerPlantGymGuide4Script; there is no PowerPlantGymGuide3Script

### 22. [rock tunnel and celadon city gym](section-22-rock-tunnel-and-celadon-city-gym.md)

Maps the Rock Tunnel / Celadon Gym stretch of the Gold walkthrough onto pokegold: verbatim warp, coord, bg and object tables for every map from the Power Plant reward through Erika's gym, plus the machine-part -> EXPN card -> LOST_ITEM -> PASS flag chain, all trainer parties, the Rock Tunnel and Route 7/8 wild tables, and the exact field-move badge checks. Ends with a 45-step bot checklist, a port-coverage matrix against src/world/gen2 and src/script/gen2, and ten walkthrough claims that the asm contradicts or does not support.

**Milestones:** RAINBOWBADGE (ENGINE_RAINBOWBADGE, set by CeladonGymErikaScript in maps/CeladonGym.asm)

**Maps:** `MAP_POWER_PLANT`, `MAP_ROUTE_10_NORTH`, `MAP_ROCK_TUNNEL_1F`, `MAP_ROCK_TUNNEL_B1F`, `MAP_ROUTE_10_SOUTH`, `MAP_LAVENDER_TOWN`, `MAP_LAV_RADIO_TOWER_1F`, `MAP_SOUL_HOUSE`, `MAP_ROUTE_8`, `MAP_ROUTE_8_SAFFRON_GATE`, `MAP_SAFFRON_CITY`, `MAP_SAFFRON_MAGNET_TRAIN_STATION`, `MAP_COPYCATS_HOUSE_1F`, `MAP_COPYCATS_HOUSE_2F`, `MAP_VERMILION_CITY`, `MAP_POKEMON_FAN_CLUB`, `MAP_ROUTE_7_SAFFRON_GATE`, `MAP_ROUTE_7`, `MAP_CELADON_CITY`, `MAP_CELADON_MANSION_1F`, `MAP_CELADON_MANSION_2F`, `MAP_CELADON_MANSION_3F`, `MAP_CELADON_MANSION_ROOF`, `MAP_CELADON_MANSION_ROOF_HOUSE`, `MAP_CELADON_DEPT_STORE_1F`, `MAP_CELADON_DEPT_STORE_2F`, `MAP_CELADON_DEPT_STORE_3F`, `MAP_CELADON_DEPT_STORE_4F`, `MAP_CELADON_DEPT_STORE_5F`, `MAP_CELADON_DEPT_STORE_6F`, `MAP_CELADON_GAME_CORNER`, `MAP_CELADON_GAME_CORNER_PRIZE_ROOM`, `MAP_CELADON_CAFE`, `MAP_CELADON_GYM`

**Gates:**

- Rock Tunnel darkness: PALETTE_DARK in data/maps/maps.asm:156-157 + FlashFunction.CheckUseFlash (engine/events/overworld.asm:271) requires ENGINE_ZEPHYRBADGE and wTimeOfDayPalset == DARKNESS_PALSET
- Surf to the Power Plant / across Route 10 water: SurfFunction badge check ENGINE_FOGBADGE (engine/events/overworld.asm:340)
- Cut generally: CutFunction.CheckAble ENGINE_HIVEBADGE (engine/events/overworld.asm:133) + CheckCutCollision against data/collision/field_move_blocks.asm CutTreeBlockPointers.kanto
- TM07 Zap Cannon: PowerPlantManager requires EVENT_RETURNED_MACHINE_PART or MACHINE_PART in bag; sets EVENT_GOT_TM07_ZAP_CANNON and EVENT_RESTORED_POWER_TO_KANTO
- EXPN CARD: LavRadioTower1FGentlemanScript requires EVENT_RETURNED_MACHINE_PART, sets ENGINE_EXPN_CARD
- LOST_ITEM from PokemonFanClubClefairyGuyScript requires EVENT_RETURNED_MACHINE_PART AND EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM (set by talking to Copycat first)
- PASS from Copycat.ReturnLostItem requires LOST_ITEM in bag; sets EVENT_GOT_PASS_FROM_COPYCAT
- Magnet Train: SaffronMagnetTrainStationOfficerScript requires EVENT_RESTORED_POWER_TO_KANTO then checkitem PASS
- TM03 Curse: CeladonMansionRoofHousePharmacistScript requires checktime NITE
- Game Corner prizes: checkitem COIN_CASE, checkcoins price, and VAR_PARTYCOUNT != PARTY_LENGTH for the mon counter
- Beating Erika retroactively sets EVENT_BEAT_LASS_MICHELLE / TANYA / JULIA / TWINS_JO_AND_ZOE, so gym trainers cannot be fought afterwards
- TM19 Giga Drain is handed out in the same conversation as the badge; a full pack silently skips it (EVENT_GOT_TM19_GIGA_DRAIN stays clear, retry by talking again)

**Unresolved (10):**

- Walkthrough says Celadon Gym needs HM01 Cut; maps/CeladonCity.blk has exactly one kanto cut-tree block ($60 at block (14,17) = cell (28,34)), nowhere near the gym door (block $12 at (5,14), approached from walkable $79 at (5,15)). No Cut gate found.
- Walkthrough's Route 7 wild list (Pidgeotto/Vulpix/Meowth) does not match data/wild/kanto_grass.asm def_grass_wildmons ROUTE_7 IF DEF(_GOLD) (Rattata/Spearow/Growlithe/Raticate/Murkrow/Houndour); Meowth+Vulpix are the _SILVER branch.
- Walkthrough omits four Rock Tunnel items present in asm: ELIXER ball at 1F (4,18), hidden X_ACCURACY at 1F (24,4), hidden X_DEFEND at 1F (21,15), hidden MAX_POTION at B1F (4,14).
- Walkthrough says Erika carries three Full Restores; data/trainers/attributes.asm:125 gives the Erika class 'db HYPER_POTION, NO_ITEM'.
- Erika's party order in parties.asm:331 is Tangela/Jumpluff/Victreebel/Bellossom, not the walkthrough's Tangela/Victreebel/Bellossom/Jumpluff.
- Bellossom's Synthesis healing fraction (walkthrough claims half HP per turn) is weather-dependent in engine/battle/effect_commands.asm and was not pinned down.
- Walkthrough describes a 'Rail Pass' then a separate 'Magnet Train Pass'; the asm has one item, PASS, given once by Copycat.GivePass.
- 'The Saffron City guard will check your Pokedex as ID' - Route7SaffronGuardScript has no checkitem, no coord event and no blocking movement; the gate is passable regardless.
- maps/CeladonGameCorner.asm object/bg event rows (individual slot machines) were not transcribed; only its two warps.
- Quoted EXP and prize-money figures (e.g. 1447 EXP, 1120G) were not verified - they are computed at runtime, not stored in a table.

### 23. [routes 11 19 and fuchsia city gym](section-23-routes-11-19-and-fuchsia-city-gym.md)

Maps the Kanto south-east loop (Route 12 south from Lavender, the Route 11 spur, Routes 13-15 into Fuchsia, the Route 16/17/18 Cycling Road, and Fuchsia Gym) onto pokegold, with every def_warp_events / def_coord_events / def_bg_events / def_object_events row transcribed verbatim plus map headers, dimensions and connections. Adds cut-tree walk cells derived by scanning each .blk against CutTreeBlockPointers, full trainer party data, the wild/fishing tables, the two BICYCLE gate coord events, and the Janine gym script's flag cascade.

**Milestones:** ENGINE_SOULBADGE (Kanto badge 5) from FuchsiaGymJanineScript in maps/FuchsiaGym.asm; EVENT_GOT_TM06_TOXIC -> TM_TOXIC (item $c5) from Janine; EVENT_GOT_SUPER_ROD -> SUPER_ROD from Route12SuperRodHouseFishingGuruScript; ENGINE_FLYPOINT_FUCHSIA set by FuchsiaCityFlypointCallback (MAPCALLBACK_NEWMAP)

**Maps:** `MAP_ROUTE_12`, `MAP_ROUTE_11`, `MAP_ROUTE_12_SUPER_ROD_HOUSE`, `MAP_ROUTE_13`, `MAP_ROUTE_14`, `MAP_ROUTE_15`, `MAP_ROUTE_15_FUCHSIA_GATE`, `MAP_FUCHSIA_CITY`, `MAP_FUCHSIA_POKECENTER_1F`, `MAP_ROUTE_16`, `MAP_ROUTE_16_GATE`, `MAP_ROUTE_16_FUCHSIA_SPEECH_HOUSE`, `MAP_ROUTE_17`, `MAP_ROUTE_17_ROUTE_18_GATE`, `MAP_ROUTE_18`, `MAP_FUCHSIA_GYM`

**Gates:**

- CUT (ENGINE_HIVEBADGE) required at walk cells Route12 (7,44)/(7,49), Route13 (44,4), Route14 (5,8)/(11,14)/(3,24), Route16 (15,4), FuchsiaCity (16,11)/(18,19) - enforced by CutFunction.CheckAble (engine/events/overworld.asm:117) and TryCutOW (:1741)
- BICYCLE in bag required at Route16Gate coord events (5,4)/(5,5), scene 0 - Route16GateBicycleCheck (maps/Route16Gate.asm:16)
- BICYCLE in bag required at Route17Route18Gate coord events (5,4)/(5,5), scene 0 - Route17Route18GateBicycleCheck
- ENGINE_ALWAYS_ON_BIKE + ENGINE_DOWNHILL forced on all of Route 17 (Route17AlwaysOnBikeCallback): no dismount, no Surf, idle frames auto-step DOWN
- ENGINE_ALWAYS_ON_BIKE conditionally set on Route 16 unless VAR_YCOORD < 5 or VAR_XCOORD > 13 (Route16AlwaysOnBikeCallback, MAPCALLBACK_NEWMAP only)
- Vermilion Snorlax (EVENT_VERMILION_CITY_SNORLAX, maps/VermilionCity.asm:41) blocks the Route 11 west connection until special SnorlaxAwake returns true - out of scope for this section
- Safari Zone permanently shut: FuchsiaCity warp 7 at (18,3) is commented ; inaccessible and no script or flag ever opens it
- ENGINE_SOULBADGE gates re-fighting Janine (FuchsiaGymJanineScript checkflag), and EVENT_GOT_TM06_TOXIC gates the TM06 handout separately from the badge

**Unresolved (9):**

- Route 19 is in the section title but the walkthrough never enters MAP_ROUTE_19 or MAP_ROUTE_19_FUCHSIA_GATE
- Walkthrough says 'cut the tree on your way west' on Route 15, but maps/Route15.blk contains none of the five TILESET_KANTO cut-tree block ids; the nearest real tree is the Route 14 one at cell (3,24)
- Walkthrough includes a 'Strategy VERSUS Espeon' paragraph for Janine; Janine (1) in data/trainers/parties.asm has no Espeon (Crobat, Weezing, Weezing, Ariados, Venomoth)
- Seven trainers' party ORDER in the guide differs from ROM order (Herman, Johnny, Carter, Boris, Charles, Linda, Janine); species and levels always match
- Guide omits Route 12 NUGGET (5,51) and hidden ELIXER (14,13), Route 13 hidden CALCIUM (30,13), Route 17 hidden MAX_ETHER (12,5) and MAX_ELIXER (8,77)
- Guide's Route 17 biker order (Riley, Glenn, Joel, Charles) contradicts the map's y-order (Riley 17, Joel 32, Glenn 53, Charles 80); these are sight-line trainers so y-order is what a bot will hit
- Port: the four-fold prize-money loop (engine/battle/core.asm:2341 'ld c, 4') was not located in src/battle/gen2/Prize.lua during this pass
- Fuchsia City cut trees at cells (16,11) and (18,19) are unmentioned by the guide and no reward was traced behind them
- FuchsiaCity warp 7 at (18,3) is only documented as inaccessible by an asm comment; the block collision itself was not decoded

### 24. [snorlax and pewter city gym](section-24-snorlax-and-pewter-city-gym.md)

Maps the FAQ's "Snorlax and Pewter City Gym" chapter onto pokegold: the blocked Route 19 boulder callback, the Poke Flute radio wake-up and forced-Leftovers Snorlax battle in Vermilion City, the three-pocket ladder chain through Diglett's Cave, Route 2's items/cut trees/Bug Catchers, and Pewter City through Brock's BOULDERBADGE. Every warp, coord, bg and object row is transcribed verbatim from the map asm, with the enforcing code cited for each gate and an honest implemented/partial/missing pass over the port's src/world/gen2, src/script/gen2 and src/battle/gen2.

**Milestones:** BOULDERBADGE (ENGINE_BOULDERBADGE, set by maps/PewterGym.asm:PewterGymBrockScript); EVENT_BEAT_BROCK; EVENT_FOUGHT_SNORLAX (L50 SNORLAX with LEFTOVERS); EVENT_GOT_SILVER_WING (Gold) / EVENT_GOT_RAINBOW_WING + EVENT_TEAM_ROCKET_DISBANDED (Silver); EVENT_GOT_NUGGET_FROM_GUY; ENGINE_FLYPOINT_PEWTER

**Maps:** `MAP_ROUTE_19`, `MAP_ROUTE_19_FUCHSIA_GATE`, `MAP_ROUTE_20`, `MAP_VERMILION_CITY`, `MAP_VERMILION_POKECENTER_1F`, `MAP_DIGLETTS_CAVE`, `MAP_ROUTE_2`, `MAP_ROUTE_2_NUGGET_HOUSE`, `MAP_ROUTE_2_GATE`, `MAP_PEWTER_CITY`, `MAP_PEWTER_POKECENTER_1F`, `MAP_PEWTER_GYM`

**Gates:**

- Route 19 boulders: Route19ClearRocksCallback paints six $7a blocks at (6,6)(8,6)(10,6)(12,8)(4,8)(10,10) while EVENT_CINNABAR_ROCKS_CLEARED is clear; that event is set ONLY by Route20ClearRocksCallback (maps/Route20.asm:13, MAPCALLBACK_NEWMAP), so nothing in this section can open it
- SNORLAX at (34,8) physically covers DIGLETT'S CAVE warp 10 at (34,7); removed by `disappear` in VermilionSnorlax, which runs only after startbattle
- SnorlaxAwake (engine/events/specials.asm:358) needs wMapMusic == MUSIC_POKE_FLUTE_CHANNEL AND the player on (33,8)/(34,10)/(35,10)/(36,8)/(36,9)
- POKe FLUTE radio channel (knob 78 / 20.0, engine/pokegear/pokegear.asm:1487) needs not-Johto plus POKEGEAR_EXPN_CARD_F
- Route 2 cut trees: COLL_CUT_TREE via CheckCutCollision, gated on HM01 CUT + ENGINE_HIVEBADGE (engine/events/overworld.asm:133)
- Diglett's Cave is three disconnected pockets joined only by warp pairs 2<->5 and 6<->4
- PewterGymBrockScript `checkflag ENGINE_BOULDERBADGE / iftrue .FightDone` makes Brock one-shot
- Pewter Museum has no warp row at all - permanently closed

**Unresolved (9):**

- Brock's party order: FAQ says Graveler/Omastar/Rhyhorn/Onix/Kabutops, BrockGroup (data/trainers/parties.asm:270) is Graveler/Rhyhorn/Omastar/Onix/Kabutops
- Every FAQ prize-money figure is exactly 4x the asm's ComputeTrainerReward (base reward x last mon level): Brock 25x42=1050 vs FAQ 4200, Rob 128 vs 512, Doug 136 vs 544, Ed 120 vs 480, Jerry 185 vs 740; the EXP figures likewise are not GS values (probably HGSS)
- FAQ says the Max Potion is 'in Viridian Forest' - no such map exists in GS; it is ROUTE2_POKE_BALL2 at (2,23) on ROUTE_2
- FAQ's 'lady' in the Pewter Pokemon Center is `Chris`, SPRITE_POKEFAN_M at (7,2)
- Which two of Route 2's five CUT_TREE blocks the FAQ means is inferred from the .blk dump plus item/warp positions, not labelled in asm
- Diglett's Cave three-pocket connectivity was derived by hand from DiglettsCave.blk block ids vs kanto_collision.asm; interior tile collision not fully traced
- FAQ's 'the route is cleared to Diglett's Cave and through Route 8' - nothing in Route11/Route8 asm is gated on the Snorlax; EVENT_FOUGHT_SNORLAX only additionally controls a Black Belt object in maps/VictoryRoadGate.asm:119
- 'Keep around those four Ultra Balls' is strategy; no ball-count check exists
- Port: the equivalent of BikeFunction.CheckEnvironment (CAVE/GATE permission) was not located in src/world/gen2/Bike.lua, so biking Diglett's Cave in the port is unverified

### 25. [lugia gold and ho oh silver](section-25-lugia-gold-and-ho-oh-silver.md)

Section 25 covers the post-Elite-Four hunt for the version-opposite mascot: the Gold branch surfs Route 41 into the Whirl Islands down to Lugia's chamber, and the Silver branch walks Ecruteak's Tin Tower gatehouse up nine floors of warp/jump mazes to Ho-Oh on the roof. The document transcribes every warp/coord/bg/object table for all 20 maps, the two mascot scripts with their checkver level split and pre-battle one-shot flags, the wing-based MAPCALLBACK_OBJECTS spawn checks, the field-move badge gates, wild/fishing tables, and an honest port-coverage pass that flags the missing Heavy Ball weight bonus.

**Milestones:** No badges awarded in this section; EVENT_FOUGHT_LUGIA set - Lugia encountered at WHIRL_ISLAND_LUGIA_CHAMBER (Lv70 in Gold, Lv40 in Silver); EVENT_FOUGHT_HO_OH set - Ho-Oh encountered at TIN_TOWER_ROOF (Lv70 in Silver, Lv40 in Gold), always holding SACRED_ASH via BATTLETYPE_FORCEITEM

**Maps:** `MAP_ROUTE_41`, `MAP_WHIRL_ISLAND_NW`, `MAP_WHIRL_ISLAND_NE`, `MAP_WHIRL_ISLAND_SW`, `MAP_WHIRL_ISLAND_SE`, `MAP_WHIRL_ISLAND_CAVE`, `MAP_WHIRL_ISLAND_B1F`, `MAP_WHIRL_ISLAND_B2F`, `MAP_WHIRL_ISLAND_LUGIA_CHAMBER`, `MAP_ECRUTEAK_CITY`, `MAP_ECRUTEAK_TIN_TOWER_ENTRANCE`, `MAP_ECRUTEAK_TIN_TOWER_BACK_ENTRANCE`, `MAP_TIN_TOWER_1F`, `MAP_TIN_TOWER_2F`, `MAP_TIN_TOWER_3F`, `MAP_TIN_TOWER_4F`, `MAP_TIN_TOWER_5F`, `MAP_TIN_TOWER_6F`, `MAP_TIN_TOWER_7F`, `MAP_TIN_TOWER_8F`, `MAP_TIN_TOWER_9F`, `MAP_TIN_TOWER_ROOF`

**Gates:**

- SURF requires ENGINE_FOGBADGE (engine/events/overworld.asm:322, badge test :340) to reach Route 41 at all
- WHIRLPOOL requires ENGINE_GLACIERBADGE (overworld.asm:1061/:1077 menu path, :1167/:1171 A-press path) to clear the Route 41 whirlpool blocks (TILESET_JOHTO block $07 -> $36, data/collision/field_move_blocks.asm:48-55)
- FLASH requires ENGINE_ZEPHYRBADGE and a PALETTE_DARK map (overworld.asm:271) - every Whirl Island map is PALETTE_DARK
- WATERFALL requires ENGINE_RISINGBADGE (overworld.asm:611/:618, :683/:687) only for the UP direction; descending the B2F waterfall needs nothing
- Lugia object only appears while checkitem SILVER_WING is true and EVENT_FOUGHT_LUGIA is clear (WhirlIslandLugiaChamberLugiaCallback, MAPCALLBACK_OBJECTS)
- Ho-Oh object only appears while checkitem RAINBOW_WING is true and EVENT_FOUGHT_HO_OH is clear (TinTowerRoofHoOhCallback)
- TIN_TOWER_1F stairs at (10,2) are physically occupied by TINTOWER1F_SAGE, masked only when EVENT_TEAM_ROCKET_DISBANDED is set (maps/RadioTower5F.asm:130 in Gold, maps/PewterCity.asm:51 in Silver)
- ECRUTEAK_TIN_TOWER_ENTRANCE coord_events at (4,7)/(5,7) block the corridor while the map scene is SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS; cleared by maps/EcruteakGym.asm:34 setmapscene on the Fog Badge
- EVENT_FOUGHT_LUGIA / EVENT_FOUGHT_HO_OH are set BEFORE startbattle, so fleeing, fainting or a KO burns the only encounter - save first
- Escape Rope only works in CAVE or DUNGEON environments (engine/events/overworld.asm:724-754); TIN_TOWER_ROOF is ROUTE, so you must descend to 9F first

**Unresolved (11):**

- Walkthrough says Whirlpool needs eight badges; the asm gates it on ENGINE_GLACIERBADGE alone (seven badges)
- Walkthrough lists 'Max Revive x2' in the Whirl Islands; only one MAX_REVIVE item ball exists (WhirlIslandB2FMaxRevive at B2F (6,4)). It also omits Full Restore x2, Carbos, Nugget, Max Elixer and three B1F hidden items
- Tin Tower item list is wrong for pokegold: no PP_UP, no HP_UP, no Max Potion item ball (only hidden TinTower4FHiddenMaxPotion at (11,6)), only one Full Heal (3F). It omits Super Potion, Nugget, Full Restore and the 4F/5F hidden items
- Walkthrough places a Max Potion and a Full Heal on the floor matching TIN_TOWER_6F; maps/TinTower6F.asm has empty def_bg_events and def_object_events
- Ho-Oh's claimed moveset (Safeguard, Ancient Power, Punishment, Sacred Fire) is impossible - PUNISHMENT does not exist in Gen 2. Derived from data/pokemon/evos_attacks.asm:3324-3336 plus FillMoves (engine/pokemon/evolve.asm:478), a Lv70 Ho-Oh should have Recover/Fire Blast/Sunny Day/Swift. The derivation is inferred, not a literal table
- Whirl Islands wild list omits GOLBAT (grass slot 5 on every floor) and TENTACOOL/TENTACRUEL (SW and B2F water); Tin Tower list omits GASTLY at night
- Whirlpool positions near Swimmer Kara (44,28) are .blk block data, not events - a bot must scan maps/Route41.blk for TILESET_JOHTO block $07
- All ledge-hop and jump-platform routing in both dungeons is .blk collision data; only the warp endpoints are asm facts
- 'Bell Tower' is the post-GS rename; pokegold text and signs say TIN TOWER throughout
- Port: Heavy Ball weight bonus is missing (src/battle/gen2/Catching.lua:36 has HEAVY_BALL = 1, no dex-weight lookup), so the FAQ's Lugia Heavy Ball tip does not work in this repo
- Port: could not locate an EscapeRopeFunction equivalent with the CAVE/DUNGEON environment check, so the TIN_TOWER_ROOF refusal is unverified in this repo

### 26. [mount moon and routes 1 4](section-26-mount-moon-and-routes-1-4.md)

Maps the walkthrough's Route 3 -> Mt. Moon (rival battle, Mt. Moon Square, gift shop) -> Route 4 -> Viridian City / Trainer House -> Route 1 -> Pallet Town / Oak's Lab stretch onto pokegold, with verbatim warp/coord/bg/object tables, map headers, trainer parties, wild tables and script control flow. Ends by handing off to Route 21 (next section) and records the port's gaps, notably that OBJECTTYPE_ITEMBALL pickup and smashable-rock interaction are unimplemented.

**Milestones:** No badge is earned in this section; EVENT_BEAT_RIVAL_IN_MT_MOON (last mandatory Silver battle; unlocks the Indigo Plateau and Dragon's Den rival re-encounters); ENGINE_FLYPOINT_VIRIDIAN (Viridian City MAPCALLBACK_NEWMAP); ENGINE_FLYPOINT_PALLET (Pallet Town MAPCALLBACK_NEWMAP); EVENT_TALKED_TO_OAK_IN_KANTO (Oak's Kanto-badge conversation; EVENT_OPENED_MT_SILVER at 16 badges); HP_UP item ball on Route 4 (EVENT_ROUTE_4_HP_UP)

**Maps:** `MAP_ROUTE_3`, `MAP_MOUNT_MOON`, `MAP_MOUNT_MOON_SQUARE`, `MAP_MOUNT_MOON_GIFT_SHOP`, `MAP_ROUTE_4`, `MAP_VIRIDIAN_CITY`, `MAP_TRAINER_HOUSE_1F`, `MAP_TRAINER_HOUSE_B1F`, `MAP_ROUTE_1`, `MAP_PALLET_TOWN`, `MAP_OAKS_LAB`

**Gates:**

- MountMoon scene 0 SCENE_MOUNTMOON_RIVAL_BATTLE -> sdefer MountMoonRivalBattleScript (42:55b0): unavoidable RIVAL2 battle; only setscene SCENE_MOUNTMOON_NOOP at the end of a win clears it
- MountMoonSquare ClefairyDance: requires ENGINE_MT_MOON_SQUARE_CLEFAIRY clear AND VAR_WEEKDAY == MONDAY AND checktime NITE; one-shot via setflag
- EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE is re-set by MountMoonSquareDisappearMoonStoneCallback on every MAPCALLBACK_NEWMAP, so the Moon Stone must be taken in the same visit as the dance
- MtMoonSquareRock -> jumpstd SmashRockScript -> engine/events/overworld.asm:1365 AskRockSmashScript / HasRockSmash: needs ROCK_SMASH in the party (CheckPartyMove), no badge check
- TrainerHouseB1F ENGINE_FOUGHT_IN_TRAINER_HALL_TODAY: one CAL battle per day
- TrainerHouse opponent identity: special TrainerHouse reads sMysteryGiftTrainerHouseFlag (engine/events/specials.asm:454); without Mystery Gift always CAL3
- Fly: engine/events/overworld.asm:544 FlyFunction .TryFly requires ENGINE_STORMBADGE plus the destination's ENGINE_FLYPOINT_*
- Surf south from Pallet to Route 21 (next section): engine/events/overworld.asm:338 SurfFunction .TrySurf requires ENGINE_FOGBADGE
- Indigo Plateau rival rematch: EVENT_BEAT_RIVAL_IN_MT_MOON + ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT clear + weekday Monday or Wednesday (maps/IndigoPlateauPokecenter1F.asm:45,67)
- Dragon's Den rival sighting: EVENT_BEAT_RIVAL_IN_MT_MOON + weekday Tuesday or Thursday (maps/DragonsDenB1F.asm:12)

**Unresolved (13):**

- Rival party ORDER contradicts the walkthrough: parties.asm has the starter evolution LAST at L45, not third (data/trainers/parties.asm:2042-2069)
- Walkthrough's Route 3 and Route 4 wild lists (Ekans/Arbok) are the ELIF DEF(_SILVER) arms; the _GOLD arms have no Ekans or Arbok (data/wild/kanto_grass.asm:314, :369)
- Walkthrough's Mt. Moon wild list omits Gold's L8 SANDSHREW, L10 SANDSLASH and two L8 CLEFAIRY slots (data/wild/kanto_grass.asm:33)
- Walkthrough's Route 1 wild list omits the nite column, which has no Pidgey or Furret at all (data/wild/kanto_grass.asm:250)
- 'Item on Route 1: Bitter Berry' is a fruittree FRUITTREE_ROUTE_1 (daily respawn), not a ground item (data/items/fruit_trees.asm)
- The two Mt. Moon paths described in the walkthrough could not be confirmed against maps/MountMoon.blk collision; only the warp graph was verified
- 'Bring Rock Smash' is supported indirectly (the rock is appeared onto the Moon Stone tile mid-cutscene) but whether it actually blocks the A press was not verified
- Route 4 hidden ULTRA_BALL at (10,3) and Viridian's TM_DREAM_EATER are real but absent from the walkthrough
- Mt. Moon Gift Shop has no NITE clerk: both SPRITE_GRAMPS rows are gated -1, MORN and -1, DAY
- Route 3's only warp is at (52,1) but its Mt. Moon Square sign is at (49,13); odd but verbatim
- PORT GAP: OBJECTTYPE_ITEMBALL pickup is unimplemented. RomExtractorGen2.lua:2968 records obj.itemball but World:interact (src/world/gen2/World.lua:5257-5310) has no arm for it, so the Route 4 HP Up cannot be taken
- PORT GAP: SPRITEMOVEDATA_SMASHABLE_ROCK has no interact arm (World.isStrengthBoulder exists at World.lua:4071, no rock equivalent anywhere in src/)
- PORT FIDELITY: src/script/gen2/Vm.lua:92-93 runs sdefer immediately instead of deferring, so the Mt. Moon rival cutscene starts marginally earlier than on cart

### 27. [cinnabar island and seafoam islands gym](section-27-cinnabar-island-and-seafoam-islands-gym.md)

Maps the FAQ's Cinnabar Island / Seafoam Islands Gym chapter onto pokegold: the surf route Pallet -> Route 21 -> Cinnabar Island -> Route 20 -> Seafoam Gym, with verbatim warp/bg/object tables, map headers, connections, the four trainers plus BLAINE, and every EVENT_/ENGINE_ flag those scripts touch. Includes the two non-obvious side effects a bot must not skip - talking to Blue clears EVENT_VIRIDIAN_GYM_BLUE (the only unlock for the Viridian Gym leader) and merely loading Route 20 sets EVENT_CINNABAR_ROCKS_CLEARED (which unseals Route 19).

**Milestones:** ENGINE_VOLCANOBADGE (VOLCANOBADGE from BLAINE, maps/SeafoamGym.asm:34); EVENT_BEAT_BLAINE (maps/SeafoamGym.asm:29); ENGINE_FLYPOINT_CINNABAR (CinnabarIslandFlypointCallback, maps/CinnabarIsland.asm:11); EVENT_CINNABAR_ROCKS_CLEARED (Route20ClearRocksCallback, maps/Route20.asm:13); EVENT_VIRIDIAN_GYM_BLUE cleared by CinnabarIslandBlue (maps/CinnabarIsland.asm:23) - the Viridian Gym leader unlock; Hidden RARE_CANDY, EVENT_CINNABAR_ISLAND_HIDDEN_RARE_CANDY (maps/CinnabarIsland.asm:36)

**Maps:** `MAP_ROUTE_21`, `MAP_CINNABAR_ISLAND`, `MAP_CINNABAR_POKECENTER_1F`, `MAP_ROUTE_20`, `MAP_SEAFOAM_GYM`

**Gates:**

- SURF over open sea for the whole section: engine/events/overworld.asm:469 TrySurfOW -> ENGINE_FOGBADGE CheckEngineFlag at :490 plus CheckPartyMove SURF (menu path SurfFunction .TrySurf, ENGINE_FOGBADGE at :340)
- Blue absent from Viridian Gym until talked to here: maps/ViridianGym.asm:183-184 object rows carry EVENT_VIRIDIAN_GYM_BLUE, set at engine/events/std_scripts.asm:552, cleared only by CinnabarIslandBlue
- Route 19 sealed by six changeblock $7a rock blocks in maps/Route19.asm:15 Route19ClearRocksCallback while EVENT_CINNABAR_ROCKS_CLEARED is clear; loading Route 20 once sets it
- Blaine re-battle blocked by checkflag ENGINE_VOLCANOBADGE / iftrue .FightDone (maps/SeafoamGym.asm:17)
- Seafoam gym guide does not exist until the win branch runs appear SEAFOAMGYM_GYM_GUIDE (maps/SeafoamGym.asm:26); flag EVENT_SEAFOAM_GYM_GYM_GUIDE set at engine/events/std_scripts.asm:553
- Fly to Cinnabar requires ENGINE_FLYPOINT_CINNABAR, set only by walking onto the map (data/maps/flypoints.asm:28, spawn_points.asm:24)

**Unresolved (9):**

- Blaine's movesets in the walkthrough (Yawn/Recover/Overheat, Flare Blitz, Bounce) do not exist in Gen 2 and contradict data/trainers/parties.asm:2303-2308 (CURSE/SMOG/FLAMETHROWER/ROCK_SLIDE, THUNDERPUNCH/FIRE_PUNCH/SUNNY_DAY/CONFUSE_RAY, QUICK_ATTACK/FIRE_SPIN/FURY_ATTACK/FIRE_BLAST). Species and levels match exactly.
- "Two Full Restores" contradicts data/trainers/attributes.asm:276 db MAX_POTION, FULL_HEAL.
- "You now have 15 badges" has no asm anchor; Kanto gym order is unenforced.
- Route 21 wild list abridged: asm also has MR__MIME in grass (kanto_grass.asm:1005) and TENTACRUEL in water (kanto_water.asm:61); Route 20 also has TENTACRUEL.
- Surf paths ("way left then down" on Route 21, the cave mouth on Route 20) are block data in maps/Route21.blk / maps/Route20.blk and were not decoded; only the trainer/warp coordinates are verified.
- No MAP_SEAFOAM_ISLANDS dungeon exists in Gen 2 - constants/map_constants.asm has only SEAFOAM_GYM; "Seafoam Islands" is LANDMARK_SEAFOAM_ISLANDS (data/maps/landmarks.asm:94).
- Per-mon EXP figures are not stored anywhere in the asm (money figures all reproduce exactly as base reward x last-mon level x 4).
- EVENT_BEAT_BLAINE has no reader anywhere in maps/, data/, engine/, home/ or constants/ - ENGINE_VOLCANOBADGE is the flag the cart branches on.
- Port gap (not a walkthrough issue): setflag ENGINE_VOLCANOBADGE lands on save.engineFlags but nothing writes save.player.kantoBadges, so the badge never reaches the trainer card or VAR_BADGES; BadgeTypeBoosts (FIRE +12.5%) is absent from src/battle/gen2/; movement byte $4c (teleport_from, Blue's exit) decodes to nop in src/script/gen2/Movement.lua.

### 28. [routes 19 20 and viridian city gym](section-28-routes-19-20-and-viridian-city-gym.md)

Maps the optional Swimmer sweep across Routes 20 and 19 and the Viridian Gym fight with Blue onto pokegold, with verbatim warp/coord/bg/object tables, map headers, connections, trainer parties, water and fishing tables, and the exact opcode flow of ViridianGymBlueScript. Ends with the real gates (FOGBADGE Surf, the Route 20 rock-clearing callback, EVENT_VIRIDIAN_GYM_BLUE hiding both gym objects, STORMBADGE/flypoint Fly), a literal 18-step bot checklist, and a port-coverage table for src/world/gen2, src/script/gen2 and src/battle/gen2.

**Milestones:** EARTHBADGE (ENGINE_EARTHBADGE) from Blue in Viridian Gym - the 16th badge; EVENT_BEAT_BLUE; EVENT_BEAT_SWIMMERF_LORI; EVENT_BEAT_SWIMMERF_NICOLE; EVENT_BEAT_SWIMMERM_TUCKER; EVENT_BEAT_SWIMMERF_DAWN; EVENT_BEAT_SWIMMERM_JEROME; TM42 Dream Eater from VIRIDIANCITY_FISHER (optional, not in the FAQ)

**Maps:** `MAP_ROUTE_20`, `MAP_ROUTE_19`, `MAP_ROUTE_19_FUCHSIA_GATE`, `MAP_VIRIDIAN_CITY`, `MAP_VIRIDIAN_POKECENTER_1F`, `MAP_VIRIDIAN_GYM`

**Gates:**

- ENGINE_FOGBADGE + SURF in party to reach Routes 19/20 at all (engine/events/overworld.asm:322 SurfFunction, :469 TrySurfOW)
- EVENT_CINNABAR_ROCKS_CLEARED gates the six changeblock $7a WALL rocks on northern Route 19 (maps/Route19.asm:15); set unconditionally by entering Route 20 (maps/Route20.asm:12 MAPCALLBACK_NEWMAP)
- EVENT_VIRIDIAN_GYM_BLUE must be CLEAR or the gym is empty - both ViridianGym objects carry it; set at new game by engine/events/std_scripts.asm:552, cleared only by maps/CinnabarIsland.asm:23 CinnabarIslandBlue
- Fly to Viridian needs ENGINE_STORMBADGE + FLY + ENGINE_FLYPOINT_VIRIDIAN, which ViridianCityFlypointCallback only sets on a first on-foot visit
- ENGINE_EARTHBADGE checkflag makes the Blue battle one-shot (maps/ViridianGym.asm:13); no rematch or phone entry
- Next section: maps/OaksLab.asm:26 readvar VAR_BADGES / ifequal NUM_BADGES gates EVENT_OPENED_MT_SILVER on this badge

**Unresolved (6):**

- The FAQ's 'blocked by boulders south of Fuchsia City' contradicts the asm: Route20ClearRocksCallback sets EVENT_CINNABAR_ROCKS_CLEARED on first entry to Route 20, so the rocks are already gone by the time the walkthrough reaches Route 19
- Route 19 declares connection north FuchsiaCity (data/maps/attributes.asm:288) as well as a warp to Route19FuchsiaGate; I did not decode Route19.blk to see whether the north edge is actually walkable
- The FAQ says Route 19 has no further trainers, but TrainerSwimmermHarold (13,28) and TrainerSwimmermCameron (12,13, Route 20) both exist with sight range 3
- Blue's strategy prose cites Air Slash (nonexistent in Gen 2) and Exeggutor's Psychic/Hypnosis; BlueGroup gives Pidgeot WING_ATTACK and Exeggutor SUNNY_DAY/LEECH_SEED/EGG_BOMB/SOLARBEAM
- 'One of only two trainers tougher than Champion Lance' has no asm counterpart
- ViridianGym's maps.asm row sets the phone column TRUE; no phone_call names BLUE, but data/phone/ was not read exhaustively

### 29. [routes 22 28](section-29-routes-22-28.md)

Covers the post-Kanto run to Mt. Silver: Fly to Pallet Town, talk to Prof. Oak with 16 badges to set EVENT_OPENED_MT_SILVER, Fly to Viridian and Cut west for TM42 Dream Eater, cross Route 22 to the Victory Road Gate, then west to Route 28, the Mt. Silver Pokecenter, and TM47 Steel Wing. Every map's warp/coord/bg/object tables are transcribed verbatim, and the Cut trees, ledges and NPC blockers were verified cell-by-cell against the .blk block data and the kanto/gate tileset collision tables.

**Maps:** `MAP_PALLET_TOWN`, `MAP_OAKS_LAB`, `MAP_VIRIDIAN_CITY`, `MAP_ROUTE_22`, `MAP_VICTORY_ROAD_GATE`, `MAP_ROUTE_28`, `MAP_ROUTE_28_STEEL_WING_HOUSE`, `MAP_SILVER_CAVE_OUTSIDE`, `MAP_SILVER_CAVE_POKECENTER_1F`

**Gates:**

- EVENT_OPENED_MT_SILVER hides VICTORYROADGATE_BLACK_BELT1 at cell (7,5), the only tile joining the gate's centre corridor to its west vestibule and therefore to the ROUTE_28 warps at (1,7)/(2,7). Oak sets it only when VAR_BADGES == NUM_BADGES (16), via `ifequal NUM_BADGES` in maps/OaksLab.asm:27. This, not the cave mouth, is what gates Mt. Silver.
- EVENT_FOUGHT_SNORLAX hides VICTORYROADGATE_BLACK_BELT2 at (12,5), the equivalent chokepoint to the ROUTE_22 vestibule. Already set by this point, but a flag-cleared test save walls itself into the gate.
- HM01 Cut + ENGINE_HIVEBADGE (engine/events/overworld.asm:1741 TryCutOW): required at ViridianCity cell (8,22) for the TM42 Dream Eater fisher, and at SilverCaveOutside cells (31,24) and (34,23) - BOTH trees - to reach ROUTE_28 (0,3), the Steel Wing house and the hidden Rare Candy.
- HM02 Fly + ENGINE_STORMBADGE (engine/events/overworld.asm:545) plus the ENGINE_FLYPOINT_PALLET / _VIRIDIAN / _SILVER_CAVE bits set by each map's MAPCALLBACK_NEWMAP.
- Victory Road Gate coord event (10,11) needs >= 8 Johto badges, but the Route 22 -> Route 28 path never crosses it.
- Ledge hopping: Route 22 has no ledge-free route to the gate warp - (35,12) and (18,6) are COLL_HOP_DOWN over COLL_WALL. The Route 28 west strip likewise exits only over the y=4 ledge row, one-way.

**Unresolved (8):**

- FAQ files TM42 Dream Eater under 'Items on Route 22'; the NPC is actually ViridianCity object (6,23). maps/Route22.asm has an empty def_object_events.
- FAQ says there is a Pokemon Center on Route 28; it is on MAP_SILVER_CAVE_OUTSIDE (warp 1 at (23,19)), one map west.
- FAQ says TM47 Steel Wing is a Route 28 item; it is inside ROUTE_28_STEEL_WING_HOUSE. Route 28's only item is the hidden Rare Candy at (25,2), which the FAQ omits.
- FAQ's Route 28 species list omits Ursaring (Gold's 20% slot where Silver has Donphan) and Doduo/Dodrio, and does not say Sneasel is nite-only.
- FAQ's Route 22 list omits Doduo, Ponyta and Fearow.
- The two-cell ledge jump distance was inferred from the collision permission table ($a0..$a7 = LAND_TILE) plus the fact that every ledge on these maps has COLL_WALL directly beyond it; the DoPlayerMovement ledge branch in engine/overworld/player_movement.asm was not read line by line. All Route 22 / Route 28 waypoints depend on that inference.
- SilverCaveOutside's east edge is also walkable at y=14..18 and y=33..35, mapping to Route 28 y=-4..0 and y=15..17, which are outside every reachable component - assumed filler, not chased.
- Nothing in the asm checks the bag, so the FAQ's 'bring 10 Revives / 50 Ultra Balls' is advice, not a gate.

### 30. [lapras](section-30-lapras.md)

Maps the Friday-only static Lapras hunt onto the pokegold disassembly: the Route 32 approach, the surf route down through Union Cave 1F and B1F, and the full Union Cave B2F event tables, with UnionCaveB2FLaprasCallback's weekday/daily-flag logic and UnionCaveLapras's unconditional disappear+setflag transcribed opcode by opcode. Includes verbatim warp/bg/object tables for all three floors, the five trainers' parties and prize-money arithmetic (base x last level x 4, which reproduces the walkthrough's gold figures exactly), the grass and water wild tables, and an honest port-coverage audit that flags item-ball pickup and Gen 2 Escape Rope as missing.

**Maps:** `MAP_UNION_CAVE_1F`, `MAP_UNION_CAVE_B1F`, `MAP_UNION_CAVE_B2F`, `MAP_ROUTE_32`

**Gates:**

- Surf field move: SurfFunction.TrySurf (engine/events/overworld.asm:322) checks ENGINE_FOGBADGE, so the Fog Badge plus a mon knowing SURF is required to reach any of the three floors' water legs, including Lapras at UNION_CAVE_B2F 11,31
- Friday-only: UnionCaveB2FLaprasCallback (maps/UnionCaveB2F.asm:15, sym 44:575e) runs readvar VAR_WEEKDAY / ifequal FRIDAY under MAPCALLBACK_OBJECTS, re-evaluated on every B2F map load
- Daily one-shot: the same callback's checkflag ENGINE_UNION_CAVE_LAPRAS (constants/engine_flags.asm:107, wDailyFlags2 bit DAILYFLAGS2_UNION_CAVE_LAPRAS_F) hides Lapras once UnionCaveLapras has run; cleared only by CheckDailyResetTimer (engine/overworld/time.asm:88)
- Unconditional consumption: UnionCaveLapras runs disappear + setflag after startbattle with no wBattleResult guard, so a KO, a flee or a blackout burns the encounter for the day - save before pressing A
- Object visibility inversion: EVENT_UNION_CAVE_B2F_LAPRAS SET means hidden (CheckObjectFlag, engine/overworld/map_objects_2.asm:31); appear clears it, disappear sets it
- Single exit: UNION_CAVE_B2F has exactly one warp (5,3 -> UNION_CAVE_B1F warp 5); leaving otherwise needs Escape Rope / Dig
- Port blocker: OBJECTTYPE_ITEMBALL objects have no consumer in this repo (extractor sets obj.itemball at src/import/RomExtractorGen2.lua:2969, World:talk only dispatches scriptKey at src/world/gen2/World.lua:5276), so the B2F Elixer and Hyper Potion cannot be picked up
- Port blocker: no Gen 2 Escape Rope path found under src/core/gen2 or src/world/gen2 (only the Gen 1 route in src/ui/PartyMenu.lua:634)

**Unresolved (8):**

- EXP figures quoted per mon (637 Marowak, 975 Kangaskhan, 355/511/924/928/933/786 and two '?' entries) are runtime-computed from base EXP x level, not stored in any trainer table, so none could be pinned to an asm row
- Walkthrough lists Nick as Charmander/Bulbasaur/Squirtle and Gwen as Eevee/Vaporeon/Jolteon/Flareon; data/trainers/parties.asm:742 has Charmander/Squirtle/Bulbasaur and :867 has Eevee/Flareon/Vaporeon/Jolteon - same sets, different order (matters because Gwen's last row, Jolteon L22, sets the prize level)
- 'once you've gotten HM Surf' implies a scripted gate that does not exist; no HM or badge check appears in UnionCaveB2FLaprasCallback or UnionCaveLapras, only reachability via SurfFunction.TrySurf's ENGINE_FOGBADGE test
- In-game NPC hints disagree with the code: PokemaniacLarryAfterBattleText says 'Every Friday' (matches the callback) while FirebreatherBillAfterBattleText says 'On weekends'; the walkthrough follows Larry and is correct
- Identification of 'the guy on the cliff still spinning around' as Firebreather Bill (UNIONCAVE1F_FISHER2 at 15,15, SPRITEMOVEDATA_SPINRANDOM_FAST) is inferred from coordinates and movement data, not stated anywhere; walking order depends on UnionCave1F.blk, which was not decoded
- Which 1F ladder the walkthrough means is inferred: warp 2 at 3,33 -> UNION_CAVE_B1F warp 4 at 3,33, chosen because Andrew stands at B1F 5,32; warp 1 at 5,19 lands nowhere near him
- B2F 'right side' / 'left side' landings are consistent with the object coordinates (12,19 and 17,23 right; 5,13 and 3,28 left) but the actual land/water split comes from UnionCaveB2F.blk, which was not decoded
- Walkthrough omits the B2F Elixer item ball at 16,2 (UnionCaveB2FElixer, EVENT_UNION_CAVE_B2F_ELIXER) entirely - an omission, not a contradiction

### 31. [mount silver and red](section-31-mount-silver-and-red.md)

Maps the final walkthrough stretch - Route 28's west edge into Mt. Silver, the three Silver Cave floors, the two-chamber item map, and the Red battle - onto pokegold, with verbatim warp/bg/object tables, the Red script's opcode-by-opcode control flow, RedGroup's party and prize-money maths, and the full johto_grass/johto_water entries with their morn/day/nite and Gold-vs-Silver splits. Gates are traced to enforcing code (VictoryRoadGate badge coord_event, PALETTE_DARK/Flash, Surf/Waterfall badge checks, EVENT_RED_IN_MT_SILVER object masking), and port coverage is marked per beat against src/world/gen2, src/script/gen2 and src/import/RomExtractorGen2.lua.

**Milestones:** No badge awarded in this section; Red (RED/RED1) defeated in SilverCaveRoom3 - final boss; credits opcode runs, wSpawnAfterChampion = SPAWN_RED, post-credits respawn at SPAWN_MT_SILVER

**Maps:** `MAP_SILVER_CAVE_OUTSIDE`, `MAP_SILVER_CAVE_POKECENTER_1F`, `MAP_SILVER_CAVE_ROOM_1`, `MAP_SILVER_CAVE_ROOM_2`, `MAP_SILVER_CAVE_ITEM_ROOMS`, `MAP_SILVER_CAVE_ROOM_3`, `MAP_VICTORY_ROAD_GATE`

**Gates:**

- VictoryRoadGate coord_event (10,11) SCENE_VICTORYROADGATE_BADGE_CHECK -> VictoryRoadGateBadgeCheckScript: readvar VAR_BADGES / ifgreater NUM_JOHTO_BADGES - 1
- EVENT_RED_IN_MT_SILVER must be CLEAR for Red's object to appear; cleared only by maps/HallOfFame.asm:36 (Elite Four induction), set by InitializeEventsScript at new game and re-set by disappear after the fight
- SilverCaveRoom1 is PALETTE_DARK -> ReplaceTimeOfDayPals .NeedsFlash; needs STATUSFLAGS_FLASH_F via FlashFunction (ENGINE_ZEPHYRBADGE + HM05)
- ENGINE_FOGBADGE + SURF (SurfFunction.TrySurf) to cross both SilverCaveRoom2 lakes
- ENGINE_RISINGBADGE + WATERFALL (WaterfallFunction.TryWaterfall / CheckMapCanWaterfall) to reach either SilverCaveItemRooms chamber
- Gen 2 ledge hop (.TryJump / HI_NYBBLE_LEDGES on the STANDING tile) required to leave the Escape Rope ledge row in SilverCaveRoom1

**Unresolved (9):**

- Walkthrough lists Protein as a Mt. Silver item; no PROTEIN appears in any Silver Cave map asm
- Walkthrough lists Donphan (#232) - that is the _SILVER column; Gold has Ursaring in those slots
- Walkthrough says Red carries three Full Restores; data/trainers/attributes.asm gives the RED class exactly two item slots
- Red's party order in the walkthrough (Pikachu, Espeon, Blastoise, Snorlax, Charizard, Venusaur) differs from RedGroup (Pikachu, Espeon, Snorlax, Venusaur, Charizard, Blastoise); the quoted per-mon EXP yields are runtime-computed and not in any table
- Walkthrough calls Espeon a dark type immune to ghost moves; data/pokemon/base_stats/espeon.asm:6 is PSYCHIC_TYPE, PSYCHIC_TYPE
- Walkthrough says Red 'flies away'; the Red script only does FadeOutToBlack / disappear / FadeInFromBlack, no applymovement
- Which SilverCaveItemRooms chamber the Surf+Waterfall route reaches was derived by expanding the .blk files through data/tilesets/cave_collision.asm, not stated in asm - route coordinates should be confirmed in-game
- EVENT_OPENED_MT_SILVER (set by maps/OaksLab.asm on 16 badges) has no consumer on the Route 28 / Silver Cave path; its only reader is the hide-flag of a Black Belt in maps/VictoryRoadGate.asm:118, so the commonly-cited 16-badge entry requirement could not be pinned to enforcing code
- WARP_CARPET_DOWN collision cells with no warp_event: (11,27) and (13,27) in SilverCaveRoom1, (11,33) in SilverCaveRoom3

### 32. [raikou entei and suicune](section-32-raikou-entei-and-suicune.md)

Maps the roaming-legendary hunt onto pokegold: the roam_struct WRAM layout, InitRoamMons starting routes (Raikou 42 / Entei 37 / Suicune 38), the verbatim 16-entry RoamMaps graph, the shared-random-byte .Update walk, and the exact map-setup-script table showing that connections and door warps run UpdateRoamMons while Fly/Teleport and Continue run JumpRoamMons. Adds full warp/coord/bg/object transcriptions and wild tables for the five maps the walkthrough names (Violet City, Routes 35/36/37/42), the catch and flee math including two shipped-ROM bugs, and an honest port-coverage audit that lists five concrete gaps.

**Maps:** `MAP_ROUTE_29`, `MAP_ROUTE_30`, `MAP_ROUTE_31`, `MAP_ROUTE_32`, `MAP_ROUTE_33`, `MAP_ROUTE_34`, `MAP_ROUTE_35`, `MAP_ROUTE_36`, `MAP_ROUTE_37`, `MAP_ROUTE_38`, `MAP_ROUTE_39`, `MAP_ROUTE_42`, `MAP_ROUTE_43`, `MAP_ROUTE_44`, `MAP_ROUTE_45`, `MAP_ROUTE_46`, `MAP_VIOLET_CITY`, `MAP_ROUTE_40`, `MAP_ROUTE_41`, `MAP_BURNED_TOWER_B1F`

**Gates:**

- EVENT_RELEASED_THE_BEASTS / special InitRoamMons at maps/BurnedTowerB1F.asm:65 is the only thing that creates the three roam_structs; without it no beast exists anywhere
- CheckEncounterRoamMon's CheckOnWater bail: roamers can never be met while surfing
- RoamMaps (data/wild/roammon_maps.asm) restricts roamers to 16 Johto routes; ROUTE_40 and ROUTE_41 are deliberately absent
- LoadWildMonDataPointer must succeed before CheckEncounterRoamMon runs, so maps with no wild table can never host a beast
- ChooseWildEncounter_BugContest never calls CheckEncounterRoamMon, so no beast can appear during the Bug Catching Contest
- SudowoodoScript on Route 36 (tile x=35,y=9) needs SQUIRTBOTTLE; EVENT_ROUTE_36_SUDOWOODO blocks the Violet/Route 36/Route 37 loop until cleared
- AlwaysFleeMons (data/wild/flee_mons.asm) is exactly RAIKOU/ENTEI/SUICUNE, so TryEnemyFlee ends the battle after one player action unless SUBSTATUS_CANT_RUN, a live wEnemyWrapCount, SLP or FRZ applies
- CheckRepelEffect compares wCurPartyLevel (40) against the lead's level: a lead of level 41 or higher repels the roamer itself, which is why the walkthrough specifies a level 39 Scyther
- FastBallMultiplier bug (engine/items/item_effects.asm:986) means Fast Balls give no bonus on the beasts; ULTRA_BALL x2 or MASTER_BALL only
- Paralysis gives no catch-rate bonus at all (commented-out wEnemyMonStatus reload in .statuscheck); only SLP/FRZ give +10
- All three beasts know ROAR at level 40; BattleCommand_ForceSwitch's wild branch ends the battle as a DRAW against any lead at level 40 or below

**Unresolved (7):**

- Walkthrough says roamers 'show up on the map in Pokegear'; FindNest's only caller is Pokedex_GetArea (engine/pokegear/pokegear.asm:2430, 24:5c7f), i.e. the Pokedex AREA screen drawn with town-map graphics, not the Pokegear map menu
- Walkthrough says tracking becomes possible 'after the initial encounter'; FindNest has no encountered gate, and nothing in maps/BurnedTowerB1F.asm marks the beasts SEEN during ReleaseTheBeasts, so the SEEN requirement is inferred rather than proven by a SetSeenMon call
- Walkthrough advises catching while 'asleep or paralyzed'; the .statuscheck block (engine/items/item_effects.asm:344) gives +10 for SLP/FRZ but nothing for PAR/BRN/PSN because the wEnemyMonStatus reload is commented out
- Walkthrough says roamers 'occasionally jump a few routes'; the only jump in the asm is the 1-in-32 and %00011111 branch into JumpRoamMon, which is a uniformly random one of the 16 entries, not an adjacent hop
- Walkthrough's 'as quickly as every 10 seconds' has no basis in code: roam movement is purely event-driven off map setup scripts and battle ends, with no timer anywhere
- Whether wCurPartyLevel still holds the wild mon's level at BattleCommand_ForceSwitch time after a mid-battle player switch was not traced; the guaranteed-Roar claim is asserted from the code as written
- Walkthrough leans on biking; CanEncounterWildMon (engine/overworld/events.asm:1164) and GetMapEncounterRate have no bicycle term, so the bike affects travel speed only

## Map -> section lookup

| Map constant | Sections |
|---|---|
| `MAP_AZALEA_GYM` | 04 |
| `MAP_AZALEA_POKECENTER_1F` | 04 |
| `MAP_AZALEA_TOWN` | 04, 05 |
| `MAP_BILLS_FAMILYS_HOUSE` | 05 |
| `MAP_BILLS_HOUSE` | 21 |
| `MAP_BLACKTHORN_CITY` | 13, 15 |
| `MAP_BLACKTHORN_DRAGON_SPEECH_HOUSE` | 13 |
| `MAP_BLACKTHORN_EMYS_HOUSE` | 13 |
| `MAP_BLACKTHORN_GYM_1F` | 13 |
| `MAP_BLACKTHORN_GYM_2F` | 13 |
| `MAP_BLACKTHORN_MART` | 13 |
| `MAP_BLACKTHORN_POKECENTER_1F` | 13 |
| `MAP_BRUNOS_ROOM` | 18 |
| `MAP_BURNED_TOWER_B1F` | 32 |
| `MAP_CELADON_CAFE` | 22 |
| `MAP_CELADON_CITY` | 22 |
| `MAP_CELADON_DEPT_STORE_1F` | 22 |
| `MAP_CELADON_DEPT_STORE_2F` | 22 |
| `MAP_CELADON_DEPT_STORE_3F` | 22 |
| `MAP_CELADON_DEPT_STORE_4F` | 22 |
| `MAP_CELADON_DEPT_STORE_5F` | 22 |
| `MAP_CELADON_DEPT_STORE_6F` | 22 |
| `MAP_CELADON_GAME_CORNER` | 22 |
| `MAP_CELADON_GAME_CORNER_PRIZE_ROOM` | 22 |
| `MAP_CELADON_GYM` | 22 |
| `MAP_CELADON_MANSION_1F` | 22 |
| `MAP_CELADON_MANSION_2F` | 22 |
| `MAP_CELADON_MANSION_3F` | 22 |
| `MAP_CELADON_MANSION_ROOF` | 22 |
| `MAP_CELADON_MANSION_ROOF_HOUSE` | 22 |
| `MAP_CERULEAN_CITY` | 21 |
| `MAP_CERULEAN_GYM` | 21 |
| `MAP_CHERRYGROVE_CITY` | 01 |
| `MAP_CHERRYGROVE_EVOLUTION_SPEECH_HOUSE` | 01 |
| `MAP_CHERRYGROVE_GYM_SPEECH_HOUSE` | 01 |
| `MAP_CHERRYGROVE_MART` | 01 |
| `MAP_CHERRYGROVE_POKECENTER_1F` | 01 |
| `MAP_CIANWOOD_CITY` | 08 |
| `MAP_CIANWOOD_GYM` | 08 |
| `MAP_CIANWOOD_LUGIA_SPEECH_HOUSE` | 08 |
| `MAP_CIANWOOD_PHARMACY` | 08 |
| `MAP_CIANWOOD_PHOTO_STUDIO` | 08 |
| `MAP_CIANWOOD_POKECENTER_1F` | 08 |
| `MAP_CINNABAR_ISLAND` | 27 |
| `MAP_CINNABAR_POKECENTER_1F` | 27 |
| `MAP_COPYCATS_HOUSE_1F` | 22 |
| `MAP_COPYCATS_HOUSE_2F` | 22 |
| `MAP_DARK_CAVE_BLACKTHORN_ENTRANCE` | 15, 16 |
| `MAP_DARK_CAVE_VIOLET_ENTRANCE` | 01, 15, 16 |
| `MAP_DAY_CARE` | 05 |
| `MAP_DAY_OF_WEEK_SIBLINGS_HOUSE` | 16 |
| `MAP_DIGLETTS_CAVE` | 24 |
| `MAP_DRAGONS_DEN_1F` | 13 |
| `MAP_DRAGONS_DEN_B1F` | 13 |
| `MAP_ECRUTEAK_CITY` | 10, 25 |
| `MAP_ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | 14, 25 |
| `MAP_ECRUTEAK_TIN_TOWER_ENTRANCE` | 14, 25 |
| `MAP_ELMS_LAB` | 00, 01, 16, 19 |
| `MAP_FAST_SHIP_1F` | 19 |
| `MAP_FAST_SHIP_B1F` | 19 |
| `MAP_FAST_SHIP_CABINS_NNW_NNE_NE` | 19 |
| `MAP_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN` | 19 |
| `MAP_FAST_SHIP_CABINS_SW_SSW_NW` | 19 |
| `MAP_FIGHTING_DOJO` | 20 |
| `MAP_FUCHSIA_CITY` | 23 |
| `MAP_FUCHSIA_GYM` | 23 |
| `MAP_FUCHSIA_POKECENTER_1F` | 23 |
| `MAP_GOLDENROD_BIKE_SHOP` | 05 |
| `MAP_GOLDENROD_CITY` | 05, 09, 12 |
| `MAP_GOLDENROD_DEPT_STORE_1F` | 05 |
| `MAP_GOLDENROD_DEPT_STORE_2F` | 05 |
| `MAP_GOLDENROD_DEPT_STORE_3F` | 05 |
| `MAP_GOLDENROD_DEPT_STORE_4F` | 05 |
| `MAP_GOLDENROD_DEPT_STORE_5F` | 05 |
| `MAP_GOLDENROD_DEPT_STORE_6F` | 05 |
| `MAP_GOLDENROD_DEPT_STORE_B1F` | 12 |
| `MAP_GOLDENROD_FLOWER_SHOP` | 05, 06 |
| `MAP_GOLDENROD_GAME_CORNER` | 05 |
| `MAP_GOLDENROD_GYM` | 05 |
| `MAP_GOLDENROD_MAGNET_TRAIN_STATION` | 05 |
| `MAP_GOLDENROD_POKECENTER_1F` | 05 |
| `MAP_GOLDENROD_UNDERGROUND` | 05, 09, 12 |
| `MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 05, 09, 12 |
| `MAP_GOLDENROD_UNDERGROUND_WAREHOUSE` | 12 |
| `MAP_GUIDE_GENTS_HOUSE` | 01 |
| `MAP_HALL_OF_FAME` | 18 |
| `MAP_ICE_PATH_1F` | 13 |
| `MAP_ICE_PATH_B1F` | 13 |
| `MAP_ICE_PATH_B2F_BLACKTHORN_SIDE` | 13 |
| `MAP_ICE_PATH_B2F_MAHOGANY_SIDE` | 13 |
| `MAP_ICE_PATH_B3F` | 13 |
| `MAP_ILEX_FOREST` | 05 |
| `MAP_ILEX_FOREST_AZALEA_GATE` | 05 |
| `MAP_INDIGO_PLATEAU_POKECENTER_1F` | 18 |
| `MAP_KARENS_ROOM` | 18 |
| `MAP_KOGAS_ROOM` | 18 |
| `MAP_KURTS_HOUSE` | 04 |
| `MAP_LAKE_OF_RAGE` | 10 |
| `MAP_LAKE_OF_RAGE_HIDDEN_POWER_HOUSE` | 10 |
| `MAP_LAKE_OF_RAGE_MAGIKARP_HOUSE` | 10 |
| `MAP_LANCES_ROOM` | 18 |
| `MAP_LAVENDER_TOWN` | 22 |
| `MAP_LAV_RADIO_TOWER_1F` | 22 |
| `MAP_MAHOGANY_GYM` | 11 |
| `MAP_MAHOGANY_MART_1F` | 10, 11 |
| `MAP_MAHOGANY_POKECENTER_1F` | 10, 11 |
| `MAP_MAHOGANY_RED_GYARADOS_SPEECH_HOUSE` | 10 |
| `MAP_MAHOGANY_TOWN` | 10, 11, 15 |
| `MAP_MANIAS_HOUSE` | 08 |
| `MAP_MOUNT_MOON` | 26 |
| `MAP_MOUNT_MOON_GIFT_SHOP` | 26 |
| `MAP_MOUNT_MOON_SQUARE` | 26 |
| `MAP_MOUNT_MORTAR_1F_INSIDE` | 15 |
| `MAP_MOUNT_MORTAR_1F_OUTSIDE` | 15 |
| `MAP_MOUNT_MORTAR_2F_INSIDE` | 15 |
| `MAP_MOUNT_MORTAR_B1F` | 15 |
| `MAP_MOVE_DELETERS_HOUSE` | 13 |
| `MAP_MR_POKEMONS_HOUSE` | 01 |
| `MAP_MR_PSYCHICS_HOUSE` | 20 |
| `MAP_NATIONAL_PARK` | 06 |
| `MAP_NATIONAL_PARK_BUG_CONTEST` | 06 |
| `MAP_NEW_BARK_TOWN` | 00, 01, 16, 19 |
| `MAP_OAKS_LAB` | 26, 29 |
| `MAP_OLIVINE_CAFE` | 08 |
| `MAP_OLIVINE_CITY` | 08, 09, 19 |
| `MAP_OLIVINE_GOOD_ROD_HOUSE` | 08 |
| `MAP_OLIVINE_GYM` | 09 |
| `MAP_OLIVINE_LIGHTHOUSE_1F` | 08, 09 |
| `MAP_OLIVINE_LIGHTHOUSE_2F` | 08, 09 |
| `MAP_OLIVINE_LIGHTHOUSE_3F` | 08, 09 |
| `MAP_OLIVINE_LIGHTHOUSE_4F` | 08, 09 |
| `MAP_OLIVINE_LIGHTHOUSE_5F` | 08, 09 |
| `MAP_OLIVINE_LIGHTHOUSE_6F` | 08, 09 |
| `MAP_OLIVINE_MART` | 08 |
| `MAP_OLIVINE_POKECENTER_1F` | 08 |
| `MAP_OLIVINE_PORT` | 19 |
| `MAP_OLIVINE_PORT_PASSAGE` | 19 |
| `MAP_PALLET_TOWN` | 26, 29 |
| `MAP_PEWTER_CITY` | 24 |
| `MAP_PEWTER_GYM` | 24 |
| `MAP_PEWTER_POKECENTER_1F` | 24 |
| `MAP_PLAYERS_HOUSE_1F` | 00, 01 |
| `MAP_PLAYERS_HOUSE_2F` | 00 |
| `MAP_POKEMON_FAN_CLUB` | 19, 22 |
| `MAP_POWER_PLANT` | 21, 22 |
| `MAP_RADIO_TOWER_1F` | 05, 12 |
| `MAP_RADIO_TOWER_2F` | 12 |
| `MAP_RADIO_TOWER_3F` | 12 |
| `MAP_RADIO_TOWER_4F` | 12 |
| `MAP_RADIO_TOWER_5F` | 12 |
| `MAP_ROCK_TUNNEL_1F` | 22 |
| `MAP_ROCK_TUNNEL_B1F` | 22 |
| `MAP_ROUTE_1` | 26 |
| `MAP_ROUTE_10_NORTH` | 21, 22 |
| `MAP_ROUTE_10_SOUTH` | 22 |
| `MAP_ROUTE_11` | 23 |
| `MAP_ROUTE_12` | 23 |
| `MAP_ROUTE_12_SUPER_ROD_HOUSE` | 23 |
| `MAP_ROUTE_13` | 23 |
| `MAP_ROUTE_14` | 23 |
| `MAP_ROUTE_15` | 23 |
| `MAP_ROUTE_15_FUCHSIA_GATE` | 23 |
| `MAP_ROUTE_16` | 23 |
| `MAP_ROUTE_16_FUCHSIA_SPEECH_HOUSE` | 23 |
| `MAP_ROUTE_16_GATE` | 23 |
| `MAP_ROUTE_17` | 23 |
| `MAP_ROUTE_17_ROUTE_18_GATE` | 23 |
| `MAP_ROUTE_18` | 23 |
| `MAP_ROUTE_19` | 24, 28 |
| `MAP_ROUTE_19_FUCHSIA_GATE` | 24, 28 |
| `MAP_ROUTE_2` | 24 |
| `MAP_ROUTE_20` | 24, 27, 28 |
| `MAP_ROUTE_21` | 27 |
| `MAP_ROUTE_22` | 29 |
| `MAP_ROUTE_23` | 17, 18 |
| `MAP_ROUTE_24` | 21 |
| `MAP_ROUTE_25` | 21 |
| `MAP_ROUTE_26` | 16 |
| `MAP_ROUTE_26_HEAL_HOUSE` | 16 |
| `MAP_ROUTE_27` | 16 |
| `MAP_ROUTE_27_SANDSTORM_HOUSE` | 16 |
| `MAP_ROUTE_28` | 29 |
| `MAP_ROUTE_28_STEEL_WING_HOUSE` | 29 |
| `MAP_ROUTE_29` | 01, 32 |
| `MAP_ROUTE_29_ROUTE_46_GATE` | 01, 16 |
| `MAP_ROUTE_2_GATE` | 24 |
| `MAP_ROUTE_2_NUGGET_HOUSE` | 24 |
| `MAP_ROUTE_3` | 26 |
| `MAP_ROUTE_30` | 01, 32 |
| `MAP_ROUTE_30_BERRY_HOUSE` | 01 |
| `MAP_ROUTE_31` | 01, 15, 32 |
| `MAP_ROUTE_31_VIOLET_GATE` | 01 |
| `MAP_ROUTE_32` | 03, 30, 32 |
| `MAP_ROUTE_32_POKECENTER_1F` | 03 |
| `MAP_ROUTE_32_RUINS_OF_ALPH_GATE` | 03 |
| `MAP_ROUTE_33` | 03, 32 |
| `MAP_ROUTE_34` | 05, 32 |
| `MAP_ROUTE_34_ILEX_FOREST_GATE` | 05 |
| `MAP_ROUTE_35` | 06, 32 |
| `MAP_ROUTE_35_GOLDENROD_GATE` | 06 |
| `MAP_ROUTE_35_NATIONAL_PARK_GATE` | 06 |
| `MAP_ROUTE_36` | 06, 32 |
| `MAP_ROUTE_36_NATIONAL_PARK_GATE` | 06 |
| `MAP_ROUTE_36_RUINS_OF_ALPH_GATE` | 03 |
| `MAP_ROUTE_37` | 06, 32 |
| `MAP_ROUTE_38` | 08, 32 |
| `MAP_ROUTE_38_ECRUTEAK_GATE` | 08 |
| `MAP_ROUTE_39` | 08, 32 |
| `MAP_ROUTE_39_BARN` | 08 |
| `MAP_ROUTE_39_FARMHOUSE` | 08 |
| `MAP_ROUTE_4` | 26 |
| `MAP_ROUTE_40` | 08, 32 |
| `MAP_ROUTE_41` | 08, 14, 25, 32 |
| `MAP_ROUTE_42` | 10, 15, 32 |
| `MAP_ROUTE_42_ECRUTEAK_GATE` | 10 |
| `MAP_ROUTE_43` | 10, 32 |
| `MAP_ROUTE_43_GATE` | 10 |
| `MAP_ROUTE_43_MAHOGANY_GATE` | 10 |
| `MAP_ROUTE_44` | 13, 32 |
| `MAP_ROUTE_45` | 15, 16, 32 |
| `MAP_ROUTE_46` | 01, 15, 16, 32 |
| `MAP_ROUTE_5` | 21 |
| `MAP_ROUTE_5_CLEANSE_TAG_HOUSE` | 21 |
| `MAP_ROUTE_5_SAFFRON_GATE` | 21 |
| `MAP_ROUTE_5_UNDERGROUND_PATH_ENTRANCE` | 21 |
| `MAP_ROUTE_6` | 20 |
| `MAP_ROUTE_6_SAFFRON_GATE` | 20 |
| `MAP_ROUTE_6_UNDERGROUND_PATH_ENTRANCE` | 20 |
| `MAP_ROUTE_7` | 22 |
| `MAP_ROUTE_7_SAFFRON_GATE` | 22 |
| `MAP_ROUTE_8` | 22 |
| `MAP_ROUTE_8_SAFFRON_GATE` | 22 |
| `MAP_ROUTE_9` | 21 |
| `MAP_RUINS_OF_ALPH_AERODACTYL_CHAMBER` | 03 |
| `MAP_RUINS_OF_ALPH_INNER_CHAMBER` | 03 |
| `MAP_RUINS_OF_ALPH_KABUTO_CHAMBER` | 03 |
| `MAP_RUINS_OF_ALPH_OUTSIDE` | 03 |
| `MAP_RUINS_OF_ALPH_RESEARCH_CENTER` | 03 |
| `MAP_SAFFRON_CITY` | 20, 22 |
| `MAP_SAFFRON_GYM` | 20 |
| `MAP_SAFFRON_MAGNET_TRAIN_STATION` | 20, 22 |
| `MAP_SAFFRON_MART` | 20 |
| `MAP_SAFFRON_POKECENTER_1F` | 20 |
| `MAP_SEAFOAM_GYM` | 27 |
| `MAP_SILPH_CO_1F` | 20 |
| `MAP_SILVER_CAVE_ITEM_ROOMS` | 31 |
| `MAP_SILVER_CAVE_OUTSIDE` | 29, 31 |
| `MAP_SILVER_CAVE_POKECENTER_1F` | 29, 31 |
| `MAP_SILVER_CAVE_ROOM_1` | 31 |
| `MAP_SILVER_CAVE_ROOM_2` | 31 |
| `MAP_SILVER_CAVE_ROOM_3` | 31 |
| `MAP_SLOWPOKE_WELL_B1F` | 04 |
| `MAP_SLOWPOKE_WELL_B2F` | 04 |
| `MAP_SOUL_HOUSE` | 22 |
| `MAP_SPROUT_TOWER_1F` | 02 |
| `MAP_SPROUT_TOWER_2F` | 02 |
| `MAP_SPROUT_TOWER_3F` | 02 |
| `MAP_TEAM_ROCKET_BASE_B1F` | 11 |
| `MAP_TEAM_ROCKET_BASE_B2F` | 11 |
| `MAP_TEAM_ROCKET_BASE_B3F` | 11 |
| `MAP_TIN_TOWER_1F` | 14, 25 |
| `MAP_TIN_TOWER_2F` | 14, 25 |
| `MAP_TIN_TOWER_3F` | 14, 25 |
| `MAP_TIN_TOWER_4F` | 14, 25 |
| `MAP_TIN_TOWER_5F` | 14, 25 |
| `MAP_TIN_TOWER_6F` | 14, 25 |
| `MAP_TIN_TOWER_7F` | 14, 25 |
| `MAP_TIN_TOWER_8F` | 14, 25 |
| `MAP_TIN_TOWER_9F` | 14, 25 |
| `MAP_TIN_TOWER_ROOF` | 14, 25 |
| `MAP_TOHJO_FALLS` | 16 |
| `MAP_TRAINER_HOUSE_1F` | 26 |
| `MAP_TRAINER_HOUSE_B1F` | 26 |
| `MAP_UNION_CAVE_1F` | 03, 30 |
| `MAP_UNION_CAVE_B1F` | 03, 30 |
| `MAP_UNION_CAVE_B2F` | 03, 30 |
| `MAP_VERMILION_CITY` | 19, 22, 24 |
| `MAP_VERMILION_GYM` | 19 |
| `MAP_VERMILION_POKECENTER_1F` | 24 |
| `MAP_VERMILION_PORT` | 19 |
| `MAP_VERMILION_PORT_PASSAGE` | 19 |
| `MAP_VICTORY_ROAD` | 17 |
| `MAP_VICTORY_ROAD_GATE` | 16, 17, 29, 31 |
| `MAP_VIOLET_CITY` | 01, 02, 32 |
| `MAP_VIOLET_GYM` | 02 |
| `MAP_VIOLET_POKECENTER_1F` | 02, 03 |
| `MAP_VIRIDIAN_CITY` | 26, 28, 29 |
| `MAP_VIRIDIAN_GYM` | 28 |
| `MAP_VIRIDIAN_POKECENTER_1F` | 28 |
| `MAP_WHIRL_ISLAND_B1F` | 14, 25 |
| `MAP_WHIRL_ISLAND_B2F` | 14, 25 |
| `MAP_WHIRL_ISLAND_CAVE` | 14, 25 |
| `MAP_WHIRL_ISLAND_LUGIA_CHAMBER` | 14, 25 |
| `MAP_WHIRL_ISLAND_NE` | 14, 25 |
| `MAP_WHIRL_ISLAND_NW` | 14, 25 |
| `MAP_WHIRL_ISLAND_SE` | 14, 25 |
| `MAP_WHIRL_ISLAND_SW` | 14, 25 |
| `MAP_WILLS_ROOM` | 18 |

