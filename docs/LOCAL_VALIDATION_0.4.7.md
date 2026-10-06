# Castlehold 0.4.7 local validation

The Gravecaller / 120-wave finale source was checked before packaging.

- 738 static/source checks passed with zero failures before archive packaging.
- 22 JSON/glTF files parse, including the new Gravecaller and Raised Ogre Skeleton models.
- External glTF buffers and texture references resolve and buffer byte lengths match.
- The Raised Ogre Skeleton retains the 24-bone combat rig and 11 required ordinary-unit animations.
- The Gravecaller retains the 24-bone combat rig and all 12 boss animations, including `special`.
- 22 WAV files decode, including the new 3.05-second necromancy ritual cue.
- Literal `res://` references and `.tres`/`.tscn` external resource paths resolve.
- GitHub Actions YAML parses and each embedded shell block passes `bash -n`.
- Wave count, 20-wave boss cadence, wave-120 boss mapping, enemy cap, save migration and mid-rise skeleton checkpoint state are checked in source.
- Python authoring tools parse successfully.
- Image and SVG assets pass format checks.

The current workspace does not include a runnable Godot 4.7.2 editor or Android SDK, so the local pass does not claim a live Godot import or APK export. The repository workflow performs the authoritative Godot import, regression tests, continuous-siege/endurance tests and Android export after push.
