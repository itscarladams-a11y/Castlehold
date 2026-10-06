class_name AudioManager
extends Node
signal preferences_save_failed
signal defeat_voice_played(kind: String)
const MUSIC_BUS:="Castlehold Music"
const EFFECTS_BUS:="Castlehold Effects"
var players: Array[AudioStreamPlayer] = []
var voice_players: Array[AudioStreamPlayer] = []
var voices: Dictionary = {}
var voice_last: Dictionary = {}
var voice_variant: Dictionary = {}
var last_voice_time := -1000
var music: AudioStreamPlayer
var interface_player: AudioStreamPlayer
var victory_player: AudioStreamPlayer
var preferences:=SettingsManager.new()
var save_timer: Timer
var dirty:=false
var backgrounded:=false
var battle_paused:=false
var sounds: Dictionary={}
var impact_groups: Dictionary={}
var impact_variant: Dictionary={}
var last_impact_time := -1000
var last_step_time := -1000
var muted: bool:
	get:return preferences.muted
	set(value):
		preferences.muted=value
		if is_node_ready():apply_levels();schedule_save()
var last: Dictionary = {}
var pitch_rng:=RandomNumberGenerator.new()
func _ready():
	# Music stays audible in Settings/Pause; backgrounding suspends everything.
	process_mode=Node.PROCESS_MODE_ALWAYS
	preferences.persistence_enabled=not OS.get_cmdline_user_args().has("--test") and not OS.get_cmdline_user_args().has("--smoke")
	preferences.load_saved()
	for name in [MUSIC_BUS,EFFECTS_BUS]:
		if AudioServer.get_bus_index(name)<0:
			AudioServer.add_bus();AudioServer.set_bus_name(AudioServer.bus_count-1,name)
	for id in ["hit","bow","gate","collapse","coin","horn","victory","defeat","fire_cast","fire_impact","boss_roar","boss_slam","necromancy","victory_fanfare","step_light","step_heavy"]:sounds[id]=load("res://assets/audio/"+id+".wav")
	for kind in ["body","metal","bone"]:
		impact_groups[kind]=[]
		for i in 3:impact_groups[kind].append(load("res://assets/audio/impact_%s_%d.wav"%[kind,i+1]))
	impact_groups["heavy"]=[]
	for i in 2:impact_groups["heavy"].append(load("res://assets/audio/impact_heavy_%d.wav"%(i+1)))
	for i in 8:
		var p := AudioStreamPlayer.new();p.volume_db=-12;p.bus=EFFECTS_BUS;add_child(p);players.append(p)
	for kind in ["human","orc","ogre"]:
		voices[kind]=[]
		for i in 3:voices[kind].append(load("res://assets/audio/voices/"+kind+"_defeat_"+str(i+1)+".wav"))
	for i in 4:
		var p:=AudioStreamPlayer.new();p.name="DefeatVoice%d"%i;p.volume_db=-3;p.bus=EFFECTS_BUS
		add_child(p);voice_players.append(p)
	interface_player=AudioStreamPlayer.new();interface_player.volume_db=-12;interface_player.bus=EFFECTS_BUS;add_child(interface_player)
	victory_player=AudioStreamPlayer.new();victory_player.name="VictoryFanfare";victory_player.volume_db=-2;victory_player.bus=EFFECTS_BUS;victory_player.stream=sounds.victory_fanfare;add_child(victory_player)
	music=AudioStreamPlayer.new();music.name="MedievalSoundtrack";music.bus=MUSIC_BUS
	var stream:AudioStreamOggVorbis=load("res://assets/audio/music/valley_watch.ogg")
	stream.loop=true;stream.loop_offset=0;music.stream=stream;add_child(music)
	save_timer=Timer.new();save_timer.one_shot=true;save_timer.wait_time=.4;add_child(save_timer);save_timer.timeout.connect(save_preferences)
	apply_levels();music.play()
func apply_levels():
	for pair in [[MUSIC_BUS,preferences.music_volume],[EFFECTS_BUS,preferences.effects_volume]]:
		var bus:=AudioServer.get_bus_index(pair[0]);var value:float=pair[1]
		AudioServer.set_bus_volume_db(bus,linear_to_db(maxf(value,.0001)))
		AudioServer.set_bus_mute(bus,preferences.muted or value<=0)
func set_music_volume(value: float):
	preferences.music_volume=preferences.level(value,SettingsManager.DEFAULT_MUSIC);apply_levels();schedule_save()
func set_effects_volume(value: float):
	preferences.effects_volume=preferences.level(value,SettingsManager.DEFAULT_EFFECTS);apply_levels();schedule_save()
func schedule_save():
	dirty=true;save_timer.start()
func save_preferences():
	if not dirty:return
	save_timer.stop()
	if preferences.save():dirty=false
	else:preferences_save_failed.emit()
