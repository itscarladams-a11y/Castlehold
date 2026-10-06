# Castlehold 0.5.0 — Bantam Entertainment branding

## Approved studio mark

The build ships the approved red/black/gold **Bantam Entertainment** logo with no domain name at `res://assets/ui/bantam_studio_logo.png`.

## Startup flow

1. Godot's native boot splash shows the studio logo on black while the engine initializes.
2. `StudioSplash.tscn` becomes the project main scene.
3. `studio_splash.gd` begins a threaded load of the real Castlehold battle scene.
4. The red/gold progress bar reads the actual `ResourceLoader` threaded progress. A short presentation ramp prevents fast devices from flashing past the branding, but the splash cannot complete until the battle scene reports loaded.
5. The game transitions to `battle.tscn`.

The progress bar is therefore functional UI, not artwork baked into a loading-screen image.
