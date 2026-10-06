extends SceneTree
## Battle-speed control: UI cycling, save/restore, pause safety, and reset hygiene.
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
	if ok:print("PASS: "+label)
	else:push_error("FAIL: "+label);failures+=1
func run():
	Engine.time_scale=1.0
	var game=load("res://scenes/battle/battle.tscn").instantiate();root.add_child(game)
	await process_frame;await process_frame
	check(is_equal_approx(game.battle_speed,1.0) and is_equal_approx(Engine.time_scale,1.0),"battle starts at normal speed")
	check(game.hud.speed_button.text=="1×" and not game.hud.speed_button.disabled,"the landscape HUD exposes a live speed control")
	game.cycle_battle_speed()
	check(is_equal_approx(game.battle_speed,2.0) and is_equal_approx(Engine.time_scale,2.0) and game.hud.speed_button.text=="2×","first tap selects 2× battle speed")
	game.set_paused(true);game.cycle_battle_speed()
	check(paused and is_equal_approx(game.battle_speed,3.0) and game.hud.speed_button.text=="3×","speed can be changed safely while planning in Pause")
	game.cycle_battle_speed()
	check(paused and is_equal_approx(game.battle_speed,4.0) and game.hud.speed_button.text=="4×","a second paused tap exposes the new 4× speed")
	var state:Dictionary=game.snapshot()
	check(SaveManager.valid(state),"checkpoints containing 4× battle speed remain valid saves")
	game.set_battle_speed(1.0);game.restore(state)
	check(is_equal_approx(game.battle_speed,4.0) and is_equal_approx(Engine.time_scale,4.0),"checkpoint restore keeps the chosen 4× battle speed")
	game.set_paused(false);game.cycle_battle_speed()
	check(is_equal_approx(game.battle_speed,1.0),"speed cycles from 4× back to 1×")
	game.set_battle_speed(9.0)
	check(is_equal_approx(game.battle_speed,1.0),"unsupported speed values fail safe to 1×")
	game.queue_free();await process_frame
	check(is_equal_approx(Engine.time_scale,1.0),"leaving Castlehold resets the global engine speed")
	paused=false
	print("BATTLE SPEED COMPLETE failures=",failures);quit(failures)
