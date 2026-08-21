# Quest Launcher 8 to Unplugged parity ledger

## Result

The clean Unplugged baseline at `c4f06e96` contains the launcher-owned Quest
presentation and settings behavior. The rebuilt Diagnostic APK contains the
same source files byte for byte. Live evidence later proved that the installed
APK also matches that artifact. The remaining defect was product-profile
activation: it depended on the optional OpenXR panel FFI backend succeeding.
The Quest Android flavor now selects the profile directly through SDL manifest
environment metadata. Generic Android remains unchanged.

The isolated app-repair candidate at `1c8ba5cd` adds a bounded Quest-only
launcher handoff with six animated lightning states, makes Gen 1 title states
use the same Quest paper surround as the opening states, and hides the inactive
T-shift and V Curved mod rows at all launcher and in-game schema consumers.
These filters do not change saved values.

The world spawn correction, companion placement, and physical Pokédex are not
launcher features. They are DRAMALESS Q42 features. They must stay in the mod.

## Evidence

- Clean baseline: `c4f06e96`.
- Isolated audit branch: `codex/launcher8-deep-parity-20260820`.
- Preserved installed payload:
  `Gen1recomp-Quest-Standalone/artifacts-installed-original.apk`.
  Its `game.love` SHA-256 is
  `9D22E08F13DB418E091A6E4952301F3C9EAE57700BB58D869FC6F81550F88899`.
- Rebuilt clean Diagnostic payload:
  `Gen1recomp-Unplugged-Baseline-Integration/dist/android/debug/diagnostic/`
  `gen1recomp-unplugged-diagnostic-app-questVr-noRecord-debug.apk`.
  Its `game.love` SHA-256 is
  `9B6C84F6D0176825EA7303DD20BE864E7A3F56E4C528B2C20C1F6E2FC6FEBF7A`.
- The rebuilt APK copies of `Renderer.lua`, `TouchControls.lua`,
  `LauncherSettings.lua`, and `SaveData.lua` match baseline source SHA-256
  values exactly.
- DRAMALESS evidence: `Gen1Recomp-Mods/DRAMALESS_q42.zip`, manifest version
  `2.0.0-quest.42-pokedex-render-stability-test`.
- Headset evidence: the user reports black ROM-loading side bars, the wrong
  spawn facing, a companion overlap, and no physical Pokédex in the currently
  running Diagnostic session.

## Launcher-owned behavior

| Behavior | Historical or accepted source | Clean source | Rebuilt APK | State |
|---|---|---|---|---|
| Normal, Test, and Diagnostic identities | Accepted Unplugged build flow | Present | Present | Found |
| Quest product-profile activation | Quest flavor identity | `SDL_ENV.POKEPORT_QUEST_PROFILE=1`; independent of panel FFI | Flavor manifest | Fixed in this branch |
| White or palette-paper surround for all opening states | Accepted Quest presentation rule | Present in Gen 1 and Gen 2 opening states and `Renderer.lua` | Exact source match | Found; activation fixed |
| No Android phone touch overlay in Quest | Accepted Quest rule | `TouchControls` returns inactive for Quest | Exact source match | Found |
| Hide Video Mode | Quest has no desktop window mode | Hidden in launcher and game menus | Exact source match | Found |
| Hide Orientation | Quest owns immersive orientation | Hidden in launcher and game menus | Exact source match | Found |
| Hide Touch Pad | Quest uses tracked controllers | Hidden in launcher and game menus | Exact source match | Found |
| Hide Vibration | This row controls phone overlay haptics | Hidden in launcher and game menus | Exact source match | Found |
| Keep supported graphics and game controls | Launcher 8 feature set | Present; exact list below | Exact source match | Found |
| Advanced color default | New user-approved Unplugged default | `redpp`, label `ADVANCED` | Exact source match | New approved |
| Lower shared room panel | Accepted headset panel test | Shared offset `-0.19375 m` | Native source build | New approved |
| Import and lifecycle recovery | Accepted Unplugged repairs | Present in baseline commits | Built in all variants | Found; device proof pending |
| Do not stop spawn for a mod-set-only report | Launcher 8 headset flow; 2026-08-20 capture exposed the regression | Quest suppresses only the informational mod-diff page; recovery and quarantine reports remain | Focused policy test | Repaired |
| Visible animated Quest launch progress | Capture part 1 has no app progress frame between Play and opening | Quest-only 0.75-second launcher-compositor handoff; six bolt states at 12 Hz | Four or more distinct sampled states; packaged source exact | Repaired; headset proof pending |
| Gen 1 title paper surround | Accepted Quest presentation rule | `TitleState` selects Quest paper letterbox fill | Red, Blue, and Yellow title route static/fixture test | Repaired; headset proof pending |
| Hide inactive T-shift and V Curved rows | Q42 handoff: these flat-pipeline rows do not affect the Quest compositor | Filtered in launcher, both game option menus, and mod manager | Focused profile and source-consumer tests | Repaired; saved choices preserved |

