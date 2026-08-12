# 1GenPokemonVR comparison and clean-room adoption audit

Audit date: 2026-08-12  
Audited repository: <https://github.com/heurazy/1GenPokemonVr>  
Audited revision: `9a90448` (`v0.2.46`)  
Our comparison branch: `quest-gen2-beta-v0.1.79`

## Executive decision

Do **not** copy source from 1GenPokemonVR into this project at this time.
The repository has no root license granting rights to its original OpenXR,
VR input, spatial UI, battle-layer, or Quest optimization additions. Its own
`THIRD_PARTY_NOTICES.md` also says redistribution of the inherited Gen1Recomp
and Dramatic Shape sources requires permission. Public source availability is
not a permission grant.

We may study observable behavior and general architecture, then implement the
useful ideas independently against our newer Dramaless/v0.1.79 base. Keep no
copied functions, constants, comments, shaders, or assets. If the author later
adds a suitable license or gives written permission, reassess file-by-file.

This is a source/licensing engineering assessment, not legal advice.

## Fork and credit answer

- A GitHub fork label is a hosting relationship, not the core legal issue.
- There is currently no license allowing us to copy the author's additions,
  whether or not our repository is presented as a fork.
- If permission is later granted under MIT or another attribution license, its
  notice and attribution requirements must be kept. We cannot promise a
  no-credit code import.
- Independently implementing standard OpenXR concepts does not make our project
  a fork of 1GenPokemonVR, but provenance notes for research are still prudent.

## Checked implementation

The following are present in checked source, not merely README claims:

- `native/openxr_bridge/gen1openxr.cpp`: two-eye OpenXR swapchains, controller
  action profiles, controller aim ray, quad layers, display-refresh extension,
  Android/EGL and Windows/OpenGL paths, session recovery and frame submission.
- `src/vr/OpenXR.lua`: LuaJIT FFI facade, per-eye pose/FOV exchange, render
  scale, refresh selection, input polling, spatial UI and battle-layer calls.
- `src/vr/Pointer.lua`: ray/menu arbitration, click debouncing and pointer
  handoff between stick navigation and controller aim.
- `src/ui/VROptionsMenu.lua` and `src/ui/VRScrollbar.lua`: headset-facing
  quality/camera/comfort controls and draggable long-list interaction.
- Bundled Dramatic Shape changes: first-person stereo rendering, tracked
  handheld display, chunk/distance/direction culling and battle integration.
- Android product flavor and Quest manifest, native ARM64 bridge build, Storage
  Access Framework import polling, atomic picker copies and release workflow.
- Release tests cover OpenXR facade behavior, packaging and several menu/input
  regressions; the release notes report 64 Windows suites.

The audited tree supports Red and Blue. It does not contain our Gold manifest,
Gen-2 runtime trees, Gold importer, or current unified Gen-2 mod API.

## Capability comparison

| Area | 1GenPokemonVR v0.2.46 | Our current Quest branch | Assessment |
|---|---|---|---|
| Upstream game base | Red/Blue-era tree; no Gold runtime found | v0.1.79 beta base with Yellow and stock Gold Quest validation | **Ours** |
| Voxel base | Bundled Dramatic Shape 1.5.4 | Newer, authorized Dramaless Quest fork plus Kanto First Person integration | **Ours** |
| Standalone OpenXR | Native ARM64, per-eye swapchains and 6DoF | Native ARM64, per-eye Quest path tested repeatedly on hardware | Both |
| PCVR | Explicit SteamVR/OpenXR bridge and several controller profiles | Quest-first; PCVR back-port remains planned | **Theirs** |
| Menu interaction | True controller ray, gaze fallback, drag scrolling | Spatial launcher with focus-ring/controller navigation; validated but less direct | **Theirs** |
| Runtime tuning | 20–36 m distance, 50–100% render scale, 72/80/90/120 Hz, world scale and comfort UI | Tuned Quest defaults and mod settings; fewer user-facing native controls | **Theirs** |
| Battle presentation | Multiple OpenXR depth planes and deterministic HUD ordering | Tracked Pokedex works, but battle camera/feed remains a documented low-priority regression | **Theirs** |
| Render optimization | Grass chunks, directional wall groups, distant-detail and connected-map submission culling, reflection removal | Bounded streaming, route history, location-aware preload and transition tuning validated across Kanto | Complementary |
| Launcher/importer | Spatial ray launcher; atomic SAF polling and lower-memory ZIP mounting | Preserved upstream launcher/mod manager/ROM workflow, Quest focus system and classic loading UI | Mixed |
| Lifecycle | EGL/session recreation, stale-session recovery and clean OpenXR shutdown in source | Controller sleep, quick/30-second/10+-minute pauses and resume behavior validated on a physical Quest | **Ours in validation; theirs has useful design ideas** |
| Mods | Bundled old voxel fork and general mod platform | Current Dramaless, Kanto First Person, Wilds of Kanto/Wild Skies testing, Gen-2 preparation | **Ours** |
| Loading/streaming UX | Conventional runtime startup and game loading | Location-aware world preload, progress presentation and readable full-color VR Unplugged loader | **Ours** |
| Provenance clarity | No root license; notices explicitly warn about redistribution | Permission evidence recorded for Dramaless, Kanto First Person and HGSS work | **Ours** |

