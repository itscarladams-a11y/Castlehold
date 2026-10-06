# Castlehold 0.4.5 — local static validation

The 0.4.5 boss-cadence source passed **349 local static/package checks with 0 failures** in the artifact workspace.

Validated items include:
- exact boss schedule at 20 / 40 / 60 / 80 / 100
- Stone-Eye Warlord resource wiring, runtime registration and save validation
- Android version metadata 14 / `0.4.5-boss-cadence`
- runtime `res://` references
- 20 JSON/glTF files and their linked buffers/textures
- 21 WAV files plus bundled OGG header
- 18 Python authoring tools compiling
- GitHub Actions YAML plus shell-block syntax
- presence of every workflow test script
- basic GDScript delimiter/source integrity checks
- no merge-conflict markers or zero-byte source files

## Engine/runtime limitation

This workspace does not include a runnable Godot 4.7.2 editor or Android SDK. Therefore this pass does **not** claim a live Godot parser/import, the deterministic endurance result, or an APK export. The included GitHub Actions workflow performs those authoritative checks after push. Historical `*-output.txt` endurance files predate the 0.4.5 cadence and are explicitly marked as historical in `docs/VALIDATION.md`.
