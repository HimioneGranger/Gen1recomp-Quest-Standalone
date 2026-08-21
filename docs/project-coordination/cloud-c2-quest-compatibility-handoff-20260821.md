# Cloud C2 Quest compatibility handoff

Date: 2026-08-21

Status: `host-eligible, independent host accepted, paired-headset pending`.
This record does not claim current device readiness or acceptance. The pair is
not installed, staged, launched, accepted, merged, pushed, published, or
released.

## Ownership boundary

The app is a pass-through transport for the game log. Android logcat keeps the
game log unchanged. DRAMALESS owns the `QRENDER scene-timing` record and all
cloud scene-timing fields. The app has no QRENDER parser, filter, allowlist,
runtime field, JNI bridge, uniform, or second cloud implementation.

DRAMALESS is an external paired dependency. Do not copy DRAMALESS source into
app history. The accepted dependency identity is:

- Source commit: `c82c3e64b826e1c84ec9a3770e2183e3fd6a17de`
- Build: `cloud-c2-advanced`
- Schema: `46`
- Version: `2.0.0-quest.cloud-c2-advanced-test`
- Package SHA-256:
  `6535FC650A93C3C90B38BFA73D471FA827038A3EEF13622EB8FDAAF29D5AB7E6`
- Source-proof SHA-256:
  `D48D82DC541A6E20AA93628DA62C2FE0C346257EA1E968948742FDE011DADFED`
- Source proof binds all `113/113` safe package entries to the source commit.

## Exact QRENDER interface

The existing `QRENDER scene-timing` record has these exact keys and allowed
values:

| Key | Allowed values |
|---|---|
| `skyCloudModel` | `linear-scalar-directional-volume-b1`, `none` |
| `skyCloudResource` | `untried`, `ready`, `failed` |
| `skyCloudFilter` | `untried`, `linear` |
| `skyCloudWrap` | `untried`, `repeat` |
| `skyCloudFailure` | `none`, `allocation`, `setPixel`, `filter`, `wrap` |

Existing `skyCloudLevel` and `skyCloudFetches` fields remain. The exact mapping
is C2 to `4`, C1 to `1`, and C0 to `0`. A bounded failure warning starts with
`Quest cloud resource failed at`.

`skyCloudResource=ready` proves resource setup only. It never proves shader
link, headset pixels, performance, or acceptance. No host result can infer a
device result.

## Exact device preconditions

Before any copy or capture, re-hash the app APK, DRAMALESS ZIP, and source
proof. Use a unique device filename. Confirm that runtime diagnostics match
build `cloud-c2-advanced`, schema `46`, and the version above.

The headset must be awake, its display must be on, proximity must be true, and
it must be actively worn. Installation, staging, launch, and capture each need
separate explicit device authority. Stop if an identity or readiness gate does
not match.

## Paired-headset acceptance gates

Use one continuous video and timestamp-aligned, unfiltered logs for the same
capture interval. Both items are mandatory. Host logs, source tests, resource
readiness, or an old capture cannot replace this paired evidence.

The device run must prove all of these items:

- Cold GLES compile and link logs for both Sky and Water, including uniform
  precision. Record driver shader instruction and register evidence when the
  driver makes it available.
- Resource diagnostics with the exact fields above and the bounded failure
  warning when a resource stage fails.
- Real stereo pixels and world lock during rotation and at least 20 cm of
  translation.
- Dawn, noon, dusk, and night response, plus the same cloud with the sun on
  its left and right.
- A dense core and darker lower mass, a soft edge and organic silhouette,
  scale layering, and slow deterministic drift.
- C2, C1, and C0 runtime behavior with exact cloud-fetch counts `4`, `1`, and
  `0`.
- Real Water reflection and wave distortion from the same cloud field.
- Visual, compile/link, stereo, Water, and frame-time gates must pass together.

## Configured-refresh performance matrix

Run all 12 resolution-by-Water cells at the configured headset refresh. Warm
each cell for 10 seconds, then record one continuous 60-second interval.

| Resolution | Water OFF | Water SKY | Water FULL |
|---|---|---|---|
| RES 1 | 60 seconds | 60 seconds | 60 seconds |
| RES 2 | 60 seconds | 60 seconds | 60 seconds |
| RES 3 | 60 seconds | 60 seconds | 60 seconds |
| RES 4 | 60 seconds | 60 seconds | 60 seconds |

For each cell, record the configured refresh, quality rung, cloud level and
fetch count, CPU time, GPU time, median, p90, p99, missed frames, stale frames,
and reprojected frames. Keep the continuous video and timestamp-aligned
unfiltered logs for that same 60-second interval.

For the C2 motion sequence, use 20 seconds of fixed sky, 20 seconds of slow
yaw across the sun and cloud field, and 20 seconds at a low-angle Water
reflection. Judge frame time in milliseconds against the configured refresh.

## Preservation and rollback

Preserve the source split at
`0bfdc360178f2c31f5b12e956ad88221a007756c`. The app compatibility checkpoint
is a later documentation and test commit; it is not the APK build source.
Preserve the DRAMALESS recovery branch and clean source commit above. Its exact
rollback is parent `550b147fec4c7c1de9150184312b2a79cef5e65d`. Preserve every input package,
proof, provenance file, prior pair, log, and capture. Do not overwrite them.
