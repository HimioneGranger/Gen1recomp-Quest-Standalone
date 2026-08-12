# Quest mod permission records

These records document direct creator permission for Quest-specific forks.
They supplement, rather than replace, the license and attribution files carried
by each upstream project. Third-party components and assets remain subject to
their own terms.

## Kanto in First Person

- Creator/contact: `briddsy`
- Platform: Discord direct message
- Request sent: 2026-08-10
- Permission received: 2026-08-11
- Requested scope: make a Meta Quest fork, optimize it for standalone VR, and
  adjust performance specifically for Quest while retaining creator credit.
- Response: "Absolutely go for it 👍"
- Evidence: `kanto-first-person-discord-permission-2026-08-11.png`
- Evidence SHA-256:
  `D23C3DFBC1F07FB73222F38533A36A7A4DBA4C8D133333FB558B7B0D00A85536`

Project policy: preserve upstream attribution and license notices, identify the
Quest fork as unofficial, keep source changes available with releases, and do
not imply that briddsy tested or supports the Quest build.

## Dramaless Shape

- Creator/contact: `Stahltier` / artyrambles
- Platform: public Discord discussion
- Permission received: 2026-08-11
- Requested scope: release and maintain a standalone Meta Quest VR version of
  Dramaless Shape, or allow the creator to publish it, while preserving VR
  functionality that the creator cannot personally test or debug.
- Response included: "you have all of my blessings and then some" and that the
  creator had hoped someone would do exactly this.
- Evidence: `dramaless-shape-discord-permission-2026-08-11.png`
- Evidence SHA-256:
  `4D57C788F7B82E7FB507F0FD0AE393295E1D775BC935294EC1667A89F787F2D8`

Project policy: retain Dramaless and original Dramatic Shape attribution and
license notices, clearly label Quest-maintained changes, avoid implying that
Stahltier tested the VR build, and respect separate terms for inherited code,
OpenXR components, and third-party assets.

## HGSS Sprites / HGSS Overhaul

- Creator/contact: `LucianoNeo`
- Platform: public Discord mod channel
- Permission received: 2026-08-11
- Requested scope: trim or edit HGSS Sprites so it performs better in
  standalone VR, publish a Quest-oriented fork, and retain creator credit.
- Response: LucianoNeo placed an affirmative white-check-mark reaction on the
  request and supplied the corrected official `HGSS_SPRITES-0.3.0.zip` link.
- Evidence:
  - `hgss-sprites-discord-permission-a-2026-08-11.jpg`
  - `hgss-sprites-discord-permission-b-2026-08-11.jpg`
- Evidence SHA-256:
  - `437F2A48C53A309263B9A1B06E2CF5DB07D230DBEBBFF1BA3B1996310135D6E7`
  - `63E270A611AD16CA706A6BD4F594A9217674C60AD4812BE550B3931A3414AB57`

Project policy: treat this as permission for a credited Quest-performance
adaptation of LucianoNeo's mod code and packaging. It is not a blanket grant
over Pokémon imagery, ROM-derived data, or work owned by other contributors.
Audit the repository license and asset provenance before distributing a fork;
prefer runtime extraction from the user's legally imported ROM wherever
redistribution rights are unclear.

### Private-fork boundary

The HGSS derivative is owner-private and must remain separate from the public
Gen1Recomp Quest project:

- no HGSS source, assets, binaries, ZIPs, or Git history in the public Quest
  repository or APK;
- no public remote, public CI artifact, public release, or automatic upload;
- no ROM, extracted ROM data, save, cache, token, credential, or private URL in
  its repository;
- keep only the minimum material needed for the private build and retain all
  attribution/notices;
- exchange builds only through an explicitly approved private destination;
- treat accidental disclosure as possible: private status reduces exposure but
  cannot guarantee that a copied file will never leak.

If a leak occurs, rotate any exposed credentials/links, remove accessible
artifacts where possible, record the affected version/hash, and notify relevant
contributors. This separation is risk containment, not permission to
redistribute material whose rights are held by third parties.
