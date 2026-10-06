# Castlehold 0.5.1 — GitHub test hotfix

GitHub Actions reached `tests/premium_combat.gd` and failed only the battlefield-side-dressing assertion. The scenery was present, but the regression test counted repeated exact node names. Godot automatically renames duplicate sibling nodes, so later carts, stake lines and rock clusters no longer retained the same exact name.

## Fix
- The two broken carts, two abandoned-stake lines and four rock clusters now receive deterministic unique node names.
- `tests/premium_combat.gd` collects those deterministic prefixes.
- The regression now verifies both object counts and that every dressing root is at least 5.5 world units from the lane center on Z.

No gameplay, balance, save, branding, boss, audio or combat behavior changed.
