# Castlehold 0.4.3 local validation

Checks performed in the current artifact workspace:

- PASS: ZIP extracted cleanly
- PASS: patched fortress architecture script present
- PASS: README/FRESH_INSTALL/ANDROID_BUILD/GDD version text updated to 0.4.3
- PASS: Android export version code updated to 12
- PASS: 64 source-side res:// references still resolve (excluding imported .godot artifacts)
- PASS: 20 JSON/glTF files parse
- PASS: 21 WAV files decode

## Engine/runtime limitation

The current artifact workspace does not include a runnable Godot 4.7.2 editor or Android SDK, and external binary download is unavailable from the container. Therefore this local pass does not claim a Godot parser/import run or APK export. The included GitHub Actions workflow remains the authoritative import, test and Android export check after the source is pushed.
