# Castlehold 0.5.1 local validation

- PASS: deterministic battlefield dressing names are present in `world_builder.gd`.
- PASS: premium-combat regression checks two carts, two stake lines and four rock clusters by prefix.
- PASS: authored dressing coordinates all sit outside |Z| < 5.5 combat-lane threshold.
- PASS: Android export version code is 20 and version name is `0.5.1-dressing-test-hotfix`.
- PASS: source-side resource references, JSON/glTF parsing, audio decoding, workflow YAML and package integrity were rechecked locally.

The authoritative Godot 4.7.2 parser/test/export run remains GitHub Actions.
