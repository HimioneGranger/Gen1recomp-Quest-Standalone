# Quest Pokedex and Performance Investigation

Branch: `quest-pokedex-perf-investigation`

Base checkpoint: `1fb3e9e` on `dramaless-1.6.4-integration`. That commit restores
the last playable APK after rejecting the ineffective 250% battle source crop.
The base branch is intentionally left unchanged while the work below is tested.

## Reconstructed Pokedex history

The local project still contains the Quest-adapted Dramatic Shape 1.8.2 source
and package backups:

- `E:/Gen1QuestVR/DramaticShapeVoxelMod/lib/VR.lua`
- `E:/Gen1QuestVR/.quest-package-native/lib/VR.lua`
- `E:/Gen1QuestVR/dist/DRAMATIC_SHAPE-1.8.2-Quest-Local-dev.zip`

The apparent Dramatic-versus-Dramaless difference was not a better independent
battle camera. Both conductors used the same mechanism: during `VR.update`, copy
the window framebuffer rectangle into a canvas and texture the Pokedex with it.
Dramatic Shape assumed `BattleScene.GB_W` x `BattleScene.GB_H` (160x144).

Two later changes invalidate that assumption:

1. Current Gen1Recomp can expose a 304x144 wide-battle UI surface.
2. Kanto First Person stages its battle across the wide rendered view.

There is also a timing defect common to the old path. Dramaless calls
`VR.update` from its game-update hook, before `love.draw` calls `Game:draw`.
Consequently, Android's completed framebuffer at that point is the previously
presented OpenXR left eye, not the current flat game composition. This explains
all of the otherwise contradictory headset evidence:

- Direct `Renderer.canvas` capture was black because it was sampled outside the
  final palette/composition seam.
- Full-left-eye and widened-region experiments remained camera views rather
  than a clean game UI.
- Increasing the battle crop from 150% to 250% changed the logged source from
  2400px to 3600px but did not reveal a genuinely wider camera.
- The 250% build made transition/load presentation worse because it copied far
  more of the 4128x2208 eye framebuffer every lit frame.

The 2026-08-10 failure log measured the rejected build at 129.04ms average and
891.34ms worst while the Pokedex/UI capture was active, versus roughly 30-34ms
once settled. Its capture rectangle was 3600x2160. This experiment was reverted
in `1fb3e9e`.

## Investigation implementation

The branch introduces a narrow, Quest-optional post-draw seam:

- `main.lua` invokes `_G.QUEST_POKEDEX_CAPTURE`, when present, immediately after
  `Game:draw` has completed the flat composition.
- The Dramaless Quest conductor owns that callback only while VR is enabled.
- The callback captures the engine's exact active UI rectangle into a small
  2x-resolution source canvas. It no longer widens an eye-buffer crop.
- Classic 160x144 menus/dialog use that source directly.
- A 304x144 wide battle is aspect-fitted into the existing 320x288 physical
  screen texture. Both combatants and all UI are retained. The unavoidable
  unused area is dark bezel; cropping or stretching are the only alternatives
  on a fixed 10:9 screen.
- The physical model, controller placement, stereo cameras, exploration view,
  save/ROM workflow, and desktop path are unchanged.

This is an experimental build until headset screenshots verify orientation,
freshness, colors, and wide-battle readability. It must not be merged into the
playable base solely because it compiles.

## Performance conclusions so far

Measured current exploration is approximately 30-34ms/frame with 500-600 draw
calls, 136MB texture memory, and every sample missing the 72Hz 13.89ms budget.
UI/battle states have reached 206MB and 16 canvas switches. No single cosmetic
Lua toggle can close a greater-than-2x GPU deficit by itself.

The safest optimization order is therefore:

1. Remove the accidental full-eye Pokedex copy and retain only the small
   post-draw UI capture (this branch).
2. Measure Pokedex-off versus classic-UI versus wide-battle capture with the
   existing PERF10 sampler.
3. Profile Kanto First Person feature groups independently on the same saved
   route. Forest FX is already rejected by headset testing.
4. Reduce repeated per-eye work and draw calls before shortening the visible
   map. The user has explicitly preferred the longer view distance.
5. Preserve the last playable APK and make every visual/performance experiment
   independently revertible.

### Indexed Dramaless candidate

Static inspection confirmed that Dramaless 1.6.4 did **not** inherit the
indexed terrain sink previously validated in Dramatic Shape. Its Android FFI
path still emits six complete vertices per quad. The earlier full-view Quest
trial demonstrated that four vertices plus six indices reduced Route 2 terrain
vertices from 3,820,770 to 2,547,180 and Viridian Forest from 3,750,006 to
2,500,004, while preserving the visible connected maps. Directional extended-
run memory fell by roughly 200MB, although the traversed cache sets differed.

Branch `quest-perf-indexed-dramaless` contains a fresh, source-guarded adapter
for the Dramaless 1.6.4 FFI sink. It:

- Leaves the table/headless geometry path unchanged.
- Stores four unique vertices and the normal 0,1,2,0,2,3 uint32 indices.
- Retains sliced vertex uploads and their cooperative budget checks.
- Refuses changed/ambiguous source and preserves any foreign implementation
  that already uses `setVertexMap`.
