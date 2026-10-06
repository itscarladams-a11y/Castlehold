# Castlehold 0.4.9 — Impact & Atmosphere

This is the first dedicated pass aimed at closing the gap between a complete functional game and a commercial 2026 mobile presentation. It deliberately targets feedback and scene readability rather than changing balance.

## Combat feel
- Body, metal and bone targets select different impact VFX palettes and different synthesized audio pools.
- Heavy blows use a dedicated low-end impact family and restrained distance-aware camera trauma.
- Camera trauma decays in real time, independent of 1×–4× battle speed.
- Sparse pooled footsteps give cavalry, ogres and melee formations more weight without allowing audio-node growth.
- Idle animation phases are randomized, model scale varies by roughly ±1.5%, attack/hit blends are faster, and living targets briefly squash/recover on impact.

## VFX budget
- The fixed combat VFX pool increases from 96 to 112 nodes.
- Sixteen new opaque streak pieces add readable weapon/armor impact direction without transparency sorting risk.
- Dust still initializes at zero alpha and all scenery remains outside dynamic shadow casting, preserving the anti-flash work from 0.4.6.

## Environment
- Two broken siege carts, two abandoned stake lines and four rock clusters now frame the battle lane.
- These props are static, shadow-disabled and positioned outside unit movement lanes.

## Gameplay scope
No campaign balance, boss cadence, save contract, Gravecaller finale logic, victory condition or 1×–4× speed behavior is intentionally changed in this pass.