### Supported launcher rows retained on Quest

Text Speed, Battle Animation, Battle Style, Battle Layout, Battle Size,
Battle Background, UI Layout, Music Volume, SFX Volume, Music Filter,
Performance, Colors, Tilt, Void Fill, Faithful Ratio, Maximum FPS, Overworld
Speed, Battle Speed, Menu Speed, and Reset Rebinds.

### Supported in-game rows retained on Quest

The launcher rows remain available where applicable. The in-game menu also
keeps Ruleset, Zoom, Mods, Controls, Date Format, and Time Format.

### Core defaults

| Setting | Default |
|---|---|
| Text speed | Medium (`3`) |
| Battle animation | On |
| Battle style | Shift |
| Battle layout | Original |
| Battle size | Fixed |
| Battle background | White or palette paper |
| UI layout | Centered |
| Ruleset | Gen 1 faithful |
| Music, SFX, Pikachu volume | `7` |
| Performance | Auto |
| Colors | Advanced (`redpp`) |
| Tilt, zoom, GBC FX | Off (`0`) |
| Void fill | Trees |
| Faithful ratio | Off (`0`) |
| Maximum FPS | `60` |
| Overworld, battle, menu speed | `1x` |

The portable core still stores phone and desktop defaults for cross-platform
compatibility. Quest hides or disables the unsupported controls at runtime.
Existing player settings are preserved. Missing values receive defaults.

## DRAMALESS-owned behavior

| Behavior | Q42 evidence | State |
|---|---|---|
| Turn the initial first-person view by 180 degrees | `FirstPerson.takeQuestSpawnYawOffset()` returns `math.pi`; `VR.lua` consumes it once | Present in Q42; activation and headset proof pending |
| Place Yellow Pikachu beside the player | `placeQuestSpawnPartner()` moves an overlapping follower to the player's right | Present in Q42; activation and headset proof pending |
| Physical chest Pokédex | `Pokedex.lua` and `VR.lua` own the chest pose, either-hand grab, hand transfer, trigger open/close, menu input, throw, ground contact, and rear camera | Present in Q42; headset proof pending |
| DRAMALESS Quest defaults | `QuestDefaults.lua` seeds absent values only | Present in Q42; fresh-profile proof pending |
| Intro/game-surface black columns inside the white room panel | 2026-08-20 capture proves the outer Quest surround is white while the columns remain inside Q42's cropped quad | DRAMALESS `VR.lua` owns the game-surface crop and geometry | Missing; route to Q42 repair |

Q42 defaults are: grid off, curve off, real-time day/night sync, full water,
high shadows, anti-aliasing off, full render scale, Far render distance,
Smooth Turn on, 90 Hz, silhouettes on, invert Y off, battle background off,
and 2D battle cards on. Its VR compatibility value remains internal.

## Excluded behavior

- Do not copy the old monolithic `src/quest/dramaless` implementation into
  the portable core. Q42 is the current owner.
- Do not expose phone VR, anti-aliasing, Video Mode, Orientation, Touch Pad,
  or phone Vibration rows on Quest.
- Do not overwrite an existing player's saved choices to force defaults.
- Do not treat the black-bar headset report as proof of a source regression.
  The 2026-08-20 video proves the Quest profile is active because its outer
  surround is white. The remaining black columns are inside DRAMALESS's
  cropped game quad, not the launcher surround.
- Do not make the app select Stationary or Roomscale. The Quest host creates
  only OpenXR LOCAL and VIEW spaces and calls no Guardian boundary API. The
  captured log records the Quest OS changing `Roomscale -> Stationary` after
  an explicit `createNewActiveStationary` action; it records no app-triggered
  `Stationary -> Roomscale` transition.

## Open acceptance gates

1. Run the candidate on a headset and confirm that several lightning states
   are visible after Play and before the opening route.
2. Run fresh Red, Blue, Yellow, and Gold openings and titles at wide and narrow
   aspect ratios. Confirm a white or palette-paper outer surround and no phone
   touch controls.
3. Import and activate Q42. Confirm its manifest version in the mod list.
4. Confirm the 180-degree spawn correction, companion placement, and Pokédex.
5. If a failure remains, collect the exact Diagnostic log and package/payload
   identity from that run before another source change.

No device action was done during this audit.