func set_battle_paused(value: bool):
	battle_paused=value
	for p in players:p.stream_paused=battle_paused or backgrounded
	for p in voice_players:p.stream_paused=battle_paused or backgrounded
func set_backgrounded(value: bool):
	backgrounded=value;music.stream_paused=value;interface_player.stream_paused=value;victory_player.stream_paused=value
	set_battle_paused(battle_paused)
	if value:save_preferences()
func play_victory():
	if muted or backgrounded or preferences.effects_volume<=0:return
	victory_player.stop();victory_player.pitch_scale=1.0;victory_player.play()
func stop_victory():
	if is_instance_valid(victory_player):victory_player.stop()
func preview_effects():
	if muted or backgrounded:return
	interface_player.stream=sounds.hit;interface_player.play()
func defeat_voice(kind: String) -> bool:
	if muted or backgrounded or battle_paused or preferences.effects_volume<=0 or not voices.has(kind):return false
	var now:=Time.get_ticks_msec()
	# No delayed queue: a defeat is heard with the fall or omitted in a dense crowd.
	var speed_factor:=maxf(1.0,Engine.time_scale)
	var global_gap:=roundi(60.0/speed_factor)
	var kind_gap:=roundi((230.0 if kind=="ogre" else 150.0)/speed_factor)
	if now-last_voice_time<global_gap or now-int(voice_last.get(kind,-1000))<kind_gap:return false
	var chosen:AudioStreamPlayer
	for p in voice_players:
		if not p.playing:chosen=p;break
	# A fallen defender remains audible even during a burst of enemy casualties.
	if not chosen and kind=="human":
		for p in voice_players:
			if str(p.get_meta("voice_kind",""))!="human":chosen=p;break
	if not chosen:return false
	var index:=int(voice_variant.get(kind,0))%3;voice_variant[kind]=(index+1)%3
	chosen.stop();chosen.stream=voices[kind][index];chosen.set_meta("voice_kind",kind)
	chosen.pitch_scale=pitch_rng.randf_range(.94,1.06)
	chosen.volume_db=-1.5 if kind=="ogre" else (-2.0 if kind=="human" else -3.0)
	chosen.play();voice_last[kind]=now;last_voice_time=now;defeat_voice_played.emit(kind)
	return true
func free_effect_player() -> AudioStreamPlayer:
	for p in players:
		if not p.playing:return p
	return null
func combat_impact(kind: String, heavy: bool=false) -> bool:
	if muted or backgrounded or battle_paused or preferences.effects_volume<=0:return false
	var now:=Time.get_ticks_msec()
	var gap:=34 if heavy else 48
	if now-last_impact_time<gap:return false
	var group:="heavy" if heavy else (kind if impact_groups.has(kind) else "body")
	var clips:Array=impact_groups[group]
	if clips.is_empty():return false
	var player:=free_effect_player()
	if not player:return false
	var index:=int(impact_variant.get(group,0))%clips.size();impact_variant[group]=(index+1)%clips.size()
	player.stream=clips[index];player.pitch_scale=pitch_rng.randf_range(.94,1.06)
	player.volume_db=-4.5 if heavy else (-6.5 if group=="metal" else -7.5)
	player.play();last_impact_time=now;return true
func footstep(heavy: bool=false):
	if muted or backgrounded or battle_paused or preferences.effects_volume<=0:return
	var now:=Time.get_ticks_msec()
	if now-last_step_time<(105 if heavy else 145):return
	var player:=free_effect_player()
	if not player:return
	player.stream=sounds["step_heavy" if heavy else "step_light"]
	player.pitch_scale=pitch_rng.randf_range(.91,1.08);player.volume_db=-16 if heavy else -20
	player.play();last_step_time=now
func cue(id: String):
	if muted or backgrounded or not sounds.has(id):return
	var now := Time.get_ticks_msec()
	if now-int(last.get(id,0)) < 70: return
	last[id]=now
	if id=="coin":interface_player.stream=sounds.coin;interface_player.play();return
	if battle_paused:return
	for p in players:
		if not p.playing:
			p.stream=sounds[id]
			p.volume_db=-2.0 if id=="victory_fanfare" else -12.0
			p.pitch_scale=1.0 if id=="victory_fanfare" else pitch_rng.randf_range(.95,1.05);p.play();return
func _exit_tree():
	if dirty:preferences.save()
	stop_all()
func stop_all():
	if is_instance_valid(music):music.stop();music.stream=null
	if is_instance_valid(interface_player):interface_player.stop();interface_player.stream=null
	if is_instance_valid(victory_player):victory_player.stop();victory_player.stream=null
	for player in players:
		if is_instance_valid(player):player.stop();player.stream=null
	for player in voice_players:
		if is_instance_valid(player):player.stop();player.stream=null
	voice_last.clear();impact_variant.clear();last_voice_time=-1000;last_impact_time=-1000;last_step_time=-1000
