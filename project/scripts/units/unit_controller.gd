class_name UnitController
extends Node3D
signal died(unit)
var data: UnitData
var enemy := false
var hp: float
var max_hp: float
var damage_scale := 1.0
var attack_multiplier := 1.0
var source_wave := 1
var home: Vector3
var battle: Node3D
var target: Node3D
var cooldown := 0.0
var windup := -1.0
var lock_timer := 0.0
var animator: AnimationPlayer
var visual: Node3D
var visual_base_scale := Vector3.ONE
var recoil_tween: Tween
var active := false
var anim := ""
var attack_index := 0
var attack_duration := .95
var slot_index := -1
var charge_distance := 0.0
var charge_cooldown := 0.0
var shaman_focus: ShamanFocus
var contact_shadow: ContactShadow
var boss_combat: BossCombat
var raise_remaining := 0.0
var step_meter := 0.0
const RAISE_DURATION := 0.90
func setup(definition: UnitData, hostile: bool, game: Node3D, at: Vector3, origin_wave: int=1):
	data=definition;enemy=hostile;battle=game;source_wave=origin_wave
	max_hp=data.hp*(1.0+maxi(0,source_wave-10)*float(game.balance.hp_growth) if enemy else 1.0);hp=max_hp
	damage_scale=1.0+maxi(0,source_wave-10)*float(game.balance.damage_growth) if enemy else 1.0
	if data.boss:max_hp=data.hp;hp=max_hp;damage_scale=1.0
	attack_multiplier=float(game.balance.get("attacker_damage_multiplier",1.0)) if enemy else 1.0
	damage_scale*=attack_multiplier
	position=at;home=at;visual=data.model.instantiate();add_child(visual)
	CharacterPresentation.apply(visual);visual.rotation.y=PI/2 if enemy else -PI/2
	var silhouette_variation:=randf_range(.985,1.015)
	visual.scale=Vector3.ONE*(1.0 if data.category=="cavalry" else data.visual_scale)*silhouette_variation
	visual_base_scale=visual.scale
	contact_shadow=ContactShadow.new();add_child(contact_shadow)
	if data.category=="cavalry":contact_shadow.scale=Vector3(2.0,1,1.25)
	if data.id=="ogre_warthog":contact_shadow.scale=Vector3(2.8,1,1.85)
	elif data.id in ["ogre","ogre_shaman","ogre_skeleton"]:contact_shadow.scale=Vector3(1.7,1,1.6)
	if data.boss:contact_shadow.scale=Vector3(data.body_radius*2.0,1,data.body_radius*1.6)
	animator=find_animation(visual)
	if animator:
		var attack_name:="shoot" if data.ranged else "attack_a"
		if animator.has_animation(attack_name):attack_duration=animator.get_animation(attack_name).length
		for name in animator.get_animation_list():
			if str(name) in ["idle","walk","run","cheer"]:animator.get_animation(name).loop_mode=Animation.LOOP_LINEAR
	play("idle")
	if animator:
		animator.advance(0)
		if animator.has_animation("idle"):
			var idle_length:=animator.get_animation("idle").length
			if idle_length>.05:animator.seek(randf_range(0.0,idle_length),true)
	if data.projectile_kind=="fireball":
		var skeleton:=find_skeleton(visual)
		if skeleton and skeleton.find_bone("hand_R")>=0:
			shaman_focus=ShamanFocus.new();shaman_focus.caster=self
			shaman_focus.bone_name="hand_R";skeleton.add_child(shaman_focus)
	cooldown=randf_range(0,.35)
	if data.boss:
		boss_combat=BossCombat.new();add_child(boss_combat);boss_combat.setup(self)
func begin_raise():
	raise_remaining=RAISE_DURATION
	position.y=-1.25
	scale=Vector3.ONE*.22
	play("idle")
func find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:return node
	for child in node.get_children():
		var found:=find_skeleton(child)
		if found:return found
	return null

