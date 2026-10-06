extends SceneTree
## Wave-120 Gravecaller event, raised-ogre presentation, capacity and save migration.
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
	if ok:print("PASS: "+label)
	else:push_error("FAIL: "+label);failures+=1
func run():
	var game=load("res://scenes/battle/battle.tscn").instantiate();root.add_child(game)
	await process_frame;game.set_physics_process(false);game.projectiles.set_process(false);game.audio.muted=true
	for unit in game.units:unit.set_physics_process(false)
	check(int(game.balance.wave_count)==120 and game.balance.boss_waves["120"]=="boss_necromancer","campaign extends through the authored wave-120 boss")
	var composition:=WaveDirector.composition(120,game.balance)
	check(composition[0].id=="boss_necromancer" and composition.size()>20,"the Gravecaller supplements a full final assault rather than replacing it")
	game.clear_army();await process_frame
	var boss:UnitController=game.spawn("boss_necromancer",true,Vector3(14,0,0),120);boss.set_physics_process(false)
	boss.boss_combat.cooldown=0
	boss._physics_process(.1)
	check(boss.position.x<14 and boss.boss_combat.windup<0,"the giant necromancer walks into the visible field before beginning the ritual")
	boss.position=Vector3(9,0,0);boss.boss_combat.cooldown=0;boss._physics_process(.01)
	check(boss.boss_combat.windup>2 and boss.anim=="special","Raise the Dead uses the boss special animation and a long readable windup")
	boss._physics_process(2.36)
	var raised:=0
	for unit in game.units:
		unit.set_physics_process(false)
		if unit.data.id=="ogre_skeleton":raised+=1
	check(raised==12,"one Gravecaller ritual raises a dozen ogre skeletons")
	var sample:UnitController
	for unit in game.units:
		if unit.data.id=="ogre_skeleton":sample=unit;break
	var start_y:=sample.position.y;sample._physics_process(.45)
	check(start_y<-.9 and sample.position.y>start_y and sample.scale.x>.22,"raised skeletons physically emerge from below the ground before fighting")
	# Capacity protection: direct raising never pushes active enemies beyond the same 84-unit mobile budget.
	while game.enemy_count()<82:
		var filler:=game.spawn("raider",true,Vector3(18,0,float(game.enemy_count()%7)-3),120);filler.set_physics_process(false)
	var added:=game.raise_undead("ogre_skeleton",Vector3(9,0,0),120,12)
	check(added==2 and game.enemy_count()==84,"necromancy respects the fixed 84-enemy mobile performance ceiling")
	# A pre-extension completed wave-100 save remains accepted and resumes at wave 101 planning gap.
	game.new_siege();game.set_physics_process(false)
	for unit in game.units:unit.set_physics_process(false)
	var legacy:=game.snapshot();legacy.director.wave=100;legacy.director.phase="complete";legacy.director.pending=[]
	check(SaveManager.valid(legacy),"completed 0.4.6 wave-100 checkpoints remain recognized")
	game.restore(legacy)
	check(game.director.wave==100 and game.phase=="gap" and game.live_play(),"an old 100-wave victory migrates into the new wave-101 continuation gap")
	game.phase="tests_complete";game.audio.stop_all();await create_timer(.2,true).timeout
	game.queue_free();await process_frame
	print("NECROMANCER COMPLETE failures=",failures);quit(failures)