- Changes neither visibility nor render resolution.

The adapter was tested against the exact local Dramaless 1.6.4 source: every
anchor matched exactly once and the transformed Lua parsed successfully. This
candidate is intentionally not considered headset-validated until it rebuilds
the active maps without corruption and PERF10/memory logs are collected on the
same route.

Kanto First Person static complexity supports profiling it separately rather
than guessing: `payload_flora.lua` alone is about 4,681 lines with 36 explicit
draw sites, 17 mesh-construction sites and 260 loops; ceiling, sky and backdrop
are much smaller. Forest canopy was already disabled by the user. Flora's
world-apron, tall-tree/mountain, grass and particle groups remain the best
feature-level ablation targets after indexed terrain, but none is force-disabled
by this branch.

Compile-only artifact (not installed automatically):

`E:/Gen1QuestVR/dist/Gen1Recomp-Quest-PokedexPostDraw-IndexedDramaless-candidate.apk`

SHA-256: `FA419141714CADBB187E9CB111EB32FD6120E37651B1392834C5523401381916`

The Quest was left on the earlier `86e2c2d` post-draw-Pokedex-only APK while
unattended. The indexed candidate was deliberately preserved but not installed,
because first launch rewrites the writable Dramaless mesher shadow and requires
an awake-controller/headset test to verify map rebuilds.

Installed safe visual-test artifact:

`E:/Gen1QuestVR/dist/Gen1Recomp-Quest-PokedexPostDraw-safe-test.apk`

SHA-256: `41D0F7D837EEEFA0665DBE1A712366CC60AFE189BEF7823D8915FCE2A8F0270C`

Build-process correction: Gradle's current installable artifact is under
`app/build/outputs/apk/...`; an older 34MB file remained under
`app/build/intermediates/apk/...`. Several late-night install/copy commands
initially referenced that stale intermediate. Both named artifacts above were
subsequently rebuilt, opened, and verified from the 55.9MB `outputs` APK. The
safe post-draw-only APK was then installed successfully; the indexed candidate
was not installed.

## 2026-08-10 headset follow-up

Post-draw timing alone did not remove Android's narrow unused column from the
classic menu/dialog source, and battle remained a near-square crop of the
widescreen eye mirror. Restored the conservative 3.5% left-only UV correction
for classic non-battle UI. It does not move or resize the physical device and
does not discard battle width.

Battle zoom is a separate aspect-ratio constraint: a 10:9 physical screen
cannot show the complete roughly 1.87:1 eye mirror without letterboxing,
distortion, a wider physical screen, or an additional battle-camera render.
Larger source crops already failed and worsened load cost. The indexed full-view
performance test therefore proceeds without adding another full-resolution
battle copy; camera/presentation alternatives remain isolated follow-up work.

Headset validation remains required for visual decisions. The computer can
compile, inspect sources, compare logs, and reject structural errors unattended,
but it cannot infer perceived stereo alignment or readability from desktop
mirror output alone.

## Deferred: Wilds of Kanto Quest performance fork

The current `YoDrehDenSwagAuf/overworld-spawn-mod` repository is MIT-licensed
for its original source and original project assets, so a clearly attributed
Quest optimization fork is permitted while retaining the copyright and license
notice. Its third-party sprite and game-adjacent assets are explicitly outside
that MIT grant and must remain governed by their own notices; questionable
assets should be excluded from a distributable fork or imported separately.

This is deliberately deferred until the current Dramaless terrain candidate and
Pokedex presentation are stable. When resumed, investigate distance-based spawn
caps, reduced off-screen AI/pathfinding frequency, animation throttling, object
pooling, and Performance/Balanced/Full presets using the Quest PERF10 route.
Keep this work in a separate fork/branch and do not bundle it into the core APK
until independently profiled and validated.

## 2026-08-10 combined-candidate headset route

The user recorded a 371-second run covering launcher/startup, Pallet/Route 1,
Viridian, interiors, battle UI, forest scenery, settings, and additional extreme
voxel viewing angles. Sampled frames show no missing, scrambled, or corrupt
terrain, providing the first visual headset validation of the indexed Dramaless
geometry candidate across multiple scene types and a map transition.

Only the final two PERF10 windows remained in logcat:

- 18.28 ms average, 16.77 ms p50, 26.48 ms p95, 41.64 ms p99, 55.86 ms worst;
  352 draws, 257.1 MB textures.
- 19.10 ms average, 17.17 ms p50, 25.59 ms p95, 42.54 ms p99, 57.05 ms worst;
  372 draws, 257.1 MB textures.

Every sampled frame missed the 13.89 ms 72 Hz budget. This is approximately
52-55 application frames per second by average interval, with long-tail spikes
above 40 ms. Indexed terrain is therefore visually safe in this run but is not
sufficient on its own. The next performance pass should target draw-call-heavy
Kanto First Person flora/horizon groups while retaining connected-map scenery,
and should persist the complete PERF10 stream before the next route.
