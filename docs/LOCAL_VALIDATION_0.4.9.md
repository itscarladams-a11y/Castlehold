# Castlehold 0.4.9 local validation

The Impact & Atmosphere source pass was checked in the current artifact workspace before packaging. The final static/resource/workflow pass completed **1,212 checks with 0 failures**.

## Passed local checks

- Source-side `res://` resource references resolve, including the new combat-impact audio families.
- All JSON/glTF files parse and linked glTF buffers/images exist.
- All WAV files decode; the 13 new combat/footstep clips are mono 16-bit 22.05 kHz and regenerate deterministically from `tools/build_combat_audio.py`.
- The bundled OGG has a valid OggS header.
- Python authoring tools compile.
- GitHub Actions YAML parses and every Bash workflow block passes shell syntax checking.
- Version metadata, 120-wave finale, 4× speed, Save/Continue, anti-flash safeguards, fixed VFX budgets, new premium-combat test, material-aware impacts, camera trauma, presentation variation and battlefield-side dressing are all present in source.
- No zero-byte project files, merge-conflict markers, NUL bytes, packaged `__pycache__` directories or `.pyc` files are permitted in the final archive.

## Engine/runtime limitation

A runnable Godot 4.7.2 editor and Android SDK are not installed in this local artifact workspace. Therefore this pass does **not** claim a live Godot parser/import, headless gameplay run or APK export here. The included GitHub Actions workflow remains the authoritative Godot 4.7.2 import, regression-test and Android-export check after push.
