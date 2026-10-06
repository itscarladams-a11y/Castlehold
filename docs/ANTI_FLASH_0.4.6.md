# Castlehold 0.4.6 — Android anti-flash pass

This pass addresses the remaining intermittent brightness/flicker report without changing combat. The exact device-specific flash has not been reproduced inside this workspace, so the changes target several plausible mobile-rendering causes at once.

## Changes
- ValleySun uses `SHADOW_ORTHOGONAL` instead of two parallel shadow splits.
- Dynamic shadow distance is reduced from 75 to 52; split blending is disabled; fade start is 1.0; shadow pancake size is reduced to 10.
- Ground, distant ridges, trees, bushes and grass no longer cast dynamic shadows. Characters and the fortress retain their useful shadows.
- Contact-shadow planes move from 0.018 m to 0.045 m above the terrain and use alpha depth-prepass transparency.
- Dust/spark opacity is reduced slightly and recycled particles reset their material before becoming visible.
- Boss warning rings are translucent and sit slightly farther above the ground.
- The ember/fire shader requests an alpha depth prepass to make overlapping flame shells more stable.

## Verification
`tests/anti_flash.gd` checks the shadow mode/range, contact-shadow separation, VFX initialization, warning transparency and fire shader mode. Physical Android play remains the final verification step.
