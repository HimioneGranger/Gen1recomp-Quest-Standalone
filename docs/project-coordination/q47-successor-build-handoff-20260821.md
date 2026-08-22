# Q47 successor build handoff

## Source and rollback

- Source commit: `1eb0880aaf88ed4f579fcc818be60d3e1656bc46`.
- Parents: `e901fc00159c85ec92306487612871a6bb8f835c` and
  `77c59d21802f7ab1b948e578f9fce88f65a3469d`.
- Rollback: reset the integration branch to first parent `e901fc00`; all
  protected worktrees remain separate and unchanged.
- Build was offline with local JDK 17, SDK/NDK, Gradle 8.5 cache, and local
  dependencies. No install, launch, ADB, Quest, network, release, or push.

## Package evidence

All APKs use `QuestGameActivity`, version `0.1.81` / code `181`, and debug
signer certificate SHA-256
`b1aa77b295eaaba52867af6dc7f9a2813590031208e93218d1c62b66c6c97291`.
Each embeds `game.love` SHA-256
`c0a8d499f716ae43df7948eb1bf33d4e43a684d2dab40ebd24b8b99465f72516`.

| Identity | Label | Size | APK SHA-256 |
|---|---|---:|---|
| `com.theboisclub.pokemonred` | `Gen1Recomp VR Unplugged` | 29,554,100 | `e684e648ed46c44b8ed4ed7b78aca08577e98fb94963c610fce5e9c3a0aa9aaa` |
| `com.theboisclub.pokemonred.test` | `Gen1Recomp Test` | 29,554,096 | `82444155e95ce1b4547200454b64c92420604019714aa89a3a71fa78cf0cbd53` |
| `com.theboisclub.pokemonred.diagnostic` | `Gen1Recomp Diagnostic` | 29,554,108 | `75167e1b40484d3b20ba5b852b055f96a141cc2b1cd497c9e7092eec38b3b939` |
| `com.theboisclub.pokemonred.recordtest` | `Gen1Recomp Test` | 29,554,100 | `de46e78c4dd49e098873b00a94f63b40a4d441e39f196a7be3e64ad187f10d99` |

Ignored local candidates are under
`dist/android/candidates/q47-1eb0880a/`. A second independent normal build
reproduced the exact normal APK hash above. Two package-only runs also
reproduced the exact embedded payload hash.

## Remote handoff

No network operation was done. The exact future remote action is a
fast-forward-only push of `codex/quest-core-split-final-20260822` at the
recorded source commit, after the owner verifies the configured destination.
Do not update or merge PR #19. Use this body for the successor PR/handoff:

> Integrates Q47 Quest compatibility split through zero-gap parity endpoint
> `77c59d21` in reviewable merge `1eb0880a`. Preserves host boundaries,
> Quest/OpenXR, V8, panel placement, labels, identities, and mods. Offline
> normal/Test/Diagnostic/record-test Quest debug APKs verify their stated
> identities and signer; normal rebuild is byte-identical. No device or
> installed app was touched.
