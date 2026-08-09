# Quest 3 standalone port: Phase 1 architecture audit

Audit date: 2026-08-09. Gen1Recomp baseline: `origin/dev` at `943ba5d`, local branch `quest-openxr`. Dramatic Shape baseline: `origin/master` at `c4d997c`, local branch `quest-openxr`; the older divergent `origin/pcvr` (`e8caa4f`) was inspected but was not selected because current `master` already contains the PCVR implementation plus later work.

This document records checked source, not assumptions. No ROM, extracted ROM data, or commercial asset was used.

## Architecture summary

Gen1Recomp is a LÖVE 11.5 / LuaJIT application. `main.lua` and `conf.lua` boot Lua modules under `src/`; rendering is performed through `love.graphics`. Game data is imported from a user-supplied, hash-validated ROM into the writable LÖVE save area. Generated ROM-derived directories are explicitly excluded from Android packaging by `scripts/build_android.sh`.

The Android application is the vendored love-android 11.5a tree under `mobile/android`. The `app` module embeds a zipped `game.love`; the `love` library compiles LÖVE, LuaJIT, SDL2 and its native dependencies with ndk-build. `GameActivity` extends SDL's `SDLActivity`. SDL owns the Android activity/native event loop and creates/manages the GLES/EGL window context used by LÖVE.

Dramatic Shape is an API-2 content mod (`manifest.json`) loaded by Gen1Recomp's mod runtime. Its entry point registers a `voxel` render pipeline and several event/hook wrappers. `lib/VoxelScene.lua`, `Voxel3D.lua`, `ChunkMesher.lua`, `TileShape.lua`, shaders, meshes and Lua math implement the 3D/voxel presentation using ordinary LÖVE graphics. Its PCVR layer renders a LÖVE canvas per eye and copies those images into OpenXR OpenGL swapchains.

## Android build and mobile implementation

- Entry: `scripts/build_android.sh` applies branding, validates the Yellow import metadata, zips `main.lua`, `conf.lua`, `src`, `data`, `assets`, save editor and ROM manifests into `app/src/embed/assets/game.love`, then runs `assembleEmbedNoRecordDebug`.
- Build: Gradle 8.1, Android Gradle Plugin 8.1.1, compile/target SDK 34, min SDK 16, NDK `25.2.9519653`, JDK 17.
- ABIs: release/default native filters are `armeabi-v7a` and `arm64-v8a`; debug adds `x86_64`. Therefore stock source already contains the required Quest CPU ABI.
- Native build: `mobile/android/love/build.gradle` calls ndk-build with `love/src/jni/Android.mk`. The source tree vendors LÖVE, LuaJIT, SDL2 and third-party libraries. JNI shared libraries are packaged by Gradle into the APK.
- Graphics: love-android uses SDL's Android backend and OpenGL ES through EGL. LÖVE's graphics layer and its GLSL translation remain the application-facing API. There is no Vulkan renderer or Android OpenXR integration in the checked application.
- Mobile bridge: `mobile/android/love/src/main/java/org/love2d/android/GameActivity.java` extends `SDLActivity` and adds Gen1Recomp-facing file picker, save export, HTTP download, restart, step-counter and secondary-display helpers.
- ROM/mod import: Android invokes Storage Access Framework `ACTION_OPEN_DOCUMENT` (or legacy `ACTION_GET_CONTENT` on API 16-20), copies the selected stream into the LÖVE save directory as `picked_rom.gb`, `picked_mod.zip`, or `picked_save.sav`, and Lua consumes it. `src/import/RomImporter.lua` hashes ROMs, installs mod ZIPs into the writable mods tree, and deletes consumed picker copies. This path is suitable for preservation on Quest.
- Mods are not fused into `game.love`; the build script deliberately leaves them user-installable/removable. This is the correct behavior for Dramatic Shape and for copyright separation.

## Dramatic Shape hooks and renderer

- `main.lua` receives the engine mod object, loads sibling Lua through `mod:read`, and registers `mod.content.render_pipelines:register("voxel", ...)` with update and `drawWorld` functions.
- It also registers a tilt-shift pipeline, settings/menu hooks, map reload/block events, battle/save events, Pokémon sprite hooks and time-of-day hooks.
- The voxel path consumes the engine map/camera/palette context, builds chunk meshes and structure meshes, and renders them with LÖVE canvases, meshes, shaders, depth testing and ordinary textures. `VoxelScene` accepts an `eyes` path so shared work (notably shadow/pose work) can be reused while drawing two eye cameras.
- `VR.lua` conducts frames from the render-pipeline update hook: OpenXR event polling, `xrWaitFrame`, eye location, per-eye render, swapchain copy, optional UI quad, controller mapping and `xrEndFrame`.
- `VRRig.lua` is pure Lua matrix/pose math. It maps OpenXR LOCAL metres to voxel-world pixels and provides per-eye view/projection cameras, diorama/first-person/battle mounts, head yaw/pitch and tracked-prop matrices.

## PCVR implementation and complete platform inventory

The checked VR backend is intentionally Windows-only. `VR.supported()` returns true only for `love.system.getOS() == "Windows"`.

