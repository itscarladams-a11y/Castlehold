# Castlehold 0.4.8 local validation

This package is checked source-side for the new final-victory, 4× and manual-save changes. The GitHub workflow additionally runs `tests/finale_and_save.gd` under Godot 4.7.2.

Key regression targets:
- Gravecaller death alone does not award victory.
- The final-legion HUD persists until the remaining force is cleared.
- VICTORY is the terminal message and a dedicated fanfare asset/player is available.
- 4× is part of the speed cycle and accepted by the save validator.
- Manual Save pauses, writes the current continuation and leaves the in-session Retry Wave anchor unchanged.
- Saved 4× state restores without falling back to 1×.
