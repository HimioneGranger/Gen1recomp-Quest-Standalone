# Optional Quest OpenXR host backend

The `questVr` Android product flavor packages an optional native OpenXR host
that presents the existing Gen1Recomp launcher on a room-anchored quad. It is
an adapter around the ordinary launcher, not a second launcher implementation.
The desktop and stock Android variants neither compile nor package this host.

## Boundaries

- `src/core/HostDisplay.lua` remains a generic no-op interface unless a
  packaged backend is detected.
- `src/host/android/QuestOpenXRDisplay.lua` converts Quest Touch input into the
  launcher's existing virtual-pointer and button paths, and submits completed
  launcher-frame metadata to the native host.
- `libquestxr.so` owns the launcher OpenXR session, room anchor, controller-ray
  projection, thin focus border, and compositor pointer.
- LÖVE exposes one optional Android presented-frame observer. Its default is
  null and it contains no Quest or OpenXR dependency.
- A gameplay VR mod may use `QUEST_PANEL_ACTIVE` only as a capability signal:
  keep the panel session alive while preparing, then request the established
  launcher-to-gameplay OpenXR handoff. Stereo rendering remains mod policy.

The compositor pointer is launcher-only. Lua explicitly enables it for a
launcher frame; live native ray tracking may update coordinates only while
that visibility flag is enabled. This prevents the launcher selector from
appearing over a game frame or a mod-owned preparation card.

## Physical validation — 2026-08-12

A Quest 3 test with Dramaless Shape `1.6.4-quest.14` passed the complete path:

1. launcher displayed upright and room-anchored;
2. Touch ray moved a crisp white selector and activated Yellow;
3. selector disappeared when launcher UI ended;
4. the mod's save-aware loading card updated on the retained panel;
5. launcher OpenXR exited and released its session cleanly;
6. gameplay OpenXR started and reached FOCUSED automatically.

The validated debug APK SHA-256 was
`7BE8565B7C7344D83954ACD79139FB8F1D37E65CD245F83F035AAEE928F6EF23`.
It was built as `questVrNoRecordDebug` and installed with `adb install -r`,
preserving app data.

## Remaining validation

- Long suspend/resume and controller-sleep soak.
- Repeated launcher/gameplay handoffs and map transitions.
- Quit-path stress testing. One earlier build observed a native
  `pthread_mutex_lock called on a destroyed mutex` abort during shutdown; do
  not promote the backend until that race is reproduced or cleared by a
  sufficiently long lifecycle test.
