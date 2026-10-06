# Castlehold — active design change, September 2026

Version 0.5.1 fixes deterministic naming/validation for battlefield-side dressing without changing gameplay. Version 0.5.0 added the approved Bantam Entertainment no-domain studio logo, a solid-black branded startup scene with a functional threaded loading bar, and a matching native boot splash. Version 0.4.9 keeps the 120-wave Gravecaller finale and treats the necromancer plus his surviving force as one final boss encounter. The first premium-production pass adds material-aware impact audio/VFX, restrained camera trauma, less synchronized unit presentation and denser battlefield-side dressing. Version 0.4.8 originally added the final-boss completion contract, Victory fanfare, 4× speed and Save for Later. Killing the Gravecaller alone does not complete the campaign; victory occurs only when the final reinforcement queue and battlefield are clear. The finish displays VICTORY and plays a dedicated triumphant fanfare. Battle speed expands to 1×/2×/3×/4×, and a manual Save control pauses then writes the current live campaign state for later continuation without moving the current in-session Retry Wave anchor. The 0.4.6 Android anti-flash rendering changes remain in place.

Version 0.4.4 keeps the 1×/2×/3× synchronized battle-speed control and louder four-channel human/orc/ogre defeat voices, and replaces the earlier light castle polish with a fuller fortress overhaul: larger gatehouse towers, a raised watch chamber, a much taller keep, twin roof turrets, a stronger watchtower and roofed corner towers. Combat balance is otherwise unchanged from 0.4.3.

The latest user direction supersedes the original preparation/aftermath rounds and 30-wave campaign schedule for the current playable mode. The active mode is now a **120-wave continuous siege**: 10–15 seconds of enemy reinforcements, then a 3–5 second gap. Existing combat continues through gaps. Recruitment and Gate/Keep repairs stay available; Pause freezes the siege while allowing management.

The medieval character redesign includes archers, sword-and-shield infantry, spearmen and mounted knights, plus corresponding enemy infantry/ranged/cavalry threats. Warm brown sandstone and smaller masonry replace the cooler fortress palette. Finger scouting remains. Surviving troops heal at wave starts without being recreated; castle damage persists. Wave-start checkpoints support paused resume/retry.

Version 0.2.2 adds original medieval background music at a medium-low 35% default. Settings adjusts music and effects independently, with master mute and saved preferences. Music remains audible during the paused Settings panel; app backgrounding suspends audio. The prior 0.2.1 graphics improvements are included.

The 0.3.0 playtest revision responds to reported screen flashing, low difficulty through wave 44, and indistinct human enemies. The attackers are now the Ironroot Horde: orc marauders, hunters, impalers, shielded orcs, warg riders and siege ogres. Formations and counters increase pressure, with longer ogre windups and bounded club splash. Pooled dust now fades in correctly; depth precision, animated bounds, shadow transitions and subpixel detail have been adjusted to reduce popping and shimmer. The exact phone-specific flashing report still requires device confirmation. Continuous pacing, pause, scouting, army persistence and music/settings remain in place.

Version 0.3.1 adds the requested ogre rider on a giant warthog and a fire-casting ogre shaman. The rider is heavy cavalry with an accelerating charge that spearmen counter; the shaman launches staff-tip fireballs with limited splash. Introductions are wave 25 and wave 18 respectively, replacing existing assault slots. Pause freezes both projectiles and staff effects.

Version 0.4.0 implements the approved giant boss concepts at waves 25, 50, 75 and 100. Their authored encounters supplement normal formations, use named health displays, and preserve nonstop pacing and pause. See docs/SIEGE_BOSSES_UPDATE.md for their actual abilities and scope.

Version 0.4.1 improves the actual castle and all sixteen character meshes with finer masonry, carved gate detail, shaped armor, textured mail/cloth and more expressive ogre faces. All attacker damage rises by 12%, including boss specials and charges. Boss defeat bounties and interval income increase to support paid replacements. Brief, family-friendly human oofs and creature grunts trigger at defeat through a bounded audio pool and the existing Effects setting.

See README.md and BALANCE.md for implemented behavior. The original specification below is retained as a future feature reference. Its preparation timers, original campaign schedule and old slice-status statements are historical, not descriptions of 0.2.0.

---

# Castlehold — production design

