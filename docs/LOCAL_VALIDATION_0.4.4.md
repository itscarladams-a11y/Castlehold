# Castlehold 0.4.4 — final local validation

Final GitHub-ready package validation performed on the Castle Overhaul source.

## Passed checks

- **236 static/package checks, 0 failures.**
- GitHub Actions workflow YAML parses and includes pinned Godot 4.7.2 import, gameplay tests, Android export and artifact upload.
- `project.godot` main scene resolves.
- Android export metadata is version code **13**, version name `0.4.4-castle-overhaul`, arm64 enabled, package ID unchanged.
- **64 source-side `res://` references** resolve with no missing files.
- **20 JSON/glTF files** parse; external glTF buffers and images resolve.
- **21 WAV files** decode and contain frames; bundled OGG music has a valid Ogg header.
- All 18 Python authoring/build tools compile with Python.
- No zero-byte source/config files or merge-conflict markers were found.
- Castle-overhaul anchors are present and the destructible timber gate / portcullis pieces remain in the source.
- The update ZIP was applied to a clean 0.4.3 fresh install and its resulting file tree matched the 0.4.4 fresh install **exactly: 0 missing, 0 extra, 0 different files**.
- Both final ZIP archives pass ZIP integrity testing.

## Engine/runtime limitation

This artifact workspace does not contain a runnable Godot 4.7.2 editor or Android SDK, so these local checks do **not** claim a live Godot parser/import, headless gameplay-test run, or APK export. The included GitHub Actions workflow is the authoritative engine/import/test/export gate after the source is pushed.
