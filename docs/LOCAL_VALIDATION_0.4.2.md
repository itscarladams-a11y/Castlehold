# Castlehold 0.4.2 local validation

Checks performed in the current artifact workspace:

- PASS: GitHub Actions YAML parses
- PASS: 20 JSON/glTF files parse
- PASS: 33 direct res:// references resolve
- PASS: no zero-byte files, conflict markers, or unbalanced line quotes
- PASS: 21 WAV files decode; max individual peak 0.730
- PASS: patch: 1x/2x/3x speeds
- PASS: patch: 4 voice players
- PASS: patch: CI speed test
- PASS: patch: version code 11

## Engine/runtime limitation

The current artifact workspace does not include a runnable Godot 4.7.2 editor or Android SDK, and external binary download is unavailable from the container. Therefore this local pass does not claim a Godot parser/import run or APK export. The included GitHub Actions workflow performs the authoritative pinned Godot 4.7.2 import, gameplay tests (including `battle_speed.gd` and `defeat_voices.gd`) and Android export after the source is pushed.
