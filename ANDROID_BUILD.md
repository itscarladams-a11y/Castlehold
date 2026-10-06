# Android build

Current game: **0.5.0 Stone & Steel**, version code 19. `Castlehold-Fresh-Install.zip` contains the entire source tree and assets for a new repository. Use **FRESH_INSTALL.md** or the command block in README.md. Run `git pull --ff-only` before extraction so Codespaces receives the uploaded ZIP.

Engine pinned: Godot 4.7.2 stable, standard GDScript edition. Android preset: arm64, landscape, immersive, offline, debug package `com.castlehold.firststand`. No C# or Gradle plugin is required for the supplied APK preset.

The download hotfix forces HTTP/1.1 for both the editor and template archives. It retries all transfer errors up to five times, with three seconds between retries and a 30-second connection timeout. This addresses the reported curl exit 92 (cancelled HTTP/2 stream) before the game tests ran. HTTPS certificate verification and pinned engine URLs remain enabled. A cancelled or truncated download is restarted into the regular output file; extraction only runs after curl succeeds. The 35-minute job timeout bounds the overall build.

If a workflow run is named **Add files via upload**, it may be the run triggered by uploading the ZIP alone. Extract the ZIP in Codespaces, commit the source changes, and use the subsequent source commit's run to build the update.

## Fresh repository from a phone

1. Create a new GitHub repository, for example `Castlehold-Fresh`, with a README and the `main` branch.
2. Upload `Castlehold-Fresh-Install.zip` to its root and open its Codespace.
3. Paste the command block from FRESH_INSTALL.md. It pulls the upload, extracts the full project, commits the source and pushes it.
4. In Actions, select **Build Castlehold Android → Install complete Castlehold game**.
5. After success, download `Castlehold-Android-debug`, extract it and install `Castlehold-debug.apk`.

The complete source ZIP has no wrapper folder and needs no previous game files. Uploading the ZIP alone leaves its files archived; the source commit installs and triggers the workflow.

Earlier builds were installed by the user. This 0.5.0 package has passed local archive/static/resource checks in the current workspace; the included GitHub Actions run is the authoritative Godot 4.7.2 import/parser/test/export check, and Android installation still needs device confirmation. A debug APK is for testing, not a Play Store release. Its signing key is regenerated on each CI run; updates from different runs may require uninstall/reinstall, which removes local progress. Before repeated distribution, store one persistent private debug key in GitHub Actions secrets and load it in the workflow. Never commit a release key.

## Local export
Install Godot's matching export templates, OpenJDK 17 and Android SDK. Configure Editor Settings → Export → Android with SDK and Java paths. The included workflow pins platform 35 and build-tools 35.0.1; verify these requirements against the engine when changing versions. For non-Gradle APK export, the prebuilt templates supply native code. Custom native/Gradle builds require the additional NDK/CMake dependencies described by Godot.

Run `godot --headless --path project --editor --import`, then `godot --headless --path project --export-debug Android ../build/Castlehold-debug.apk` with a configured debug keystore. `tools/configure_android.py` sets SDK paths in Linux CI after the editor has created its settings file. It is not needed when you set paths through the editor.

## Required device verification
Test one midrange arm64 phone with Vulkan and at least one wide/notched display. Check launch, safe areas, taps, sound, suspend/resume, process-kill recovery, victory, gate breach, retry, and frame-time spikes. Target 60 fps with 30 fps fallback remains a target, not a measured claim. For compatibility testing launch the project with `--rendering-method gl_compatibility`; an in-game renderer selector is not yet implemented.

Reference: [Godot Android export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)

## Graphics update 0.2.1

Android version code is 5; package ID and save format are unchanged. All new maps are included as Resources with ETC2/ASTC import enabled. CI also runs `tests/graphics.gd` to check material imports and paused effects. Install the APK from the run for the applied graphics-source commit, not the earlier ZIP-upload commit. Debug signing behavior remains as documented above.

## Music update 0.2.2

Android version code is 6. The same package ID and campaign save format are retained. The soundtrack is a bundled stereo Ogg Vorbis resource; playback works offline and does not request a network permission. A separate versioned preferences file stores music/effects levels and mute. CI includes `tests/audio_settings.gd`. Check speaker balance at the 35% default, slider response, hardware volume interaction, and Home/return behavior on a physical phone. Download the APK from the run for the applied music-source commit.

## Horde update 0.3.0

Version code is 7; package ID, version 2 checkpoints and audio preferences remain compatible. Six original enemy models are included as glTF 2.0 assets. CI now checks horde mechanics, pooled-dust initialization, animated mesh bounds, old reinforcement snapshots and contrasting recruitment policies. The source ZIP is cumulative and contains paths relative to the repository root, without a wrapper folder.

No 0.3.0 APK was exported locally. Download the artifact from the successful run for the commit that extracts this update. Check the reported flashing during dense battles and finger scouting on the same phone; also inspect the orc silhouettes, ogre attack timing and late-wave pressure.

## Previous Tusk & Ember update 0.3.1

Version code 8 retains the package ID, version 2 checkpoints and audio preferences. Two new glTF enemies, a bone-attached staff effect, 16-slot fireball pool and two synthesized sound effects are included. CI runs `tests/ogre_elites.gd` for animation contact, flight/impact, pause, splash, charge counters and restore.

