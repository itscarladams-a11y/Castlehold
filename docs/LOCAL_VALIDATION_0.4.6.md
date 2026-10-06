# Castlehold 0.4.6 local validation

The final static/debug pass completed **579 checks with 0 failures** in this artifact workspace.

Coverage includes:
- release/version metadata and the 20/40/60/80/100 boss cadence
- anti-flash shadow, contact-shadow, VFX, boss-warning and flame-shader anchors
- 64 source-side `res://` references
- 20 JSON/glTF files, including linked buffers and textures
- 21 WAV files plus bundled OGG header validation
- 18 Python authoring/build tools
- GitHub Actions YAML and every embedded shell block
- source-file conflict-marker, zero-byte and basic GDScript delimiter checks

## Engine/runtime limitation

The local artifact workspace does not include a runnable Godot 4.7.2 editor or Android SDK. The included GitHub Actions workflow therefore remains the authoritative parser/import/runtime-test/Android-export check. Physical Android play is still required to determine whether the device-specific intermittent flash has been eliminated.