| Component | Checked implementation | Classification | Quest consequence |
|---|---|---|---|
| LÖVE game/runtime API | LÖVE 11.5 Lua application | ANDROID COMPATIBLE | Retain. |
| LuaJIT and Lua `ffi` | Vendored in love-android; mod uses `require("ffi")` | ANDROID COMPATIBLE | ARM64 FFI is available in principle, but Android native library names/ABI and structs must differ. |
| SDL Android activity/event loop | `GameActivity extends SDLActivity` | ANDROID COMPATIBLE | Retain or minimally extend for XR lifecycle. |
| SDL GLES/EGL window context | love-android native backend | ANDROID COMPATIBLE | Existing flat context works; OpenXR must bind to an Android EGL context. Whether SDL's exact context can satisfy the Quest runtime must be proved. |
| Voxel renderer, chunk mesher, shaders | LÖVE meshes/canvases/shaders | ANDROID COMPATIBLE | Retain; performance and shader limits require device testing. |
| `VRRig.lua` pose/camera math | Pure Lua | PORTABLE | Retain. |
| `VR.lua` orchestration/controller mapping | Mostly platform-neutral, guarded to Windows | PORTABLE | Split capability detection from backend selection; retain high-level flow. |
| `VRXR.lua` OpenXR frame/session logic | Direct OpenXR 1.0 FFI | PORTABLE | State-machine concepts and most core structs/calls are reusable. Native loading and graphics binding are not. |
| `assets/vr/openxr_loader.dll` | Khronos x64 Windows loader | WINDOWS SPECIFIC | Must not be loaded or packaged as the Quest loader. |
| DLL extraction to save directory | `dramatic_shape_openxr_loader.dll`, then `ffi.load` | WINDOWS SPECIFIC | Remove from Android path; Quest uses an ARM64 Android `.so`/platform loader packaged in `lib/arm64-v8a`. |
| `XrGraphicsBindingOpenGLWin32KHR` | HDC/HGLRC session binding | WINDOWS SPECIFIC | Replace with `XrGraphicsBindingOpenGLESAndroidKHR` and Android/EGL handles. |
| `XR_KHR_opengl_enable` | Desktop OpenGL extension | WINDOWS SPECIFIC | Replace with `XR_KHR_opengl_es_enable`. |
| `XrSwapchainImageOpenGLKHR` | Desktop GL swapchain image | WINDOWS SPECIFIC | Replace with `XrSwapchainImageOpenGLESKHR`. |
| `VRGL.lua` `ffi.load("opengl32")` | Windows OpenGL 1.1 export DLL | WINDOWS SPECIFIC | Replace with GLES library or, preferably, a small native bridge. |
| `wglGetCurrentDC`, `wglGetCurrentContext` | Win32/WGL context access | WINDOWS SPECIFIC | Replace with EGL display/context/config discovery or explicit native ownership. |
| `wglGetProcAddress` | Windows extension lookup | WINDOWS SPECIFIC | Replace with `eglGetProcAddress`/linked GLES entry points. |
| GL FBO/canvas introspection | Bind LÖVE canvas, query `GL_DRAW_FRAMEBUFFER_BINDING` | NEEDS QUEST REPLACEMENT | Semantics may be reusable, but must be verified against LÖVE GLES state/cache and Quest runtime constraints. |
| Canvas-to-XR texture blits | GL framebuffer attach/blit | NEEDS QUEST REPLACEMENT | Reimplement/test with GLES 3 and OpenXR swapchain images; avoid stale LÖVE state. |
| Window front-buffer UI capture | reads `GL_FRONT` from desktop window | WINDOWS SPECIFIC | Android default framebuffer/front-buffer assumptions do not carry over; render UI to an explicit canvas/texture. |
| OpenXR Android loader integration | None in checked source | NEEDS QUEST REPLACEMENT | Add Khronos/Meta Android ARM64 loader and manifest/native configuration. |
| Android activity/OpenXR lifecycle bridge | None in checked source | NEEDS QUEST REPLACEMENT | Instance creation needs Android loader initialization/activity context; session pause/resume must follow Android lifecycle. |
| Quest controller interaction profile | Existing suggestions cover PC profiles in FFI source | UNKNOWN | Verify/add Meta Touch profile bindings from checked OpenXR headers/runtime requirements. |
| Quest manifest/device features | Standard Android game manifest only | NEEDS QUEST REPLACEMENT | Add VR category/features/metadata required by current Meta distribution after checking official requirements. |
| Vulkan path | None | UNKNOWN | Not selected; GLES is the smallest compatible continuation of current LÖVE renderer. |

The repository also contains `oxr.zip` and an unpacked `oxr/` NuGet payload with Windows/UWP `.dll` and `.lib` variants (including Windows-named ARM/ARM64 artifacts). These are not Android ELF libraries and are WINDOWS SPECIFIC. They are not evidence of a Quest backend.

## Recommended minimal port seam

Do not rewrite the voxel renderer. Keep `VR.lua` and `VRRig.lua` as the high-level interface. Introduce an Android/OpenXR backend behind the current `VRXR`/`VRGL` API, ideally as a small ARM64 JNI/native module that owns loader initialization, Android/OpenXR structs, EGL/GLES interop and lifecycle. Keep the Win32 FFI implementation untouched for desktop. Render the flat UI into an explicit LÖVE canvas shared with the XR backend instead of reading a window front buffer.

Before that work, the stock Android ARM64 build and launch/import flow must be reproduced. Headset testing will then determine whether SDL/LÖVE's existing EGL context can be bound directly or whether XR must own the EGL surface/context and expose a narrower texture submission bridge. That decision remains UNKNOWN until device/runtime validation; the checked source alone does not settle it.
