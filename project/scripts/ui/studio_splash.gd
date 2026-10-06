extends Control
## Bantam Entertainment studio splash. The progress bar is driven by Godot's
## threaded load status for the actual Castlehold battle scene, with a short
## minimum presentation window so the approved studio mark remains readable.
const NEXT_SCENE := "res://scenes/battle/battle.tscn"
const MIN_DISPLAY_SECONDS := 2.35
@onready var progress_bar: ProgressBar = $Content/ProgressBar
@onready var loading_label: Label = $Content/LoadingLabel
var elapsed := 0.0
var requested := false
var switching := false
func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	var error:=ResourceLoader.load_threaded_request(NEXT_SCENE,"PackedScene",true)
	if error!=OK:
		show_failure("LOAD ERROR")
		return
	requested=true
func _process(delta: float):
	if not requested or switching:
		return
	elapsed+=delta
	var progress:Array=[]
	var status:=ResourceLoader.load_threaded_get_status(NEXT_SCENE,progress)
	var actual:=float(progress[0]) if not progress.is_empty() else 0.0
	var presentation:=clampf(elapsed/MIN_DISPLAY_SECONDS,0.0,1.0)
	# Actual threaded progress always participates. The presentation ramp keeps a
	# fast phone from flashing through the splash before the studio mark can read.
	progress_bar.value=minf(99.0,maxf(actual*100.0,presentation*88.0))
	loading_label.text="LOADING"+".".repeat((int(elapsed*2.4)%3)+1)
	if status==ResourceLoader.THREAD_LOAD_FAILED or status==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		show_failure("LOAD ERROR")
	elif status==ResourceLoader.THREAD_LOAD_LOADED and elapsed>=MIN_DISPLAY_SECONDS:
		progress_bar.value=100.0
		switching=true
		call_deferred("open_game")
func open_game():
	await get_tree().process_frame
	var scene:=ResourceLoader.load_threaded_get(NEXT_SCENE) as PackedScene
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		show_failure("LOAD ERROR")
func show_failure(message: String):
	requested=false
	switching=false
	loading_label.text=message
	progress_bar.value=0.0