## Ideas worth independently implementing

### High priority

- **Quest quality menu:** expose render scale, draw distance and supported
  refresh rate without requiring users to edit mod settings. Query supported
  rates and fall back safely rather than assuming 120 Hz.
- **Clean-room culling experiments:** profile grass chunking, directional wall
  batches and rejection of connected-map detail behind the headset. Apply one
  technique at a time to our current Dramaless fork and retain only measured
  wins; do not replace our preload/streaming system.
- **Battle presentation repair:** use the concept of separately ordered world,
  Pokemon, effects, HUD and command layers to solve our compromised Pokedex
  battle view. Design new transforms from our own captures and tests.

### Medium priority

- **Controller ray for dense menus:** add an optional direct-pointer mode for
  the Mod Manager/importer while retaining the working focus-ring path and
  conventional controller navigation.
- **Importer hardening:** independently add atomic `.part` publication and
  avoid loading large mod ZIPs fully into Lua memory if our current importer
  still does so. Verify against current upstream first.
- **PCVR abstraction:** keep Quest EGL and desktop OpenGL session creation
  behind separate backends while sharing actions, view data and layer policy.
  This is the clearest route to supporting the PCVR users now relying on us.

### Low priority

- User-facing world scale, player height, smooth/snap turn and camera-mode
  controls after the stable Quest/Gen-2 merge is complete.
- Draggable VR scrollbars only after direct ray selection itself is stable.

## What not to take

- The bundled Dramatic Shape 1.5.4 tree: ours is newer, permission-backed and
  already integrated with the current project.
- Its older Red/Blue engine or launcher: adopting either would regress Gold,
  Yellow, current mod APIs and our validated import flow.
- Native bridge, Lua facade, pointer, shaders, culling routines or battle-layer
  code verbatim while the repository lacks an outbound license.
- README performance claims as proof: every adopted concept must be profiled on
  our Quest build with the current mod stack.

## Proposed execution order

1. Preserve the promoted `5bbe07e7` Quest baseline and current v0.1.79 work.
2. Finish the upstream/Gen-2 integration boundary before renderer surgery.
3. Add our own refresh-rate/render-scale capability query and settings surface.
4. Benchmark one culling idea at a time against the saved Pallet/Route 1/Route
   2/Route 23 and Saffron/Route 8 paths.
5. Repair the battle Pokedex using independently designed layer ordering.
6. Prototype optional controller-ray UI behind a flag.
7. Generalize the proven Quest bridge boundary into a PCVR backend.

## Evidence and limitations

This audit examined revision `9a90448`, its history, README, release notes,
third-party notice, OpenXR native bridge, Lua VR facade/pointer, Android build
tree, UI files, tests and feature searches. No APK was installed and no ROM or
copyrighted commercial asset was downloaded. Hardware/performance statements
about 1GenPokemonVR remain unverified locally unless explicitly described above
as checked source structure.