The user's 64-section Castlehold brief is the primary specification. This is the implementation companion, not a replacement or reduced commercial scope.

## Vision and platform
Original offline landscape Android 2.5D castle defense for ages 8+, using Godot 4.7.2 and GDScript, Mobile/Vulkan with a compatibility launch path. Castle left third, enemies from right. Modern stylized characters with readable silhouettes, no gore. Priority: character identity, readable combat, army persistence, visible castle deterioration, counters, performance, extensibility. No ads, timers, network requirements, paid engine or mandatory paid assets.

## Full game loop
Preparation without timer → 3–5 s approach → automatic battle with tactical spells → aftermath. Survivors heal; casualties do not resurrect; structures retain damage. Retry restores a preparation checkpoint and permits different purchases. Campaign 30 waves, bosses every five, then Endless. The current First Stand build has three raider-only test encounters, explicitly separate from the proposed campaign's teaching schedule.

## Castle
Keep 5,000 HP (loss condition); gate 2,200 HP; three wall sections 1,600 HP each; mage tower 1,400 HP. Structure damage stages at 75/50/25/0%. Gate breaks into physical-looking controlled animated planks and braces; enemies then attack the keep. Normal per-preparation repair is capped at 35% maximum HP, cumulative across taps. Repair price baseline is one gold per four HP, rounded up. Future walls collapse and remove ranged slots, with displaced archers retreating. Mage abilities disable on tower destruction and reactivate above 30%. Current slice implements gate destruction and gate repair; other structure identities/HP are scaffolding, not complete damage systems.

## Combat roster
See BALANCE.md for exact supplied friendly baselines. Soft counters: arrows beat exposed infantry, shields resist arrows, bolts pierce armor, spears beat cavalry, cavalry reaches ranged/siege, fire hurts machines, magic punishes density. Persistent soldiers are individual nodes during battle, aggregate counts at preparation. Planned capacity: ranged 20→48, infantry 24→60, cavalry 6→16, one wizard.

## Abilities and progress
Rally: 30 s cooldown, 6 s duration, infantry +20% attack speed/+15% movement and knockback resistance. Cavalry charge: 20 s cooldown, target area, reform then accelerate. Wizard unlock 450. Bolt 35/1.5 s. Fireball 180/12 s; lightning 150, six jumps ×0.85, 18 s; frost 80 and 50% slow for 4 s, 22 s; meteor 500 center/250 outer, 1.2 s warning, 45 s. These are planned, not in the slice.

Gate upgrade five levels +20% base HP, masonry five +15%, quarters +4 slots, barracks +6, stable +2, blacksmith +5% damage five levels, armory +5% HP five levels. Curve base ×1.55^(level−1), rounded. Advanced classes retain distinct roles rather than becoming mandatory replacements.

## Campaign sequence
1 raiders; 2 archers; 3 shields; 4 spears; 5 ram boss; 6 cavalry; 7 mixed; 8 ladders; 9 heavies; 10 War Chief; 11 berserkers; 12 sappers; 13 mixed; 14 multiple siege; 15 troll; 16 catapult; 17 cavalry wings; 18 ladders/catapult; 19 elites; 20 grand siege tower; 21–24 advanced mixtures; 25 archmage; 26–29 escalating siege; 30 dragon. Boss mechanics and numbers remain as supplied. Future chapter dressing: Green Valley → Autumn Highlands → Stormlands.

## Presentation and performance
16:9 logical 1280×720, adaptive safe margins; touch targets at least 56 logical px with device density review required. Bottom preparation cards collapse in battle. Portraits match models. Top gold/wave/keep status. Planned radial spell cooldowns, tutorials, pause/settings, adjustable music/SFX, vibration, damage numbers and camera shake. Target 60 fps midrange / 30 fallback; actual Android performance must be measured, not inferred from headless testing. Pool projectiles/effects. Target lock hysteresis and inexpensive steering. Spatial partitioning is required before 100+ combatant acceptance.

## Production gates
M1: visual combat slice and art review. M2: validated economy, saves, persistent army and repairs. M3: counters, cavalry, wizard. M4: full siege and multiple breaches. M5: campaign/bosses/tutorial/endless. M6: art/animation/audio/UI/device polish. This repository begins M1 and includes supporting M2 systems to make it playable. It does not declare M1's commercial visual bar passed. See docs/STATUS.md.
