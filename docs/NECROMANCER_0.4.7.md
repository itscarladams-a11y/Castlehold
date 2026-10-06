# Castlehold 0.4.7 — Gravecaller finale

## Campaign extension

The continuous siege is extended from 100 to **120 waves**. The earlier milestone bosses remain at waves 20, 40, 60, 80 and 100. Wave 120 adds a sixth encounter: **The Gravecaller**, a giant ogre necromancer.

## The Gravecaller

The Gravecaller is a new authored skinned ogre-mage model rather than a scaled copy at runtime. He uses oversized necromancer regalia, a bone crown and skull-focused staff. He advances to a visible firing line before his first ritual.

His special is **RAISE THE DEAD**. The ritual has a long telegraph and green warning ring. It can trigger at full health and again at approximately 76%, 51% and 26% health. Each completed ritual attempts to raise **12 Raised Ogre Skeletons** from the ground in rings around him. The existing 84-enemy performance cap limits the number actually created if the battlefield is already saturated.

## Raised Ogre Skeleton

The new enemy has its own procedural 3D asset built on the ogre skeleton/animation rig. Visible geometry includes an ogre skull, eye sockets, jaws and teeth, ribs, sternum, pelvis, heavy limb bones, scraps of armor, tattered burial cloth and a crude bone-and-iron weapon. It uses the normal walk, attack, hit and defeat animation system. A short emergence state brings each raised ogre upward from beneath the terrain before normal combat begins.

## Presentation

The ritual uses a sickly green variation of the staff flame, green pooled ritual sparks/dust and an original synthesized `necromancy.wav` cue with low drone, air pull and bone-clatter elements. No external audio or model assets are used.

## Save compatibility

The checkpoint schema remains version two. Wave and source-wave validation now extends to 120. A completed wave-100 save from 0.4.6 remains valid and is migrated into a planning gap before wave 101 so the new twenty-wave extension can be played without restarting the campaign.