func find_animation(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:return node
	for child in node.get_children():
		var found:=find_animation(child)
		if found:return found
	return null
func play(name: String):
	if anim==name:return
	anim=name
	if animator and animator.has_animation(name):
		var blend:=.045 if name in ["attack_a","attack_b","shoot","special","hit"] else .12
		animator.play(name,blend)
func presentation_hit(heavy: bool):
	if not is_instance_valid(visual):return
	if recoil_tween != null and recoil_tween.is_valid():recoil_tween.kill()
	var squash:=Vector3(1.045,.91,1.045) if heavy else Vector3(1.02,.96,1.02)
	visual.scale=visual_base_scale*squash
	recoil_tween=create_tween();recoil_tween.tween_property(visual,"scale",visual_base_scale,.13 if heavy else .09)
func _physics_process(delta: float):
	if hp<=0 or not active or get_tree().paused:return
	if raise_remaining>0:
		raise_remaining=maxf(0.0,raise_remaining-delta)
		var progress:float=1.0-raise_remaining/RAISE_DURATION
		var eased:float=progress*progress*(3.0-2.0*progress)
		position.y=lerpf(-1.25,0.0,eased)
		scale=Vector3.ONE*lerpf(.22,1.0,eased)
		play("idle")
		if raise_remaining<=0:
			position.y=0.0;scale=Vector3.ONE
		return
	cooldown=maxf(0,cooldown-delta);charge_cooldown=maxf(0,charge_cooldown-delta)
	# A ranged boss must reach the visible field before establishing its battery.
	# Otherwise it can kite pursuing knights beyond the wall archers' reach.
	if data.boss and data.ranged and enemy and position.x>data.boss.firing_line and windup<0 and not boss_combat.busy():
		move_toward_point(Vector3(data.boss.firing_line,0,home.z),delta);return
	if boss_combat and boss_combat.tick(delta):return
	if windup>=0:
		windup-=delta
		if windup<=0:
			windup=-1
			if is_instance_valid(target) and target.hp>0:
				var damage:=damage_against(target)
				if data.ranged:
					if data.projectile_kind=="fireball":
						var origin:Vector3=shaman_focus.origin() if is_instance_valid(shaman_focus) else global_position+Vector3.UP*3.0
						battle.projectiles.fireballs.launch(origin,target,damage,enemy,data)
						battle.audio.cue("fire_cast")
					else:
						battle.projectiles.launch(global_position+Vector3.UP*1.65,target,damage)
						battle.audio.cue("bow")
				elif flat_distance(target)<=data.attack_range+.5:
					var charged:bool=data.charge_damage>0 and charge_distance>=3.5 and charge_cooldown<=0
					if charged:
						damage+=data.charge_damage*attack_multiplier;charge_cooldown=12;charge_distance=0
					var feedback_style:="heavy" if charged or data.splash_radius>0 else "auto"
					target.take_damage(damage,false,feedback_style)
					if charged and data.charge_knockback>0 and target is UnitController and target.hp>0:
						var away:Vector3=target.global_position-global_position;away.y=0
						target.position+=away.normalized()*data.charge_knockback
						target.position.z=clampf(target.position.z,-4.4,4.4)
					if data.splash_radius>0:heavy_impact(target,damage)
		return
	if not enemy and data.category=="cavalry" and hp<max_hp*.30:
		var retreat:=Vector3(-2.8,0,home.z)
		if position.distance_to(retreat)>.4:move_toward_point(retreat,delta)
		else:play("idle")
		return
	lock_timer-=delta
	if not is_instance_valid(target) or target.hp<=0 or lock_timer<=0:
		target=choose_target();lock_timer=.45+randf()*.15
	if not is_instance_valid(target):
		if not enemy and not data.ranged and position.distance_to(home)>.35:move_toward_point(home,delta)
		else:play("idle")
		return
	var reach:=data.attack_range
	if flat_distance(target)<=reach:
		var facing:Vector3=target.global_position-global_position;facing.y=0
		if facing.length_squared()>.01:visual.rotation.y=atan2(-facing.x,-facing.z)
		if cooldown<=0:
			attack_index+=1;anim=""
			play("shoot" if data.ranged else ("attack_a" if attack_index%2 else "attack_b"))
			windup=data.hit_time if data.hit_time>=0 else (.625 if data.ranged else .475);cooldown=data.interval
			if data.ranged:battle.targeting.reserve(target,damage_against(target),data.projectile_kind!="fireball")
		elif cooldown<data.interval-maxf(0.0,attack_duration-.08):play("idle")
	elif not data.ranged or enemy:move_toward_point(target.global_position,delta)
	else:play("idle")
func move_toward_point(point: Vector3, delta: float):
	var direction:=point-position;direction.y=0
	if direction.length_squared()<.01:return
	if not enemy and data.category=="cavalry" and is_instance_valid(target) and target is UnitController and target.data.ranged and position.x<point.x-2.0 and absf(position.z)<3.2:
		# Approach hunters along a wing instead of riding through the pike line.
		direction.z+=(1.0 if home.z>=0 else -1.0)*3.0
	direction=(direction.normalized()+battle.targeting.separation(self)).normalized()
	var speed_multiplier:=lerpf(1.0,data.charge_speed_multiplier,minf(charge_distance/3.5,1.0)) if data.charge_damage>0 and charge_cooldown<=0 else 1.0
	var step:Vector3=direction*data.speed*speed_multiplier*delta
	position+=step;position.z=clampf(position.z,-4.4,4.4)
	if data.charge_damage>0:charge_distance+=step.length()
	# Sparse pooled footsteps add weight without turning a large battle into noise.
	step_meter+=step.length()
	var step_distance:=.90 if data.boss or data.id in ["ogre","ogre_warthog","ogre_shaman","ogre_skeleton"] or data.category=="cavalry" else 1.35
	if step_meter>=step_distance:
		step_meter=fmod(step_meter,step_distance)
		if not data.ranged or data.boss:battle.audio.footstep(step_distance<1.0)
	visual.rotation.y=atan2(-direction.x,-direction.z);play("run")
func flat_distance(other: Node3D) -> float:
	var a:=global_position;var b:=other.global_position;a.y=0;b.y=0
	return maxf(0,a.distance_to(b)-data.body_radius-(other.data.body_radius if other is UnitController else 0.0))
func impact_point() -> Vector3:
	return global_position+Vector3.UP*data.impact_height
func damage_against(other: Node3D) -> float:
	var result:=data.damage*damage_scale
	if other is UnitController and other.data.category=="cavalry":result*=data.anti_cavalry
	if other is CastleStructure:result*=data.structure_damage_multiplier
	return result
func heavy_impact(primary: Node3D, _damage: float):
	# A slow, anticipated club hits only a small nearby group, never the whole line.
	var nearby:Array[UnitController]=[]
	for candidate in battle.units:
		if candidate==primary or candidate.hp<=0 or candidate.enemy==enemy or candidate.data.ranged:continue
		if candidate.global_position.distance_to(primary.global_position)<=data.splash_radius:nearby.append(candidate)
	nearby.sort_custom(func(a,b):return a.position.distance_squared_to(primary.position)<b.position.distance_squared_to(primary.position))
	for i in mini(data.splash_targets,nearby.size()):
		var candidate:UnitController=nearby[i]
		candidate.take_damage(data.damage*damage_scale*data.splash_fraction,false,"silent")
		if candidate.hp>0 and data.knockback>0:
			var away:=candidate.global_position-global_position;away.y=0
			candidate.position+=away.normalized()*data.knockback
func choose_target() -> Node3D:
	var best:Node3D
	var best_score:=INF
	for candidate in battle.units:
		if candidate.hp<=0 or candidate.enemy==enemy:continue
		var distance:=flat_distance(candidate)
		if enemy and not data.ranged and candidate.data.ranged and battle.castle.structures.gate.hp>0:continue
		if not enemy and not data.ranged and candidate.position.x>data.pursuit_limit:continue
		var score:=distance
		if data.ranged and distance<=data.attack_range and battle.targeting.saturated(candidate):score+=18.0
		if data.anti_cavalry>1 and candidate.data.category=="cavalry":score*=.68
		if candidate.data.ranged:score*=data.ranged_target_bias
		if candidate.data.category=="heavy" and distance<=data.attack_range:score*=data.heavy_target_bias
		if candidate.data.ranged_resistance>0:score*=data.shield_target_bias
		# A small preference keeps a valid target rather than switching constantly.
		if candidate==target:score*=.82
		if score<best_score:best_score=score;best=candidate
	if enemy:
		if best and flat_distance(best)<(data.attack_range+2.0 if data.ranged else (2.9 if data.structure_damage_multiplier>1 else 4.0)):return best
		# A rebuilt gate cannot teleport enemies already inside back outside.
		return battle.castle.structures.gate if battle.castle.structures.gate.hp>0 and position.x>-4.5 else battle.castle.structures.keep
	return best
func impact_profile() -> String:
	if data.id=="ogre_skeleton":return "bone"
	if data.armor>=.20 or data.category=="cavalry" or data.id in ["orc_guard","ogre_warthog"]:return "metal"
	return "body"
func take_damage(amount: float, ranged_hit: bool=false, feedback_style: String="auto"):
	if hp<=0:return
	var reduced:=amount*(1-data.armor)*(1-data.ranged_resistance if ranged_hit else 1.0)
	hp=maxf(0,hp-reduced)
	if feedback_style not in ["silent","fire"]:
		var profile:=impact_profile()
		var heavy:=feedback_style=="heavy" or (feedback_style=="auto" and reduced>=max_hp*(.09 if data.boss else .18))
		battle.vfx.burst(impact_point(),heavy,profile)
		battle.audio.combat_impact(profile,heavy)
		presentation_hit(heavy)
		if heavy and is_instance_valid(battle.camera):battle.camera.impact(.58 if data.boss else .34,global_position)
	if hp<=0:
		if boss_combat:boss_combat.ring.hide()
		battle.audio.defeat_voice(data.defeat_voice)
		active=false;windup=-1;play("defeat");died.emit(self)
		var tween:=create_tween();tween.tween_interval(1.6 if data.boss else 1.1);tween.tween_property(self,"scale",Vector3.ZERO,.25);tween.tween_callback(queue_free)
	elif windup<0 and not data.boss:play("hit")
func snapshot() -> Dictionary:
	var state:Dictionary={"id":data.id,"enemy":enemy,"hp":hp,"source_wave":source_wave,"position":[position.x,position.y,position.z],"home":[home.x,home.y,home.z],"slot":slot_index,"cooldown":cooldown,"charge_distance":charge_distance,"charge_cooldown":charge_cooldown,"raise_remaining":raise_remaining}
	if boss_combat:state.boss=boss_combat.snapshot()
	return state
func restore_combat(state: Dictionary):
	hp=minf(max_hp,float(state.hp));home=Vector3(state.home[0],state.home[1],state.home[2]);slot_index=int(state.slot)
	cooldown=float(state.cooldown);charge_distance=float(state.charge_distance);charge_cooldown=float(state.charge_cooldown)
	raise_remaining=clampf(float(state.get("raise_remaining",0.0)),0.0,RAISE_DURATION)
	if raise_remaining>0:
		var progress:float=1.0-raise_remaining/RAISE_DURATION
		var eased:float=progress*progress*(3.0-2.0*progress)
		position.y=lerpf(-1.25,0.0,eased);scale=Vector3.ONE*lerpf(.22,1.0,eased)
	elif position.y<0:
		position.y=0.0;scale=Vector3.ONE
	if boss_combat:boss_combat.restore(state.get("boss",{}))
