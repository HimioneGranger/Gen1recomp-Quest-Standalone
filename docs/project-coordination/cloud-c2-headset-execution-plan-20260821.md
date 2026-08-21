# Cloud C2 headset execution plan

Date: 2026-08-21

Status: `host candidate, independent rereview pending, paired-headset pending`.
No device action is authorized by this document.

This file is the sole authoritative device procedure for the Cloud C2 test.
The earlier implementation artifact `PAIRED_HEADSET_GATE_PLAN.md` remains
preserved, but it is superseded for physical execution because its 30-second
cell instruction failed independent review. Do not use that old instruction.

## Preservation and limited supersession

All Q43, Q44, Q45, post-Q44, post-parity, paired-launcher, failed Cloud C2
`-001`, and other prior pair/evidence directories remain preserved. The new
`-002` pair supersedes them only as the candidate for this Cloud C2 test. It
does not accept or replace their historical results for any other lane.

Preserve the source split at
`0bfdc360178f2c31f5b12e956ad88221a007756c`, the immutable APK build source
at `430b731553c4089e65e23a9505c78bf5ee811259`, and the DRAMALESS source at
`c82c3e64b826e1c84ec9a3770e2183e3fd6a17de`. The DRAMALESS rollback is parent
`550b147fec4c7c1de9150184312b2a79cef5e65d`.

## Authority and readiness gates

Obtain separate, explicit authority for device access, installation, staging,
launch, and capture. Before each action, confirm that the headset is awake,
the display is on, proximity is true, and the headset is actively worn. Stop
on any authority, identity, or readiness mismatch.

Before staging, re-hash the exact host APK, DRAMALESS ZIP, source proof, and
pair checksum list. Use a unique staged filename. Re-hash the staged device
file and require an exact host/device match before launch. Confirm the runtime
reports build `cloud-c2-advanced`, schema `46`, and version
`2.0.0-quest.cloud-c2-advanced-test`.

## Capture evidence

For every measured interval, record continuous both-eye video plus
timestamp-aligned, unfiltered logs for the same interval. Neither source nor
host evidence can replace device evidence.

On a cold run, collect Sky and Water GLES compile and link logs, including
uniform-precision diagnostics. Collect driver shader instruction and register
evidence when the driver makes it available. Require these exact resource
diagnostics:

- `skyCloudModel`: `linear-scalar-directional-volume-b1` or `none`.
- `skyCloudResource`: `untried`, `ready`, or `failed`.
- `skyCloudFilter`: `untried` or `linear`.
- `skyCloudWrap`: `untried` or `repeat`.
- `skyCloudFailure`: `none`, `allocation`, `setPixel`, `filter`, or `wrap`.
- The bounded failure warning starts with `Quest cloud resource failed at`.

Prove real stereo pixels and world lock during rotation and at least 20 cm of
translation. Capture dawn, noon, dusk, and night, and the same cloud with the
sun on its left and right. Show a dense core, darker lower mass, soft edge,
organic silhouette, scale layering, and slow deterministic drift. Prove C2,
C1, and C0 with exact cloud fetch counts `4`, `1`, and `0`. Prove real Water
reflection and wave distortion from the same cloud field.

Capture a lower/under-cloud view that looks up at the same cloud and makes its underside and darker lower mass unambiguous.

## Exact 4x3 performance matrix

Run all 12 resolution-by-Water cells at the configured target refresh. For
each cell, warm each cell for 10 seconds, then capture and measure each cell
continuously for 60 seconds, not 30.

| Resolution | Water OFF | Water SKY | Water FULL |
|---|---|---|---|
| RES 1 | 60 seconds | 60 seconds | 60 seconds |
| RES 2 | 60 seconds | 60 seconds | 60 seconds |
| RES 3 | 60 seconds | 60 seconds | 60 seconds |
| RES 4 | 60 seconds | 60 seconds | 60 seconds |

For every cell, record the configured refresh, quality rung, cloud level,
cloud fetch count, CPU time, GPU time, median, p90, p99, missed frames, stale
frames, and reprojected frames. Acceptance is against the configured target
refresh, not only the 72 Hz minimum.

If it provides distinct evidence, also capture one separate 60-second C2
visual sequence: 20 seconds of fixed sky, 20 seconds of slow yaw across the
sun and cloud field, and 20 seconds at a low-angle Water reflection. This
sequence does not replace any matrix cell.

## Acceptance

Accept only when identity, readiness, cold compile/link, resource diagnostics,
stereo, world lock, all visual phases, C2/C1/C0, Water, and configured-refresh
performance gates pass together. Preserve all raw video and logs. On failure,
stop and return to the preserved source, app, and DRAMALESS recovery points.
