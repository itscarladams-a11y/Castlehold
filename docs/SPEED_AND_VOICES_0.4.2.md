# Castlehold 0.4.2 — Speed & Voices

This revision is based directly on the user-provided `Castlehold-Fresh-Install.zip` (Stone & Steel 0.4.1).

## Battle speed
- The top HUD now has a large touch button that cycles **1× → 2× → 3× → 1×**.
- Speed can be changed while the battle is running or paused.
- Godot `Engine.time_scale` is used so movement, combat timers, projectiles, physics and character animations remain synchronized rather than selectively accelerating one subsystem.
- The selected speed is stored in the normal checkpoint snapshot and restored on resume/retry.
- Castlehold resets `Engine.time_scale` to 1.0 on scene exit to prevent speed leaking into tests or another scene.

## Character defeat sounds
- Human oofs, orc defeat exhalations and ogre grunts remain the original offline synthesized assets.
- Voice concurrency increases from 2 to 4 fixed players.
- Character voices are mixed substantially louder than 0.4.1 while still routing through the normal Effects volume/mute controls.
- Voice anti-spam timing scales with 1×/2×/3× so accelerated battles do not become unnaturally silent.
- Human voices retain priority when all voice channels are occupied.

## Regression coverage
`tests/battle_speed.gd` verifies HUD state, cycling, pause behavior, checkpoint restore, invalid-value fallback and engine-speed cleanup. The existing defeat-voice test now verifies the four-channel bounded pool and audible voice gain. GitHub Actions runs both tests before Android export.
