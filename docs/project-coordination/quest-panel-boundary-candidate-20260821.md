# Quest Panel and Boundary Diagnostic Candidate

Date: 2026-08-21

## Base

- Corrected split base: `fefa8b3f1d8fbfbb4043d7ca6b0d0b6764b611b4`
- Corrected app baseline: `548c2f665e085ad3054792986786bfc429cf79f5`
- This candidate does not change DRAMALESS, ROM data, saves, or device data.

## Q44 boundary finding

The completed Q44 log does not show an app request to change Guardian from
Stationary to Roomscale. The native app creates `LOCAL` and `VIEW` OpenXR
spaces. Quest OS logs show `AutoStationaryHelper` repeatedly evaluating nearby
Roomscale Guardian anchors. The same run later reports Guardian
`ANCHOR_QUERY_FAILED` and `GARBAGE_ANCHORS_RETURNED` events.

This evidence does not prove that forcing a different OpenXR space would
preserve the user's Guardian choice. The candidate therefore adds observation
only: supported space types, current STAGE bounds, and detailed reference-space
change events. It does not request Stationary, Roomscale, STAGE, or boundary
visibility changes.

A second exact reproduction showed an orderly app exit. Android paused the
activity, OpenXR moved through `STOPPING` to `IDLE`, and `xrEndSession`
completed. Quest then reported one active safety bound, made it visible, and
changed Home from VR safety to MR passthrough. Its safety indicator changed
from Stationary to Passthrough and removed the Guardian-valid flag. This is a
Quest Home safety-mode transition after app exit, not an app request to disable
the boundary. The candidate now also records every session state, the shutdown
caller, and final STAGE bounds before destroying the OpenXR session.

## Panel placement

The complete shared launcher/loading/game panel moves upward by 15 percent of
its 1.1625 metre height relative to the prior accepted anchor. Startup VIEW
placement, settled LOCAL anchor placement, submitted content, and controller
ray projection continue to use the same pose.

## Verification

- Focused Quest/Android suite: 12 files, 0 failures.
- Panel placement contract: 5 checks passed.
- Boundary diagnostic contract: 4 checks passed.
- Quest OpenXR display contract: 39 checks passed.
- Diagnostic ARM64 Quest APK build: passed.
- `git diff --check`: passed.

## Remaining gate

The candidate is not device-accepted. A separately authorized run must record
Guardian mode before launch, the new diagnostic lines during launch, and
Guardian mode after exit. The same run must accept the 15 percent panel move.
No merge, push, publish, or release is allowed before that evidence passes.