The APK must still be built by Actions and reviewed on a phone. Inspect shamans at wave 18 and warthog riders at wave 25, including the visible staff-tip launch, readable flame size, hooves/tusks, charge timing, pause and dense fights. Check both effects at your preferred sound level. Download the successful artifact for the commit that extracts the source update, rather than the ZIP-upload commit. Signing behavior and possible uninstall/save loss remain as described above.

The Siege Bosses source includes the HTTP/1.1 retry fix for interrupted engine/template downloads. Its CI also runs the boss attack, pause, save, reinforcement and final-victory checks before APK export.

## Stone & Steel 0.4.2 — Speed & Voices

Version code 11 retains the package ID, version 2 campaign checkpoints and separate audio preferences. The existing nine short mono 24 kHz defeat clips now use a fixed four-player voice pool on the Effects bus with louder per-character gain and speed-aware anti-spam timing. The top HUD cycles 1× / 2× / 3× using Godot engine time scaling so combat systems remain synchronized. CI includes both `tests/defeat_voices.gd` and `tests/battle_speed.gd`. Test device speaker clarity, crowd overlap, speed changes, pause/resume and background behavior. No local Android APK was exported in this workspace.


## Stone & Steel 0.4.4 — Castle overhaul

Version code 13 keeps the same Android package ID and save data shape but upgrades the fortress asset with a more dramatic silhouette: taller gatehouse crown, larger flanking towers, a taller keep, twin roof turrets, a stronger watchtower and heavier buttressing. Speed control, louder defeat voices and gameplay systems remain as in 0.4.3.

## Stone & Steel 0.4.3 — Castle polish

Version code 12 retains the package ID, version 2 campaign checkpoints and separate audio preferences. This art pass improves the fortress silhouette and front-facing detail with under-parapet machicolations, a heavier gatehouse crown, keep corner quoins, added buttresses, roof dormer, chimneys and small tower accents. Battle speed, audio behavior and balance remain as in 0.4.2. No local Android APK was exported in this workspace.

## Stone & Steel 0.4.5 — Boss cadence

Version code 14 keeps the same package ID and version-two checkpoint format. Boss encounters now occur at waves 20, 40, 60, 80 and 100. The wave-80 Stone-Eye Warlord is a stronger cyclops variant that reuses the authored Gatebreaker boss rig and special-animation set. Ironjaw remains the final boss at wave 100. Existing saves remain compatible; already-passed milestones are not replayed.


## Stone & Steel 0.5.0 — Bantam Entertainment branding

Castlehold now starts on the approved Bantam Entertainment studio splash. The transparent no-domain studio mark is shown over solid black, and the red/gold progress bar is driven by Godot `ResourceLoader` threaded scene-loading progress. The logo is also configured as the engine boot splash to prevent an unbranded startup frame. Gameplay remains based on the 0.4.9 Impact & Atmosphere build.

## Stone & Steel 0.4.9 — Impact & Atmosphere

The first premium-production pass keeps the 120-wave campaign and 0.4.8 controls while upgrading combat presentation: body/metal/bone impact families, heavy-hit audio, sparse footsteps, pooled impact streaks, restrained camera trauma, per-unit idle/scale variation, hit squash and additional static battlefield dressing. CI adds `tests/premium_combat.gd`.

## Stone & Steel 0.4.8 — Final victory, 4× and Save for Later

Version code 17 keeps the package ID and version-two save format. Wave 120 is treated as one final Gravecaller encounter: killing the necromancer does not finish the campaign while any attackers remain. The HUD keeps a final-legion panel active until the field is clear, then displays VICTORY and plays a dedicated synthesized fanfare. Battle speed now includes 4×. A manual Save control pauses and writes the live campaign state for later continuation, while preserving the in-session Retry Wave checkpoint; Android backgrounding also attempts a current-state save. CI adds `tests/finale_and_save.gd`.

## Stone & Steel 0.4.7 — Gravecaller / 120-wave finale

Version code 16 extends the continuous siege to 120 waves. The existing 20-wave boss cadence continues through wave 100, and wave 120 adds The Gravecaller, a new giant ogre necromancer with an authored mage model, a four-phase Raise the Dead ritual and a new articulated Raised Ogre Skeleton enemy. Each ritual attempts to raise 12 skeleton ogres around the boss while respecting the existing 84-enemy mobile cap. An original necromancy cue and green ritual VFX are included. Completed version-two wave-100 victory saves are accepted and migrated to the planning gap before wave 101.

## Stone & Steel 0.4.6 — Android anti-flash pass

Version code 15 keeps the same package ID and version-two save format. ValleySun now uses one orthogonal shadow map with a 52-unit range, no split blending, a 10-unit pancake and fade start at 1.0. Distant decorative scenery no longer casts dynamic shadows. Contact shadows use alpha depth pre-pass and sit farther above the terrain. Boss warnings are translucent, pooled dust/sparks are slightly dimmer, recycled VFX reset before visibility, and the ember shader requests an alpha depth pre-pass. CI includes `tests/anti_flash.gd`. Device testing remains required because the reported brightness flash is Android/GPU-specific.
