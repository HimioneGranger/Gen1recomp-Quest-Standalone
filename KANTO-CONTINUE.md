# KANTO-CONTINUE: executing the never-run half of Gold (sections 19-32)

Deferred from the 2026-08-09 fix campaign by request. This doc is self-contained: the
audit documents it was distilled from are being retired, so everything a future session
needs is here.

## What this is

The Johto main line (walkthrough sections 00-18) is proven: the route bot beats Champion
Lance with every row passing. Kanto (sections 19-32) is extracted and wired but has
NEVER been executed by any bot row, driver, or human. Every entry below reads clean in
static review (cache + code + cart source were cross-checked adversarially); the risk is
purely runtime. The job: make each beat actually run, fix what breaks, and leave
executable evidence (bot rows or assertion drivers) behind.

## State after the 2026-08-09 campaign (what changed under you)

- ~80 defects fixed across the port; 91/91 gen2 suites, engine 128/128, T3 all green.
- The post-game handoff WORKS now: post-E4 credits end at the title screen, and
  CONTINUE consumes the post-game spawn (HallOfFame.consumePostGameSpawn): after Lance
  you continue in NEW_BARK_TOWN, after Red at SILVER_CAVE_OUTSIDE (23,20). Section 19
  is reachable by normal play for the first time.
- The Snorlax wake chain is fully functional (engine-flag bridge unlocks the Pokegear
  and EXPN card; the tuned radio song persists after closing the gear; SnorlaxAwake
  fires; proven live by tests/drivers/gold_radio_persist.lua).
- Landed systems Kanto beats depend on: phone random/outgoing calls, field item use
  (Escape Rope/Dig via save.backupWarp), Repel, swarms, Rock Smash encounters,
  waterfall current tiles, roamer scatter on CONTINUE, trap volatiles + FORCESHINY
  battle types (beast catching in section 32 is now mechanically possible), badge
  boosts, held items, specialty balls (Lure Ball needs battleType 'fish', already
  stamped by updateFishing).
- NPC HOUR WINDOWS are now enforced (they were not when the Johto route was authored).
  Any Kanto row that talks to a time-gated NPC must pin the clock (POKEPORT_GOLD_HOUR /
  POKEPORT_GOLD_DAY) or handle absence. Only 11 hour-gated objects exist on the whole
  cart: CELADON_GAME_CORNER 6/7, GOLDENROD_GAME_CORNER 4/5, MOUNT_MOON_GIFT_SHOP 1-4,
  and the three Moms in PLAYERS_HOUSE_1F; Celadon and Mt Moon are the Kanto exposures.
- The game clock now anchors on every new game (cart InitClock semantics), so time of
  day no longer follows the host wall clock in driver runs; POKEPORT_GOLD_HOUR pins
  the anchored base too. Runs are reproducible across day/night; a pre-existing flake
  class (night runs catching HOOTHOOT where day runs catch PIDGEY, shifting grind
  levels) died with it.
- Battles hit harder both ways since the cart MIN_DAMAGE floor landed; grind budgets
  tuned for the old numbers may need a nudge.

## Known bot weaknesses to expect (verified pre-existing, not campaign regressions)

- Pathfinding pocket: travel into ILEX_FOREST / SLOWPOKE_WELL bounces (probe
  CHERRYGROVE_CITY>ILEX_FOREST reports no route), and route row 16.54 gives up the
  walk to VICTORY_ROAD_GATE with the identical TELEPORT signature in every logged run.
  Kanto routing should waypoint doors explicitly per the ops recipes above.
- Optional buy rows 04.5d and 18.g4/18.g5 fail whenever the wallet is empty at that
  point in the run; they are budgeting gaps in the route, not engine bugs.
- Grind row 08.g (Route 41 water) has almost no margin; with the clock now anchored
  its inputs are stable, but a low-level POLIWAG catch can still stretch it.

## How to run things

Identity/cache: gold-dev (~/Library/Application Support/LOVE/gold-dev/gold), rebuilt
2026-08-09 with swarm/rock/roam tables. Checkpoints gold-ckpt-NN.lua exist per section;
gold-ckpt-18-pristine.lua is the post-E4 seed. ROM: ../decprep/Pokemon - Gold
Version.gbc. Cart source: ../pokegold (cite it in any hand-ported code).

Headless love needs a pty on macOS; wrap every run:
  perl -e 'alarm 900; exec @ARGV' python3 -c "import pty; pty.spawn(['love','.'])"

Full bot run:  POKEPORT_IDENTITY=<id> POKEPORT_GAME=gold POKEPORT_SPEED=200 \
  POKEPORT_GOLD_CKPT=1 POKEPORT_GOLD_STALL=20000 POKEPORT_GOLD_LOG=/tmp/b.log \
  POKEPORT_DRIVER=tests/drivers/gold_bot.lua love .
Resume a section: POKEPORT_GOLD_RESUME=NN (same identity, prior CKPT=1 run).
Travel probe: POKEPORT_GOLD_PROBE="MAP_A>MAP_B" with tests/drivers/gold_travel_probe.lua.
Map graph: luajit tools/goldwalk/mapgraph.lua path|map|reach|audit; regenerate
tests/drivers/gold/map_regions.lua with `mapgraph.lua graph >` after ANY extractor map
change, then re-check route region indices.
Route validation (before any run): luajit tests/gold_route_validate_test.lua and
luajit tests/gold_flag_names_test.lua.
Suites: GOLD_CACHE="$HOME/Library/Application Support/LOVE/gold-dev/gold" luajit
tests/gen2_<name>_test.lua; tiers run_engine/run_modkit/run_tests.
Reimport after extractor/manifest changes: python3 tools/make_gold_manifest.py, then
POKEPORT_IMPORT_TRACE=1 POKEPORT_IDENTITY=gold-dev POKEPORT_IMPORT_ROM="../decprep/\
Pokemon - Gold Version.gbc" POKEPORT_IMPORT_ONLY=1 POKEPORT_FORCE_IMPORT=1 \
POKEPORT_GAME=gold love .

## Recommended shape of the work

1. Extend tests/drivers/gold/route.lua with sections 19-32 (the row format, ops and
   evidence rules are documented in the file head and bot.lua). Seed runs from
   gold-ckpt-18-pristine plus the now-working post-credits CONTINUE. `expect` flags are
   the only oracles; never make a row load-bearing on a soft-failing map.
2. Highest-risk multi-map scripted chains first: S.S. Aqua voyage, Machine Part chain,
   PASS/Magnet Train chain. Each deserves an assertion driver even if bot rows also
   cover it.
3. Time-gated beats (S.S. Aqua sailing days, Indigo rival Mon/Wed, Dragon's Den
   Tue/Thu, Clefairy Monday night, TM03 night gate) need POKEPORT_GOLD_DAY/HOUR pins.
4. Johto stragglers are folded in below (lighthouse descent, TM08 flake, and the
   optional gift beats); they ride the same route-extension pass.
5. Section 32 (beasts) last: it needs long roaming play; trap volatiles and FORCESHINY
   landed this campaign, so Mean Look + Heavy/Fast Ball plans are now viable.

## Also deferred (deliberate stubs, do not re-flag)

Time Capsule trading, Trainer House CAL2/Mystery Gift visitor, Silver-version import,
Cable Club link rooms, and Game Boy Printer output are deliberate product-level stubs,
not campaign work.

## The beats, in walkthrough order

