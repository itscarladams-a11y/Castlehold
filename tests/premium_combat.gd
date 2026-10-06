extends SceneTree
## Castlehold 0.5.1 premium combat/presentation regression checks.
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
	if ok:print("PASS: "+label)
	else:push_error("FAIL: "+label);failures+=1
func collect_prefix(node: Node,prefix: String,out: Array[Node]):
	if String(node.name).begins_with(prefix):out.append(node)
	for child in node.get_children():collect_prefix(child,prefix,out)
func run():
	var game=load("res://scenes/battle/battle.tscn").instantiate();root.add_child(game)
	await process_frame;await process_frame;game.set_physics_process(false);game.audio.muted=true
	check(game.audio.impact_groups.has("metal") and game.audio.impact_groups["metal"].size()==3,"metal impacts have three authored variants")
	check(game.audio.impact_groups.has("body") and game.audio.impact_groups["body"].size()==3,"body impacts have three authored variants")
	check(game.audio.impact_groups.has("bone") and game.audio.impact_groups["bone"].size()==3,"bone impacts have three authored variants")
	check(game.audio.impact_groups.has("heavy") and game.audio.impact_groups["heavy"].size()==2,"heavy impacts have dedicated low-end variants")
	var streaks:=0
	for slot in game.vfx.slots:
		if slot.kind=="streak":streaks+=1
	check(game.vfx.slots.size()==112 and streaks==16,"fixed VFX pool adds sixteen opaque impact streaks without runtime growth")
	var metal:UnitController=game.spawn("orc_guard",true,Vector3(8,0,0),40);metal.set_physics_process(false)
	var bone:UnitController=game.spawn("ogre_skeleton",true,Vector3(10,0,0),120);bone.set_physics_process(false)
	var body:UnitController=game.spawn("raider",true,Vector3(12,0,0),10);body.set_physics_process(false)
	check(metal.impact_profile()=="metal" and bone.impact_profile()=="bone" and body.impact_profile()=="body","impact material profiles distinguish armor, bone and body hits")
	game.camera.trauma=0
	metal.take_damage(metal.max_hp*.25,false,"heavy")
	check(game.camera.trauma>0,"heavy melee feedback drives restrained camera trauma")
	var active_streak:=false
	for slot in game.vfx.slots:
		if slot.kind=="streak" and slot.life>0:active_streak=true
	check(active_streak,"heavy hit activates pooled streak geometry")
	var carts:Array[Node]=[];var stakes:Array[Node]=[];var rocks:Array[Node]=[]
	collect_prefix(game,"BrokenSiegeCart_",carts);collect_prefix(game,"AbandonedStakes_",stakes);collect_prefix(game,"BattlefieldRockCluster_",rocks)
	var dressing_outside_lane:=true
	for group in [carts,stakes,rocks]:
		for node in group:
			if absf(node.global_position.z)<5.5:dressing_outside_lane=false
	check(carts.size()>=2 and stakes.size()>=2 and rocks.size()>=4 and dressing_outside_lane,"battlefield side dressing is present outside the combat lane")
	check(is_instance_valid(game.units[0].animator) and game.units[0].visual_base_scale.length()>0,"troops retain animated presentation state and per-unit silhouette scale")
	game.audio.stop_all();game.queue_free();await process_frame
	print("PREMIUM COMBAT COMPLETE failures=",failures);quit(failures)
