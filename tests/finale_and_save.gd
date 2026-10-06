extends SceneTree
## Final Gravecaller victory contract, 4x control and manual save/continue behavior.
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
	if ok:print("PASS: "+label)
	else:push_error("FAIL: "+label);failures+=1
func run():
	Engine.time_scale=1.0
	for suffix in ["", ".bak", ".tmp"]:
		var path:=SaveManager.save_path()+suffix
		if FileAccess.file_exists(path):DirAccess.remove_absolute(path)
	var game=load("res://scenes/battle/battle.tscn").instantiate();root.add_child(game)
	await process_frame;await process_frame
	game.set_physics_process(false);game.projectiles.set_process(false)
	game.set_battle_speed(4.0)
	check(is_equal_approx(game.battle_speed,4.0) and is_equal_approx(Engine.time_scale,4.0),"battle-speed ladder accepts 4x")
	game.set_battle_speed(1.0)
	check(is_instance_valid(game.hud.save_button) and game.hud.save_button.text=="Save","HUD exposes manual save-for-later control")
	check(game.audio.sounds.has("victory_fanfare") and is_instance_valid(game.audio.victory_player) and game.audio.victory_player.stream!=null,"dedicated triumphant fanfare is loaded on its own player")

	# The Gravecaller alone dying is not victory. His remaining force is part of the final boss encounter.
	game.clear_army();game.director.wave=120;game.phase="final";game.director.pending.clear();game.set_paused(false)
	var boss:UnitController=game.spawn("boss_necromancer",true,Vector3(8,0,0),120);boss.set_physics_process(false)
	var skeleton:UnitController=game.spawn("ogre_skeleton",true,Vector3(10,0,1),120);skeleton.set_physics_process(false)
	boss.take_damage(1000000)
	game._physics_process(.02)
	check(game.phase=="final" and game.hud.message.text=="GRAVECALLER FALLS","killing the necromancer alone does not prematurely award victory")
	game.hud.refresh()
	check(game.hud.boss_panel.visible and game.hud.boss_title.text.contains("GRAVECALLER'S LEGION"),"final-boss HUD persists for the necromancer's surviving legion")
	skeleton.take_damage(1000000);game._physics_process(.02)
	check(game.phase=="complete" and game.hud.message.text=="VICTORY","victory triggers only after the final Gravecaller force is cleared")

	# Manual save freezes the fight and preserves a current-state continuation with 4x selected.
	game.new_siege();game.set_physics_process(false);game.director.start_wave();game.set_battle_speed(4.0)
	var raider:UnitController=game.spawn("raider",true,Vector3(13,0,1.25),game.wave);raider.set_physics_process(false);raider.hp=raider.max_hp*.43
	var retry_wave_before:int=int(game.checkpoint.director.wave)
	var ok:=game.save_progress(true)
	check(ok and paused and game.hud.message.text=="PROGRESS SAVED","manual save pauses the battle and confirms persistence")
	var saved:=SaveManager.read_state()
	check(not saved.is_empty() and SaveManager.valid(saved) and is_equal_approx(float(saved.battle_speed),4.0),"manual continuation save validates with 4x speed")
	check(int(saved.director.wave)==game.wave and int(game.checkpoint.director.wave)==retry_wave_before,"manual save preserves current wave without replacing the in-session Retry Wave checkpoint")
	var found:=false
	for entry in saved.units:
		if entry.id=="raider" and absf(float(entry.hp)-raider.hp)<.01 and absf(float(entry.position[2])-1.25)<.01:found=true
	check(found,"manual continuation stores living enemy health and position")
	game.set_battle_speed(1.0);game.restore(saved);game.set_paused(true)
	check(is_equal_approx(game.battle_speed,4.0) and paused,"saved progress restores at 4x selection while remaining paused for the player")

	game.audio.stop_all();game.queue_free();await process_frame
	for suffix in ["", ".bak", ".tmp"]:
		var path:=SaveManager.save_path()+suffix
		if FileAccess.file_exists(path):DirAccess.remove_absolute(path)
	paused=false;Engine.time_scale=1.0
	print("FINALE AND SAVE COMPLETE failures=",failures);quit(failures)