### Runtime coverage ends at the Hall of Fame: no bot row, driver, or human has run any Kanto beat (sections 19-32) or the section 14 Tin Tower/Whirl Islands content

walkthrough section(s) 19,20,21,22,23,24,27,28,29,30,31,14 | missing

One root cause: tests/drivers/gold/route.lua (1264 lines) ends at row 18.20 (settle HALL_OF_FAME, expect EVENT_BEAT_ELITE_FOUR); the campaign covers asm-walk sections 00-18 only and none of the 24/36 gold_* drivers reaches any Kanto map, so sections 19-32 have zero execution proof. Extend route.lua into sections 19-32 and/or add targeted drivers. Per section pair: (s19/20) next rows are the Elm ticket (needs the post-credits spawn fix or a fly detour from Indigo), the ship crossing as far as the docking events, the Surge fight, and a Saffron Gym pad-chain assertion. (s21/22) All 24 route/gym trainers resolve in cache with correct parties: Route 9 six (Edna, Sid, Dean, Sidney, Tim, Heidi); Route 25 seven plus Kevin, whose Nugget-then-battle script 50:488d is hand-shaped (a full bag aborts before the battle, cart behavior); Cerulean's three swimmers; Route 10 South's Jim and Robert (Robert's Quagsire holds a BERRY via TRAINERTYPE_ITEM); Route 8's five; Celadon Gym's five including the twins' shared beat flag. Sight-line engagement is Trainers.sees (proven by the Johto bot); prize money base x level x 4 is Prize.lua; Erika's class item extracts as HYPER_POTION (the walkthrough's 'three Full Restores' is a FAQ error, not a port gap); Gold-only wilds (Mankey line Route 9, Growlithe Routes 7/8) come from the ROM version branch; Route 8's PRZCureBerry fruit tree is a fruittree op (Vm.lua:1218) into Apricorns.lua daily reset. One Kanto smoke-run converts the whole block. (s23/24) Nothing touches Routes 11-19, Fuchsia City/gym, Vermilion Snorlax, Diglett's Cave, Route 2, Pewter; the report's three blocker findings (START menu row, Pokegear card flags, radio persistence) are exactly the UI-plumbing breaks data audits miss: a gold_snorlax_wake.lua that grants the gear and EXPN card the way the game does (setflag 4, setflag 0, setflag 3 through the VM, not by poking save fields), tunes the radio, closes the gear, and talks to the Snorlax would currently fail at three separate steps; gold_cycling_road.lua and gold_fuchsia_gym.lua are the other two cheap proofs (gold_menu_shots.lua:72-73 only ever hand-seeded save fields). (s27/28) Drive first: (1) Cinnabar Blue talk -> disappear -> clearevent 1910 -> Viridian Gym populated -> Blue beaten -> ENGINE_EARTHBADGE set -> VAR_BADGES answers 16 (a break anywhere makes the 16th badge unobtainable and the Mt. Silver gate unpassable); cache chain exists: CINNABAR_ISLAND obj 1 SPRITE_BLUE at (9,6) scriptKey 4e:4985 eventFlag 1909; VIRIDIAN_GYM objs 1-2 gated on 1910; (2) the ROUTE_20 MAPCALLBACK_NEWMAP 4e:4cfa setevent 215 / ROUTE_19 MAPCALLBACK_TILES 4e:4f09 changeblock unseal pair (regression walls off Route 19). Driver: surf Pallet -> Route 21 -> Cinnabar -> talk to Blue -> Route 20 -> beat Blaine -> fly to Viridian -> beat Blue. (s29/30) No rows for Kanto OAKS_LAB, ROUTE_22, ROUTE_28, SILVER_CAVE_OUTSIDE, or the Union Cave B2F Lapras revisit (route.lua's only Union Cave rows are 03.29/04.g); risk concentrates on composites never run together: the 16-badge Oak visit with ProfOaksPCBoot text chain, the double Cut approach to the Route 28 west strip, surf-to-talk on the drifting SWIM_WANDER Lapras (Lake of Rage Gyarados proves the shape via gold_lake_probe.lua), and the daily-flag consume-and-respawn cycle across a save reload; a targeted gold_lapras_probe driver (clockDay=5, walk in, assert object present, catch, walk out, re-enter, assert gone) plus route extension converts inspected to proven. (s31) All six Silver Cave maps decode (warps, item balls flags 1689-1693, hidden items, SILVER_CAVE_OUTSIDE flypoint callback, PALETTE_DARK on Room 1, grass/water tables including Room 2 water); Flash lifts PALETTE_DARK via Palettes.isDarkness + World flashUsed; Surf/Waterfall live in FieldMoves with the badge table; gen2 ledges landed via Permissions.ledgeFacings / World:tryLedgeJump (the asm-walk's 'ledge hop missing' row is stale, GOLD-NEXT-RUN records the fix); the flypoint is FieldMoves.lua:386 flag 75; but no driver has entered Silver Cave, used Waterfall on Room 2's two bands, hopped Room 1's Escape Rope ledge, or talked to Red (closest: gold_halloffame_shots, gold_hm07_probe which proved Waterfall only at Tohjo Falls). (s14) The bot covers sections 10,11,12,13,16,17,18 and never section 14 (Ho-Oh is optional); untested: the 4F-9F ladder/hop mazes (depend on the recently added ledge-hop and one-way-wall support), the Ecruteak entrance sage scene retarget from Morty's setmapscene, the 1F sage unmasking off EVENT_TEAM_ROCKET_DISBANDED (set on the Gold arm of the Radio Tower boss script), the roof save/reset loop, and the entire Gold-side Whirl Islands dive; needs one probe driver carrying a RAINBOW_WING save up the tower and one diving to the Lugia chamber.

*How to prove it:* Extend tests/drivers/gold/route.lua past row 18.20 into sections 19-32, and/or write the named targeted drivers: gold_snorlax_wake.lua, gold_cycling_road.lua, gold_fuchsia_gym.lua, a gold_lapras_probe (clockDay=5 present/absent cycle), a Cinnabar-to-Viridian 16th-badge driver, a Route 20/19 unseal driver, a Silver Cave/Red driver, a Tin Tower RAINBOW_WING probe, and a Whirl Islands Lugia dive probe.

*Notes:* Merged from the parent heading plus six 'Also filed as' sub-findings (all one cause). Doc's own ratings: parent missing/minor (s19,20, already in ledger); s21,22 unverified/minor; s23,24 unverified/minor; s27,28 missing/major; s29,30 unverified/minor; s31 unverified/minor; s14 unverified/minor. The adversarial re-check ran on the s27/28 sub-claim, tried to refute and could not; its one correction: tests/drivers/gold/flag_names.lua and map_regions.lua DO name the Kanto maps (map_regions even carries CINNABAR/SEAFOAM/VIRIDIAN region graphs, so bot travel there is data-ready) but they are lookup tables, not executed coverage. 'Implemented statically, executed by nobody' matches the project's Roamers/Events:restore failure mode. GOLD-WALK-HANDOFF sections 1 and 4 already document the Johto-only scope.


### Olivine Port pier and Fast Ship boarding gate: the only road into Kanto, fully extracted, never executed

walkthrough section(s) 19 | unverified

Coord event at (7,15) (cache 5b:407d) does the full cart sequence: temporary-event bails, first-time bypass on event 48, readvar VAR_WEEKDAY branch, yesorno, checkitem S_S_TICKET (item 68), setevent 1, 7-step applymovement, sjump into gangway script 5b:401e which plays SFX, disappears/appears the sailor, runs special 46 = FadeOutToWhite (specialOrder[46+1], implemented Specials.lua:998), clears the eight eastbound EVENT_BEAT_* rematch flags on repeat trips, sets FAST_SHIP_1F scene 1, and warps to (25,1). Port sprite toggles for the post-Hall-of-Fame sailor (events 1847/1848) are armed by the HOF script. All data extracted, every op has a proven Johto call site; matched op-for-op against pokegold maps/OlivinePort.asm. Needs one live run or driver.

*How to prove it:* A driver or bot section that reaches OLIVINE_PORT post-HOF with the S_S_TICKET, boards, and asserts the warp to FAST_SHIP_1F (25,1) with scene 1 set. No gold_* driver currently reaches OLIVINE_PORT post-HOF.

*Notes:* Doc rating: unverified/blocker, new. If this chain fails, the walkthrough stops here (Kanto unreachable).


### S.S. Aqua maiden voyage: trainer gauntlet, lazy sailor, granddaughter, Metal Coat, docking; extracted end to end, never run

walkthrough section(s) 19 | unverified

Verified in cache, never executed: FastShip1F enter scene 5b:48a8 sdefer 5b:48ad (SFX_BOAT, earthquake 30, blackoutmod to cabin map, clearevent 49, scene 2 on first trip); grandpa bump coord events at (24,6)/(25,6); maiden-trip trainer objects behind flag 1849 with parties matching data/trainers/parties.asm exactly (NOLAND Sandslash31/Golem33, LYLE Koffing28/Flareon31/Koffing28, COLIN Delibird32 holding BERRY, MEG&PEG, FRITZ Mr.Mime/Magmar/Machoke, JEFF 2x Raticate32, DEBRA Seaking33, STANLY Machop31/Machoke33/Psyduck26, all in trainers.lua); B1F blocking-sailor coord scripts 5b:5e0c/5b:5e21 plus shared talk script 5b:5e37 clearing event 1837 to spawn the lazy sailor; FastShipLazySailorScript 5b:4d68 (playmusic, loadtrainer SAILOR 9, reloadmap, special 27 = HealParty, setmapscene B1F NOOP, readvar VAR_FACING walk-out); bed script 5b:521b (HealParty, fades, ReloadSpritesNoPalettes, RestartMapMusic, dock check on events 49/50/48 so sleeping cannot dock the maiden voyage); granddaughter payoff 5b:55c6 (fade, disappear/moveobject/appear teleport, showemote, sjump 5b:5633 = Metal Coat verbosegiveitem plus EVENT_FAST_SHIP_HAS_ARRIVED/FOUND_GIRL); door guard 5b:48d2 with arrived arm 5b:48ec (scall facing arm, setmapscene VERMILION_PORT scene 1, warp to VERMILION_PORT 7,17). Specials 27/46/47/49/50/60 resolve to HealParty/FadeOutToWhite/FadeOutToBlack/FadeInFromBlack/ReloadSpritesNoPalettes/RestartMapMusic, all implemented. Nothing in the chain touches a stubbed special, callasm, or VAR. Matched against pokegold maps/FastShip*.asm.

*How to prove it:* A bot section or driver for the full crossing (board, fight or dodge the gauntlet, sleep check, granddaughter Metal Coat, dock at VERMILION_PORT 7,17).

*Notes:* Doc rating: unverified/blocker, new. If any link breaks, arrival in Kanto is impossible.


### Machine Part quest chain (Power Plant manager, Cerulean Gym grunt scene, Route 24 grunt, part return, TM07) never executed

walkthrough section(s) 21,22 | unverified

The spine of sections 21-22: manager talk sets EVENT_MET_MANAGER_AT_POWER_PLANT 202, clears EVENT_CERULEAN_GYM_ROCKET 1901 and EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM 251, arms CERULEAN_GYM scene 1 and the POWER_PLANT guard phone-call scene; grunt runs out of the gym (sets 203, clears 1900/1902, arms ROUTE_25 scene 1); beat the Route 24 grunt (GRUNTM 31, L30 Golbat); return the part for TM07 Zap Cannon plus EVENT_RESTORED_POWER_TO_KANTO 205 and the Saffron station population flip (clears 1906). Statically verified: cache holds full bytecode for PowerPlantManager 54:4dbd with both branches (54:4deb takeitem MACHINE_PART / 54:4e04 TM give guarded by event 223), gym scene script 54:4332 sdefer 54:4336 with all 34 rows, Route 24 grunt script 50:4407; initial_events.lua seeds flags 251/1900/1901/1902/1903/1906/1907 at new game exactly as InitializeEventsScript does (pokegold engine/events/std_scripts.asm:546-550); World.lua:607 applies the seed while EVENT_INITIALIZED_EVENTS is clear. Engine deps all have call sites: World:trySceneScript (World.lua:5369, called at :6893), setmapscene/setscene (Vm.lua:274-284), specials RestartMapMusic/FadeOutToBlack/FadeInFromBlack/ReloadSpritesNoPalettes/FadeOutMusic (Specials.lua:999-1072). Missing only run-time proof: route bot covers sections 00-18, no Kanto driver exists.

*How to prove it:* Route extension or a driver walking manager -> gym grunt scene -> Route 24 grunt battle -> part return, asserting events 202/203/205 set and 1900/1901/1902/251/1906 cleared and TM07 in bag.

*Notes:* Doc rating: unverified/blocker, new.


### Route 25 Misty date scene, Cerulean gym population, and Misty fight never executed (and Misty gives no TM, contrary to walkthrough)

walkthrough section(s) 21 | unverified

The date cutscene at Route 25 cells (42,6)/(42,7) is what clears EVENT_TRAINERS_IN_CERULEAN_GYM 1903 and populates the gym with Misty, three swimmers, and the guide; without it Misty never appears and the Cascade Badge is unreachable. Cache has both coord events with sceneId=1 (scripts 18305/18369) and full scripts 50:4781/50:47c1 (34-row cutscene: heart emote, boyfriend flees, Misty approach movement, clearevent 1903, setscene 0, special 60=RestartMapMusic), armed by gym grunt script 54:4336 row 27 (setmapscene group=7 map=16 scene=1). Engine deps: World:tryCoordScript (World.lua:5006) filters on the map scene id; mapScenes persist on the save (GOLD-INDEX tier note on World:loadPlayerData). CeruleanGymMistyScript 54:438a is in the cache; MISTY trainer 1 party (L42 Golduck, L42 Quagsire, L44 Lapras, L47 Starmie with full movesets) extracts correctly; baseMoney 25 so the 4700G payout follows from Prize.reward.

*How to prove it:* Driver: arm the scene via the gym grunt, trigger the date coord event at (42,6)/(42,7), assert 1903 cleared and the gym populated, then fight Misty and assert the Cascade Badge and 4700G.

*Notes:* Doc rating: unverified/blocker, new. Correction embedded in the doc: Misty gives NO TM on the Gold cart, only the badge plus retroactive swimmer beat flags; the walkthrough and the lead's 'TM from Misty' are wrong about the cart, nothing is missing in the port there.


### PASS quest: Copycat lost item and Fan Club doll chain fully extracted, never run

walkthrough section(s) 22 | unverified

Copycat (COPYCATS_HOUSE_2F object 1, variable sprite slot 251) talk after the machine part return sets EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM 206; Fan Club Clefairy guy (POKEMON_FAN_CLUB object 3, script 59:437b) then gives LOST_ITEM 130 and disappears the doll (flag 1908, correctly NOT in the initial seed; doc evidence line also cites POKEMON_FAN_CLUB object 5 flag 1908); returning it (Copycat branch 61:528b: takeitem 130, setevent 208, clearevent 1907 to re-show her shelf doll, then PASS 134 via 61:529d) yields the PASS. All bytecode in cache (61:5235/61:5270/61:528b); the mimicry gag's variablesprite slot 11 plus special 93 resolves to LoadUsedSpritesGFX (specialOrder[94], Specials.lua:1033); the Copycat's variable sprite slot is seeded through World.initialSprites/findInitialSprites (World.lua:1530, the fix GOLD-INDEX credits for the Copycat existing at all). Flag 1907 is in the initial seed so the shelf doll is hidden until the return; 1906 is seeded so the Saffron station stays empty until power is restored.

*How to prove it:* Driver: after machine-part return, talk to Copycat (assert 206), get LOST_ITEM at the Fan Club (assert doll flag 1908 set), return it (assert 208 set, 1907 cleared, PASS 134 in bag).

*Notes:* Doc rating: unverified/major, new. Correction embedded: the walkthrough's 'Rail Pass then Magnet Train Pass' is one item (PASS) on the cart, not a port gap. Merge-with hint: the s20 entry 'Copycat lost doll quest chain toward the rail PASS' (copycat-doll-pass-s20) describes the same quest from the section-20 audit with slightly different event ids cited (210/201 gate checks there vs 206/208 here).


### Magnet Train ride wired end to end; arrival behavior needs a human eye, never ridden since

walkthrough section(s) 22 | unverified

SaffronMagnetTrainStationOfficerScript (cache 61:4bc2/61:4bd0, rows 11-14) checks EVENT_RESTORED_POWER_TO_KANTO 205 then checkitem PASS 134, does setval 1, special id=35 which resolves to MagnetTrain (specialOrder[36]), then warpcheck and newloadmap 249 (MAPSETUP_TRAIN). All implemented: H.MagnetTrain (Specials.lua:2119) reads scriptVar for direction and blocks on World:magnetTrain (World.lua:2393) which pushes Gen2MagnetTrainRide; Vm handles warpcheck (:1135) and newloadmap (:1177); MAPSETUP_TRAIN defined at World.lua:175. Gating events (205 set by the Power Plant manager, PASS from the Copycat) are this section's other findings.

*How to prove it:* WHATS-NEXT item 8: a human rides both ways and presses a direction on arrival; the conversation must start on the first step because south is the only legal step out of the doorway cell. Nothing has run this since.

*Notes:* Doc rating: unverified/major, already named in the ledger.


### Silver Wing in Gold: Pewter City gramps script extracted, but Kanto (and the Whirl Islands dive) never run

walkthrough section(s) 14 | unverified

For a Gold cart, Lugia needs the SILVER_WING carried in the bag (WhirlIslandLugiaChamberLugiaCallback does checkevent EVENT_FOUGHT_LUGIA then checkitem SILVER_WING), and in Gold the wing comes from the Pewter City gramps (pokegold maps/PewterCity.asm PewterCityGrampsScript: checkver, Silver arm branches away, Gold falls through to verbosegiveitem SILVER_WING + setevent). Verified in cache: PEWTER_CITY object 3 (SPRITE_GRAMPS at 29,17) scriptKey 4d:583e = faceplayer / opentext / checkver / iftrue 4d:585c / checkevent 121 / verbosegiveitem item 71 / setevent 121 / closetext / end, all generic opcodes. The Lugia chamber map, its SPRITE_LUGIA object (scriptKey 47:41a0, eventFlag 1853), and its MAPCALLBACK_OBJECTS callback (47:418c) are in the cache using only implemented machinery. Route bot has no section 14/25 rows (grep 'id = "1[0-9]' shows 10,11,12,13,16,17,18). One mechanical gap on the dive path: the waterfall forced-down item, reported separately in the doc.

*How to prove it:* Driver or bot rows: reach Pewter in Gold, talk to the gramps (assert SILVER_WING item 71 given, event 121 set), then the full Whirl Islands dive to the Lugia chamber.

*Notes:* Doc rating: unverified/major, new. The waterfall forced-down item on the dive path is a separate finding elsewhere in the doc, not part of this entry.


### Vermilion Port arrival bookkeeping, Vermilion flypoint, and Kanto music never executed

walkthrough section(s) 19 | unverified

Arrival scene (VERMILION_PORT scene 1, sdefer 5b:450e) extracted intact: one step up, appear the gangway sailor, setscene 0, end-of-voyage flags (1841/1840 hide grandpa and granddaughter for good, 1849 retires the maiden-trip trainers, clear 1843 to reveal the Olivine passage Pokefan, set 48 EVENT_FAST_SHIP_FIRST_TIME), and blackoutmod VERMILION_CITY. ENGINE_FLYPOINT_VERMILION comes from MAPCALLBACK_NEWMAP on both VERMILION_PORT and VERMILION_CITY (setflag 57); the port's fly table carries the matching row (FieldMoves.lua:392) and World:runMapCallback has a live call site (World.lua:5659 plus the MAPCALLBACK_OBJECTS call in setMap). Fly deliberately stays region-locked exactly like the cart (FieldMoves.flyPoints, FieldMoves.lua:442: Kanto page only after SPAWN_INDIGO, no cross-region fly, verified against pokegold engine/pokegear/pokegear.asm .KantoFlyMap). Kanto music extracted: audio.lua songs has 92 entries, musicOrder includes Music_VermilionCity and Music_ViridianCity (musicOrder[63]=Music_VermilionCity), mapSongs carries all 362 map rows.

*How to prove it:* Driver: dock at Vermilion, assert flags 1841/1840/1849/48 set and 1843 cleared, flypoint flag 57 set on map entry, and Vermilion/Viridian city music playing.

*Notes:* Doc rating: unverified/major, new.


### Pokemon Fan Club chairman Rare Candy give never run

walkthrough section(s) 19 | unverified

Chairman script 59:4340: checkevent 212 (already heard), checkevent 211 (bag-full retry), yesorno where answering No gives nothing (cart behavior), two promptbutton speech pages, verbosegiveitem item 32 = RARE_CANDY, setevent 212. The cart quirk that nothing ever sets the bag-full retry event 211 is faithfully carried in the extracted bytecode. Same map also holds the Clefairy doll object (flag 1908) and Clefairy Guy script 59:437b that the later Copycat quest reads. yesorno, verbosegiveitem, and multi-page writetext all have proven Johto call sites. Matched against pokegold maps/PokemonFanClub.asm; RARE_CANDY present in items.lua.

*How to prove it:* Covered by any Kanto smoke-run that talks to the chairman and asserts RARE_CANDY given and event 212 set.

*Notes:* Doc rating: unverified/minor, new.


### Lt. Surge gym: trainers, Thunder Badge, AI item use fully extracted, never fought

walkthrough section(s) 19 | unverified

Surge script 59:4bfc: checkflag 36 re-fight guard, loadtrainer class 19 member 1, winlosstext, reloadmapafterbattle (whose loss-abort semantics were fixed during the Johto campaign), retroactive setevent of the three gym trainers, setflag 36 = ENGINE_THUNDERBADGE which routes to save.player.kantoBadges.THUNDER. Parties in trainers.lua match data/trainers/parties.asm exactly: Surge is RAICHU44/ELECTRODE40/MAGNETON40/ELECTRODE40/ELECTABUZZ46 with full TRAINERTYPE_MOVES movesets; Vincent, Horton, Gregory all match (GUITARIST 2/JUGGLER 3/GENTLEMAN 3). Trainer AI item use implemented: Ai.ITEM_ORDER/Ai.chooseItem (Ai.lua:1368-1400) dispatched from Battle.lua:1790 (AI_SwitchOrTryItem) off the extracted class attributes. The gym has no puzzle in Gen 2, matching the walkthrough's power-outage line.

*How to prove it:* Driver or route rows: fight the gym trainers and Surge, assert ENGINE_THUNDERBADGE (flag 36) set into save.player.kantoBadges.THUNDER and the AI HYPER_POTION use path exercised.

*Notes:* Doc rating: unverified/major, new. Correction embedded: the walkthrough's claim that Surge holds a Full Restore is a FAQ error; pokegold data/trainers/attributes.asm line 114 (block 113-117) gives the Lt Surge class HYPER_POTION and the cache carries exactly that (LT_SURGE items=HYPER_POTION, baseMoney 25).


### Route 6 Underground Path blocker and Saffron gate guard extracted, never walked

walkthrough section(s) 20 | unverified

The walkthrough's 'large man who blocks the entire entrance' is the ROUTE6_POKEFAN_M object at (17,4) whose event flag EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH hides him only when SET (set by the Power Plant script in a later section); the port's object-visibility rule 'flag set hides object' is implemented and documented at Events.lua:1-2, and his script is a bare jumptextfaceplayer about the Power Plant. The Route 6 Saffron gate guard at (0,4) stands off the walking lane and is dialogue only (branches on EVENT_RETURNED_MACHINE_PART). ROUTE_6 grass and water encounter tables (Abra/Magnemite slots) are present in encounters.lua. Nothing gated on engine work; it has just never been walked.

*How to prove it:* Covered by any Kanto walk through Route 6 before and after the Power Plant script sets the blocker flag.

*Notes:* Doc rating: unverified/minor, new.


### Mr. Psychic's TM29 Psychic give extracted verbatim, Kanto walk to the door unproven

walkthrough section(s) 20 | unverified

Cache 61:4b15: checkevent 227, writetext, promptbutton, verbosegiveitem item 221 = TM_PSYCHIC_M, iffalse full-bag fall-through WITHOUT setting the flag (cart behavior, re-talk after making room), setevent 227. TM_PSYCHIC_M is in items.lua with pocket TM_HM and price 2000; the four-pocket bag and TM teaching were exercised in the Johto run (TM08 ROCK SMASH teach passed on merit per GOLD-WALK-HANDOFF). Matched against pokegold maps/MrPsychicsHouse.asm.

*How to prove it:* Any Kanto run that walks to the house, talks, and asserts TM29 given and event 227 set (plus the full-bag retry arm).

*Notes:* Doc rating: unverified/minor, new.


### Silph Co. 1F Up-Grade give extracted, never run

walkthrough section(s) 20 | unverified

Cache 61:4f81: same shape as Mr. Psychic, verbosegiveitem item 172 = UP_GRADE guarded by event 222 with the full-bag fall-through. The officer at (13,1) has event flag -1 so he never moves, and SILPH_CO_1F has only the two street-door warps: there is no upstairs in Gen 2, so the 'man blocking the stairway' never opens, matching the cart (verified against pokegold maps/SilphCo1F.asm). Generic mechanisms only. UP_GRADE present in items.lua.

*How to prove it:* Any Kanto run that enters Silph Co. 1F and asserts UP_GRADE given behind event 222.

*Notes:* Doc rating: unverified/minor, new.


### Saffron Gym teleporter maze (30 same-map warp pads) never exercised; same-map warp chains untested anywhere

walkthrough section(s) 20 | unverified

The gym's whole puzzle is 30 warp pads (cache SAFFRON_GYM warps 3-32) that all target SAFFRON_GYM itself; the only route to Sabrina is entrance pad (11,15) -> ... -> (1,5) -> (11,9). The engine mechanism exists and reads correct: pads are COLL_WARP_PANEL 0x7c, an immediate warp (Permissions.lua:311); World:takeWarp (World.lua:6022-6040) handles a destination equal to the current map through setMap; warpCooldown keyed on the landing cell (World.lua:6135 set, 6217-6222, 6240 suppression check) stops the landing pad from re-firing until the player steps off, exactly what a pad-to-pad maze needs. But the asm-walk's own port-coverage table flags that no driver has ever exercised a same-map warp chain, and no Kanto run exists. If this breaks, Sabrina is unreachable and the 10th badge (and eventually Red's gate) is lost.

*How to prove it:* Targeted driver: enter the gym, ride pad (11,15), assert arrival at (19,17), then the full 5-hop chain to (11,9).

*Notes:* Doc rating: unverified/major, new.


### Sabrina battle and Marsh Badge fully extracted, never fought

walkthrough section(s) 20 | unverified

Sabrina script (cache 61:40cf): checkflag 39 guard, loadtrainer class 35 member 1, reloadmapafterbattle, force-sets the four gym trainer flags (so the trainers are skippable, as the walkthrough implies), setflag 39 = ENGINE_MARSHBADGE routed to save.player.kantoBadges.MARSH. Party matches the cart exactly (trainers.lua SABRINA 1: ESPEON46 Sand-Attack/Quick Attack/Swift/Psychic, MR__MIME46 Barrier/Reflect/Baton Pass/Psychic, ALAKAZAM48 Recover/Future Sight/Psychic/Reflect; class item HYPER_POTION, base reward 25, AI attribute words extracted; attributes.asm:209-213). The four trainers (Rebecca, Franklin, Doris, Jared; MEDIUM 6,7 / PSYCHIC_T 2,11; parties verified including the cart's L35 third Exeggcute that the FAQ gets wrong) are OBJECTTYPE_TRAINER with SPINRANDOM movement, which Npc.lua supports, and sight/battle handoff is the proven Trainers.lua path. Prize money base x last-level x4 is implemented in Prize.lua (matches the walkthrough's 4800G).

*How to prove it:* Driver through the warp maze to Sabrina; assert ENGINE_MARSHBADGE (flag 39) into save.player.kantoBadges.MARSH, the four trainer flags force-set, and the 4800G payout.

*Notes:* Doc rating: unverified/major, new. Corrections embedded: the L35 third Exeggcute is cart-correct (the FAQ is wrong); Sabrina's class item is HYPER_POTION.


### Copycat lost doll quest chain toward the rail PASS (section-20 filing): all pieces present and generic, never run

walkthrough section(s) 20 | unverified

Spans this section's maps (Copycat's house is Saffron warp 8, the doll source is the Vermilion Fan Club) though the walkthrough text defers it to after the Power Plant (EVENT_RETURNED_MACHINE_PART gates the dialogue arms). Copycat's 2F object uses variable sprite 251 (SPRITE_COPYCAT), and the new-game variablesprite seeding that used to leave Copycat despawned was fixed during the Johto campaign (tests/gen2_variable_sprites_test.lua, GOLD-WALK-HANDOFF section 5); her script (cache 61:5235) is extracted bytecode whose only special, LoadUsedSpritesGFX, is implemented (Specials.lua:1033); the Fan Club Clefairy Guy (59:437b) checks events 210/201 and gives LOST_ITEM; the doll object (flag 1907) and the PASS handover (verbosegiveitem PASS, setevent EVENT_GOT_PASS_FROM_COPYCAT per pokegold maps/CopycatsHouse2F.asm:61-73) are ordinary ops; PASS is a KEY_ITEM in items.lua. Nothing engine-shaped is missing.

*How to prove it:* Same driver as the s22 PASS quest entry: full Copycat/Fan Club round trip asserting LOST_ITEM, doll flags, and PASS.

*Notes:* Doc rating: unverified/minor, new, named in the leads. Merge-with hint: same quest chain as pass-quest-copycat-fanclub (s22); kept separate because the doc filed them as distinct headings from two section audits. This filing cites Clefairy Guy gate events 210/201 and doll flag 1907; the s22 filing cites 206/208 and doll-disappear flag 1908.


### Celadon side items: TM03 Curse night gate, Leftovers trash can, hidden PP Up (plus Berserk Gene, Route 9 Ether, Route 25 Potion) never run

walkthrough section(s) 22 | unverified

TM03 Curse: roof house pharmacist script 5e:5083 in cache with checktime mask 4 (NITE) at row 7; the Vm checktime opcode (Vm.lua:788) maps NITE to bit 4 off World:timeOfDayId, so the night-only gate should behave; the give branch 5e:509a is guarded by EVENT_GOT_TM03_CURSE 218. Leftovers: CeladonCafeTrashcan bg event at (7,1) key 5e:648c present, plain giveitem bytecode with the flag only set on success so a full pack retries, exactly the cart. Hidden PP Up at Celadon (37,21): BGEVENT_ITEM row present, handled by HiddenItems (fixed PP_UP; the walkthrough's 'random PP Up' is wrong on the cart too). Berserk Gene at Cerulean (2,12), hidden Ether Route 9 (10,5), and hidden Potion Route 25 (4,5) likewise extract. All generic and statically sound, none ever run.

*How to prove it:* Kanto run collecting each: night visit for TM03 (checktime NITE), cafe trash can Leftovers with full-pack retry, hidden-item picks via HiddenItems.

*Notes:* Doc rating: unverified/minor, new. Correction embedded: the PP Up is fixed, not random, on the cart.


### Mt. Moon Square Clefairy dance (Monday night) + hidden Moon Stone + Rock Smash rock: all dependencies present, sequence never executed

walkthrough section(s) 26 | unverified

Coord event at (7,11) scene 0 runs 5b:676a, whose 45 rows extract completely: checkflag 87 (ENGINE_MT_MOON_SQUARE_CLEFAIRY), readvar var 11 (VAR_WEEKDAY, real in the port) ifnotequal 1 (MONDAY), checktime NITE, then the appear/follow/applymovement/cry/showemote dance, clearevent 236 (the hidden Moon Stone flag) and setflag 87. Both callbacks extracted (type 5 NEWMAP 5b:6763 re-hides the stone on entry; type 2 OBJECTS 5b:6767 hides the rock). The rock object (SPRITE_ROCK at 7,7, scriptKey 5b:67ee = jumpstd SmashRockScript) resolves to the real SmashRock/AskRockSmash bodies GOLD-INDEX.md:377-382 documents; follow/stopfollow are implemented (Vm.lua:1009,1026). Flag semantics match the cart: ENGINE_MT_MOON_SQUARE_CLEFAIRY lives in wDailyFlags2 (pokegold constants/engine_flags.asm:105-106) and the port clears id 87 in Apricorns.DAILY_ENGINE_FLAGS, so the dance is once per day, i.e. once per Monday night. Unproven in-game: (a) whether the appeared rock correctly blocks/receives the A press on the Moon Stone tile at (7,7) and Rock Smash then exposes the hidden item in the same visit, and (b) the full follow-chain animation. The stubbed RockMonEncounter (CallAsm STUB_ROWS) does NOT affect this rock: MOUNT_MOON_SQUARE is not in the cart's RockMonMaps (pokegold data/wild/treemon_maps.asm:43-48), so no encounter roll is owed here.

*How to prove it:* Driver: force clockDay=MONDAY clockHour=NITE, walk to (7,11), watch the dance, smash the rock, take the Moon Stone.

*Notes:* Doc rating: unverified/minor, new.


### Rival re-encounters after Mt Moon (Indigo Plateau Mon/Wed rematch, Dragon's Den Tue/Thu cameo) never run

walkthrough section(s) 26 | unverified

Both beats are pure extracted content keyed on EVENT_BEAT_RIVAL_IN_MT_MOON (set by the implemented Mt Moon script) and VAR_WEEKDAY (real in the port; World:readVar VAR_WEEKDAY at World.lua:1289): the cache carries INDIGO_PLATEAU_POKECENTER_1F's NEWMAP callback 5a:48b6 (23 rows of setmapscene/clearevent resets) plus its two coord events, and DRAGONS_DEN_B1F's callback 47:44e1 (checkevent 793 -> disappear object 4). The daily rematch flag ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT (id 92) is in Apricorns.DAILY_ENGINE_FLAGS so it clears on the daily rollover. The rematch parties RIVAL2 members 4-6 (L45-50 with CROBAT) are in trainers.lua. Nothing looks missing, but the coord-event choreography in the Pokecenter (rival walks in as you leave) is the kind of scene worth a driver before trusting; filed unverified rather than implemented for that reason.

*How to prove it:* Driver: set EVENT_BEAT_RIVAL_IN_MT_MOON via the Mt Moon fight, force weekday Monday/Wednesday, enter the Indigo lobby and assert the rematch triggers; force Tuesday/Thursday and assert the Dragon's Den object 4 state.

*Notes:* Doc rating: unverified/minor, new. Merge-with hint: overlaps indigo-lobby-rival-rematch (s18), the same Indigo Plateau rematch filed from the section-18 audit; that filing cites World:weekday at World.lua:1247 and scriptKeys 5a:48ff/5a:4940.


### Indigo lobby rival rematch (Monday/Wednesday, RIVAL2, post Mt. Moon) armed on tiles the walkthrough crosses, never run

walkthrough section(s) 18 | unverified

Not in the walkthrough text but armed on the lobby tiles it crosses: coord events at (16,4)/(17,4) run PlateauRivalBattle1/2 (cache scriptKeys 5a:48ff/5a:4940), which fight the RIVAL2 second-tier party when EVENT_BEAT_RIVAL_IN_MT_MOON is set, ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT is clear, and VAR_WEEKDAY is Monday or Wednesday (pokegold maps/IndigoPlateauPokecenter1F.asm). Every dependency exists: coord events and scripts extracted, VAR_WEEKDAY answers the real weekday (World:weekday, World.lua:1247), the daily engine flag is registered for midnight reset (Apricorns.lua:88, id 92 ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT), and RIVAL2 parties 4-6 (SNEASEL/45, CROBAT/48, MAGNETON/45, GENGAR/46, ALAKAZAM/46, starter/50) are in the trainers cache. But the gate flag EVENT_BEAT_RIVAL_IN_MT_MOON is Kanto content no run has ever set.

*How to prove it:* Should be picked up when section 26 is audited/run: same driver as rival-rematch-mtmoon, entering the lobby on Monday/Wednesday with the Mt Moon flag set and asserting the coord-event battle fires.

*Notes:* Doc rating: unverified/minor, new. Merge-with hint: same beat as rival-rematch-mtmoon (s26); kept separate because the doc filed both headings. Line-cite difference between filings: World.lua:1247 (weekday) here vs World.lua:1289 (readVar VAR_WEEKDAY) there.


### Lighthouse descent and swim to Cianwood (route rows 08.50/08.51) never walked; collision data matches the cart, blame points at the bot's region graph

walkthrough section(s) 08 | unverified

The route bot has never completed the descent from Jasmine to Route 40, so the Surf crossing, all fourteen Route 40/41 swimmers, and Cianwood arrival are engine-unwalked (runs reach section 08+ by teleport; run 28 still failed rows 08.50/08.51). The handoff narrows it to the 3F seven-cell pocket: warps 8/9 at (8,3)/(9,3) 'do not take' when stood on. Verified in the current cache: OLIVINE_LIGHTHOUSE_3F (8,3)/(9,3) decode to COLL_FLOOR 0x00, and pokegold data/tilesets/lighthouse_collision.asm block $27 is FLOOR,FLOOR,FLOOR,FLOOR, so those two warp rows are one-way landing anchors for the 4F pits at (8,3)/(9,3) (which decode to COLL_PIT 0x60) and never fire on the cart either. The pocket's real exit is warp 3, the staircase at (9,5), which decodes to 0x72 and does fire ((13,3) also 0x72). Fix shape: correct the bot's region graph, which treats landing-anchor warp coordinates as exits (the exact trap GOLD-WALK-HANDOFF.md:593 documents), not the engine; a human following the walkthrough (drop beside Connie, fight Terrell, take the Ether, head up the stairs) uses the (9,5) staircase and should be fine.

*How to prove it:* Something must walk 6F down to CIANWOOD_CITY in the engine (bot rows 08.50/08.51 passing, or a driver doing the descent and the Route 40/41 Surf crossing); until then the second half of section 08 stays a beat-completeness check rather than a proven path.

*Notes:* Doc rating: unverified/major, already named in the ledger. The doc's own re-check corrected the suspicion of an engine defect: the cache collision matches the cart exactly, so the failing rows indict the bot's region graph, not the engine or the warp data.


### TM08 Rock Smash give (route row 06.21) flaky across runs; ledger contradicts itself and the failure is unresolved

walkthrough section(s) 06 | unverified

The Route 36 fisher gives TM08 after EVENT_FOUGHT_SUDOWOODO (Route36RockSmashGuyScript, generic extracted bytecode with verbosegiveitem guarded by iffalse .NoRoomForTM). The ledger contradicts itself across runs: GOLD-WALK-HANDOFF section 8 says 'Everything before it now passes on merit: Sudowoodo, TM08, the ROCK SMASH teach', but run 28's failure table lists '06.21 ROUTE_36 EVENT_GOT_TM08_ROCK_SMASH not set' while the Sudowoodo row itself passed. Plausible causes: full TM pocket taking the iffalse arm, or the bot failing to stand adjacent. The script path is generic and the same give shape works everywhere else, so this is most likely route flake, but it is unresolved in the latest continuous run and TM08 gates all Rock Smash content downstream (Burned Tower rocks, Route 40/Cianwood rock items).

*How to prove it:* Re-run route row 06.21 in a continuous run and assert EVENT_GOT_TM08_ROCK_SMASH gets set; instrument for TM-pocket fullness and adjacency to distinguish the two suspected causes.

*Notes:* Doc rating: unverified/minor, already named in the ledger. Not given severity unverified-risk because the problem is a reproduced-once run failure (a live flake), not purely never-executed content.


### New Bark rival push scene (talk to rival by the lab) unproven; low risk, zero coverage

walkthrough section(s) 00 | unverified

Walkthrough: 'If you talk to him, he'll push you out of the way.' NewBarkTownRivalScript is optional, repeatable (sets no flag) and uses follow PLAYER, applymovement with turn_head/step/fix_facing/jump_step, and SFX_TACKLE. Every opcode involved is implemented (follow/stopfollow in the VM, jump_step in Movement.lua which the ledge fixes exercised), and the sibling teacher-drag scene has a dedicated driver (tests/drivers/gold_teacher_scene.lua), but no driver or test touches this specific scene and the route bot never talks to optional NPCs. Cache maps.lua NEW_BARK_TOWN objects include the rival with a scriptKey and eventFlag.

*How to prove it:* A short driver that talks to the rival by the lab and observes the push movement chain, mirroring gold_teacher_scene.lua.

*Notes:* Doc rating: unverified/minor, new.


### Kiyo battle and Tyrogue gift (Mount Mortar B1F): fully wired, never exercised by any driver or bot run

walkthrough section(s) 15 | unverified

The game's only Tyrogue. Cache scripts['46:5eec'] holds all 29 rows of MountMortarB1FKiyoScript (checkevent 97 / 1193, winlosstext, loadtrainer class BLACKBELT_T member 6, startbattle, reloadmapafterbattle, setevent 1193, readvar var=1 VAR_PARTYCOUNT, ifequal 6, givepoke species 236 level 10, setevent 97); trainers cache has BLACKBELT_T[6] KIYO = L34 HITMONLEE + L34 HITMONCHAN (KIYO object at 13,4 with scriptKey 46:5eec); readvar VAR_PARTYCOUNT is a real read (World.lua:1271); givepoke is implemented at Vm.lua:443. The full dependency chain has never run: Surf across the 1F Outside lake, the in-cave Waterfall climb to warp 4 at (17,5), the 2F/1F-inside/B1F warp descent, the battle, and the gift. The waterfall climb mechanic itself is bot-verified only at Tohjo Falls; route.lua contains no MORTAR/KIYO/DARK_CAVE rows.

*How to prove it:* A Mount Mortar driver: Surf the outside lake, Waterfall to warp 4 (17,5), descend to B1F, beat Kiyo, assert Tyrogue (species 236, L10) given with a party of <6 and events 97/1193 set.

*Notes:* Doc rating: unverified/major, new. Correction embedded: GOLD-INDEX's claim that only VAR_WEEKDAY and VAR_FACING answer readvar is STALE; World.lua:1265-1330 now answers essentially every VAR_*.


### Blackglasses pharmacist in Dark Cave Blackthorn entrance extracted exactly, never run (same for TM13 Snore and Revive balls)

walkthrough section(s) 15 | unverified

The script is fully extracted (cache scripts['47:436c'], 13 rows matching pokegold maps/DarkCaveBlackthornEntrance.asm exactly: checkevent / verbosegiveitem / iffalse pack-full arm / setevent), the spinning NPC object (SPRITE_PHARMACIST) is in the cache at (7,3) with that scriptKey, and verbosegiveitem is implemented in the VM. Reaching him also needs Flash plus Surf inside the cave, both implemented. The same unverified state covers the TM13 Snore and Revive item balls beside him (item ball arm is implemented and tested). No driver enters Dark Cave and the bot route bypasses it (grep DARK_CAVE in route.lua is empty).

*How to prove it:* A Dark Cave driver: Flash + Surf to the Blackthorn entrance, talk to the pharmacist (assert Blackglasses given), pick up TM13 Snore and the Revives.

*Notes:* Doc rating: unverified/minor, new.


### Master Ball from Elm after eighth badge: route rows exist but optional, no run log confirms the event ever set

walkthrough section(s) 16 | unverified

ProfElmScript's ElmCheckMasterBall gate is checkflag ENGINE_RISINGBADGE then verbosegiveitem MASTER_BALL then setevent EVENT_GOT_MASTER_BALL_FROM_ELM (pokegold maps/ElmsLab.asm:57-61). All generic extracted bytecode; checkflag over ENGINE_* badges works since the badge-store fix (GOLD-WALK-HANDOFF.md:502, badges routed into save.player.badges). The route bot has rows 16.24/16.24b for this beat but both are marked optional = true, and no run log or handoff note confirms EVENT_GOT_MASTER_BALL_FROM_ELM was ever actually set in a live run (no MASTER hits in GOLD-NEXT-RUN.md run logs). A full bag silently skips the setevent (verbosegiveitem iffalse), same as the cart.

*How to prove it:* Make route rows 16.24/16.24b non-optional (or run them) and assert EVENT_GOT_MASTER_BALL_FROM_ELM set with bag space available.

*Notes:* Doc rating: unverified/major, new.


### Everstone from Elm by showing a self-hatched Togepi: pieces individually proven, full chain never exercised end to end

walkthrough section(s) 16 | unverified

The gating special FindPartyMonThatSpeciesYourTrainerID is a real handler with the own-OT check (Specials.lua:1134), and the phone-call prerequisite is NOT required: pokegold maps/ElmsLab.asm ElmCheckTogepiEgg -> EVENT_TOGEPI_HATCHED -> ElmEggHatchedScript re-runs the same species scan, so a hatched Togepi in the party is sufficient (maps/ElmsLab.asm:62-95, engine/phone/scripts/elm.asm:46). Egg hatching has a driver (tests/drivers/gold_egg_hatch.lua) and PC withdraw exists (BoxMenu.lua / PcMenu.lua). The full chain (hatch with your OT, withdraw, talk, EVENT_SHOWED_TOGEPI_TO_ELM, verbosegiveitem EVERSTONE) has never run end to end. The .egghatched arm of ElmPhoneCalleeScript (sets EVENT_TOLD_ELM_ABOUT_TOGEPI_OVER_THE_PHONE) lives in the bank $41 callee scripts and only matters for the alternate entry path. No route row exists for the Everstone.

*How to prove it:* A driver chaining gold_egg_hatch-style hatching (own OT), PC withdraw, and the Elm talk, asserting EVENT_SHOWED_TOGEPI_TO_ELM and EVERSTONE in bag.

*Notes:* Doc rating: unverified/minor, new.


### TM37 Sandstorm happiness gate at the Route 27 house never exercised; gate is first-slot happiness >= 150

walkthrough section(s) 16 | unverified

The granny's script is extracted (cache scripts['60:6352'], 9 rows: checkevent, special id 88, ifgreater, sjump into the loyal/disloyal arms) and special id 88 resolves through constants.specialOrder with the VM's order[id+1] rule (Vm.lua:1773) to specialOrder[89] = GetFirstPokemonHappiness, a real handler at Specials.lua:1506 reading the first non-egg party member. The cart gate is happiness >= 150 on the FIRST party slot (ifgreater 150-1), not 'one of your Pokemon'. Happiness accrues via Happiness.lua stepped from StepEvents. No driver or bot row enters ROUTE_27_SANDSTORM_HOUSE.

*How to prove it:* Driver: enter ROUTE_27_SANDSTORM_HOUSE with a first-slot mon at happiness >= 150 and assert TM37 given; also assert the disloyal arm below 150.

*Notes:* Doc rating: unverified/minor, new.


### Route 27 whirlpool island (Bird Keeper Jose, TM22 Solarbeam, Rare Candy) and Tohjo Falls Moon Stone never run; whirlpool mechanic only proven on Route 41

walkthrough section(s) 16 | unverified

The whirlpool mechanic is implemented and driver-verified, but on Route 41, not here: tests/drivers/gold_water_moves.lua:105-124 clears a real whirlpool block with GLACIERBADGE gating and asserts the block replacement. The Route 27 island content is all in the cache (TM_SOLARBEAM ball at (60,12) item id 213 with event flag, Rare Candy ball at (53,12), BIRD_KEEPER[14] JOSE = L35 FARFETCH_D with phone contact rows; maps.ROUTE_27 objects rows 6-8) and the item ball arm is implemented, but the bot route crosses Route 27 only via Tohjo Falls and never surfs south past Gilbert (route rows 16.42-16.43 skip the south water), so this specific whirlpool, the Jose fight, and the TM22 pickup have never run. Same for the Tohjo Falls MOON_STONE ball at (2,6) (maps.TOHJO_FALLS object 1), which the walkthrough itself never mentions.

*How to prove it:* Driver or route rows: surf south past Gilbert, clear the Route 27 whirlpool, fight Jose, collect TM22 and the Rare Candy; separately pick up the Tohjo Falls Moon Stone.

*Notes:* Doc rating: unverified/minor, new.


### Route 26 heal house free heal extracted with all specials real, never entered

walkthrough section(s) 16 | unverified

The teacher's script is extracted (cache scripts['60:60e6'], 17 rows) and every special id in it resolves via order[id+1] to a real handler: 47 FadeOutToBlack, 50 ReloadSpritesNoPalettes, 27 HealParty, 49 FadeInFromBlack, 60 RestartMapMusic (Specials.lua:450, :999, :1025, and the fade-in/restart pair at :1059). Unconditional and repeatable like the cart. No driver or bot row ever enters ROUTE_26_HEAL_HOUSE; the bot route's Route 26 leg is a single travel row straight to the gate.

*How to prove it:* Driver: enter ROUTE_26_HEAL_HOUSE with a damaged party, talk, assert full heal and that the scene is repeatable.

*Notes:* Doc rating: unverified/minor, new.


### Victory Road item pickups (TM26 Earthquake pit, Full Restore shelf, Max Revive, Full Heal, X Special, two hidden items) never exercised

walkthrough section(s) 17 | unverified

The walkthrough collects five Poke Ball items (TM26 Earthquake via the one-way pit at (0,11), Full Restore on the ledge shelf via the (17,19) ladder, Max Revive and Full Heal in the entrance region, X Special on the HOP_LEFT column) plus two hidden items (Max Potion at (3,29), Full Heal at (3,65)). All pieces exist: cache maps.VICTORY_ROAD carries 6 objects (5 with itemball item/qty payloads), 2 bgEvents with hiddenItem tables, 10 warps, 2 coord events; World:interact consumes obj.itemball (World.lua:5483-5490, an earlier bot-found fix); HiddenItems handles BGEVENT_ITEM; Permissions models the COLL_PIT one-way warp, the six ladders, ledge hops (isLedge/ledgeFacings, Gold's own direction order where $a0 is HOP_RIGHT), and COLL_UP_WALL side walls (Permissions.lua:170-260 LEDGE_FACINGS/SIDE_BLOCKS/NEIGHBOR_ARM), with a test section at tests/gen2_world_test.lua:2936. But nothing has walked these routes: the bot's section 17 is only travel/walk rows 17.2, 17.11, 17.15 (no pickup rows), so the pit drop, the two HOP exits from the TM pocket, the HOP_DOWN off the shelf, and the X Special ball sitting ON a HOP_LEFT tile (the one placement the asm-walk flags as needing hardware confirmation) are all unproven end to end.

*How to prove it:* Driver or route rows through Victory Road collecting all five balls and both hidden items, specifically exercising the (0,11) pit drop, the (17,19) ladder shelf with HOP_DOWN exit, the two HOP exits from the TM pocket, and interaction with the X Special ball on its HOP_LEFT tile.

*Notes:* Doc rating: unverified/minor, new.

