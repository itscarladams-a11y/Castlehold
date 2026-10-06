extends SceneTree
## Rendering-stability regression checks for the Android anti-flash pass.
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
	if ok:print("PASS: "+label)
	else:push_error("FAIL: "+label);failures+=1
func run():
	var game=load("res://scenes/battle/battle.tscn").instantiate();root.add_child(game)
	await process_frame;await process_frame;game.set_physics_process(false);game.audio.muted=true
	var sun:DirectionalLight3D=game.get_node_or_null("ValleySun")
	check(is_instance_valid(sun),"battlefield has the stabilized ValleySun")
	if sun:
		check(sun.directional_shadow_mode==DirectionalLight3D.SHADOW_ORTHOGONAL,"sun uses one orthogonal shadow map instead of split cascades")
		check(not sun.directional_shadow_blend_splits and sun.directional_shadow_max_distance<=52.01,"split blending is disabled and shadow range is bounded")
		check(is_equal_approx(sun.directional_shadow_fade_start,1.0) and sun.directional_shadow_pancake_size<=10.01,"shadow fade and pancake settings avoid moving transition bands")
	var contact:ContactShadow=game.units[0].contact_shadow
	check(contact.position.y>=.04,"contact shadows sit clear of the ground depth plane")
	var contact_mat:StandardMaterial3D=contact.material_override
	check(contact_mat.transparency==BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS,"contact shadows use depth-prepass transparency")
	game.vfx.burst(Vector3.ZERO,true)
	var dust_stable:=true
	for slot in game.vfx.slots:
		if slot.kind=="dust" and slot.life>0:dust_stable=dust_stable and slot.node.visible and slot.mat.albedo_color.a==0.0
	check(dust_stable,"recycled dust is reset transparent before it becomes visible")
	var boss:UnitController=game.spawn("boss_gatebreaker",true,Vector3(18,0,0),20);boss.set_physics_process(false)
	var warning:StandardMaterial3D=boss.boss_combat.material
	check(warning.transparency==BaseMaterial3D.TRANSPARENCY_ALPHA and warning.albedo_color.a<.5,"boss warning ring is translucent instead of a full-opacity brightness pop")
	check(boss.boss_combat.ring.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"boss warning geometry never enters the shadow pass")
	var shader_text:=FileAccess.get_file_as_string("res://assets/materials/ember_fire.gdshader")
	check(shader_text.contains("depth_prepass_alpha"),"overlapping flame shells request an alpha depth prepass")
	game.audio.stop_all();game.queue_free();await process_frame
	print("ANTI FLASH COMPLETE failures=",failures);quit(failures)
