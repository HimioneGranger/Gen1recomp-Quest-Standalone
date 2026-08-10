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

Headset validation remains required for visual decisions. The computer can
compile, inspect sources, compare logs, and reject structural errors unattended,
but it cannot infer perceived stereo alignment or readability from desktop
mirror output alone.
