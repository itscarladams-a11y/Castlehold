# Boss Cadence 0.4.5 — validation note

Version 0.4.5 changes the live boss schedule to 20/40/60/80/100 and adds the Stone-Eye Warlord resource/coverage. The historical endurance numbers and `*-output.txt` files below were generated before this cadence change and must not be treated as 0.4.5 balance results. The included GitHub Actions workflow reruns boss, continuous-siege and endurance tests on the 0.4.5 source before APK export.

# Speed & Voices 0.4.2 — local validation addendum

The 0.4.2 patch changes battle-speed control, defeat-voice mixing, HUD wiring, version metadata and CI regression coverage. The original 0.4.1 validation record follows below.

# Stone & Steel 0.4.1 — validation

Pinned runtime: Godot 4.7.2.stable.official.ed1daf0bf, Linux headless. Native import completed without script/resource errors. All sixteen model buffers match their glTF lengths and embedded SHA-256 fingerprints. Atlas dependencies exist and optional authoring scripts compile. The cumulative archive is also reconstructed over the original baseline and checked with a clean import and focused gameplay tests.

| Test group | Passing checks |
|---|---:|
| Core combat, purchases, repairs and persistence | 35 |
| Camera, safe input and fortress | 15 |
| Graphics resources, actual mipmaps and bounded effects | 10 |
| Music and settings | 18 |
| Defeat voices and attacker scaling | 16 |
| Orc horde mechanics and restore | 20 |
| Warthog rider and fire shaman | 31 |
| Giant bosses, contact, warnings, saves and final victory | 42 |
| Continuous 100-wave pacing and pause | 15 |
| Full mixed-army siege | 1 |
| Archer-only policy failure before wave 100 | 1 |
| Total | 204 |

The eleven adjacent `*-output.txt` files contain the final production-configuration results. Tests use the same shipped Resources, including the 1.12 attacker multiplier, 95 + 8 × wave interval gold and revised boss bounties. No diagnostic balance overrides are included in the release or final runs.

## Difficulty calibration

The unchanged mixed purchase policy completes wave 100 in 1,708.00 simulated seconds, about 28.5 minutes. It records 228 defender casualties, versus 214 in 0.4.0. Peak active combatants are 116, with 130 unit nodes between accelerated cleanup passes. It maintains an intact 2,200 HP Gate and 5,000 HP Keep and spends no repair gold. At Ironjaw's defeat it has 30 archers, 30 swordsmen, six spearmen and eight knights, with 6,583 gold. It pays normal replacement prices throughout.

The contrasting policy buys only archers after the starting garrison. It loses at wave 55 after 904.35 simulated seconds, with 177 recorded casualties and 4,210 gold spent on repairs. Peak active combatants are 74; Dreadscale remains alive at defeat. The preceding release's archer-only policy reached wave 56. Extra income cannot replace a frontline or anti-cavalry support.

A direct 12% attack increase with the old income caused the reference defense to collapse before it could defeat the final boss. Increased boss bounties alone did not resolve that. The final interval income is 95 + 8 × wave rather than 95 + 6 × wave, and bounties are 750 / 1,250 / 2,000 / 2,500. Enemy composition, five-wave ogre cadence, troop prices, friendly stats, force caps and wave timing are unchanged. The mixed purchase policy and its win-at-100 requirement were not weakened.

These results demonstrate one affordable winning policy and the need for counters. The substantial final reserve in the mixed run means this is not a claim that every part of the campaign is optimally difficult. Human play should assess replacement frequency, boss danger and the cost of mistakes. All attackers hit 12% harder, but income also changes; the casualty comparison is not an isolated measurement of the attack multiplier.

Both policies step actual game AI, projectiles, economy and waves at 0.05 seconds, without injected gold, healing or damage advantages. Cosmetic random generators are separate. Expired corpses are removed periodically during accelerated runs; real-time fall cleanup is covered by integration tests. These are not Android frame-time measurements.

## Graphics and audio

All sixteen imported character models have one complete mesh surface, faction vertex colors, shared 512² albedo and normal maps, distinct ORM regions and mipmapped filtering. The graphics check also confirms actual albedo mip levels. Castle sandstone, oak and slate imports explicitly generate mipmaps. The final CPU review samples actual geometry, authored UVs and albedo maps; it does not reproduce Mobile-renderer lighting or normal-map detail.

Ordinary human/orc foot soldiers use about 5,000–7,000 triangles. The giant warthog rider uses 14,648 including its mount; bosses range from 13,878 to 26,866. Complete rigs use 24–40 meaningful joints. The castle review export contains 223,225 triangles, batched by structure/material. Rigid skin weights and missing authored LODs remain limitations. UI-free on-device visual review remains the commercial character quality gate.

The 16 new defeat-voice checks cover nonfatal hits, one fatal cue, family identity, Effects routing, pause/resume, background suspension, mute, zero volume, rotating variants, bounded crowd overlap, nine distinct audible short samples, and exact enemy/charge scaling. The source WAV bank contains 192,636 bytes of original mono 24 kHz synthesis, with a maximum normalized peak of 0.73. It contains no actor recordings or external samples. The sample report is in `defeat-voice-report.json`.

Music remains at the adjustable 35% default. Voice playback uses two preallocated players, short throttles and no delayed queue. The castle's new braziers are static emissive geometry; no new full-screen flash or dynamic scene light is added.

## Combat, pause and saved state

The retained suite checks gate break/repair, intruders inside a repaired gate, paid repair allowances, survivor healing, casualty relief, purchases during pause, checkpoint retry/backup, legacy saves and all 100 assault/gap intervals. Elite and boss tests verify animation/contact timing, charge counters, fixed-area firestorm flight and damage on arrival, faction/height-aware splash, named health displays, warning freeze, queued summons, consumed thresholds after restore, one bounty per defeat and clearing the final boss/support queue before victory. Boss contact expectations include the configured attack increase; normal wave growth does not apply to curated bosses.

## Build and device limits

The HTTP/1.1 download/retry fix remains in both workflow downloads. Android version code is 10, with the existing package ID and version 2 checkpoints. The new source must be imported, tested and exported by the included Actions workflow before installing its APK. No local APK export or successful remote Actions run is claimed for this release.

Physical Android review is still needed for fine-detail shimmer, the previously reported intermittent flashes, lighting, animation, touch scouting, notch/safe-area layout, speaker balance, background/resume and late-wave frame rate. Headless checks and CPU asset previews cannot establish 60 fps, final sound quality or commercial visual readiness.

## Full source package — 14 September 2026

`Castlehold-Fresh-Install.zip` contains the complete tracked source tree and assets, including the workflow, directly at repository root. This packaging revision changes setup documentation only; the 0.4.1 game, balance and build workflow are unchanged.

Fresh-package verification extracts the archive into an empty directory, compares every file against the committed source, imports it with the pinned engine and runs core integration, graphics and defeat-voice tests (61 checks). No original-source archive, previous update, import cache or earlier installation supplies files to that directory. The full 204-check gameplay results above remain those of the unchanged Stone & Steel game. APK export remains the job of the included GitHub Actions workflow.
