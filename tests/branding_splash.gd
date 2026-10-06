extends SceneTree
## Castlehold 0.5.0 studio-branding regression checks.
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
	if ok:print("PASS: "+label)
	else:push_error("FAIL: "+label);failures+=1
func run():
	check(str(ProjectSettings.get_setting("application/run/main_scene"))=="res://scenes/ui/studio_splash.tscn","Bantam splash is the project main scene")
	check(str(ProjectSettings.get_setting("application/boot_splash/image"))=="res://assets/ui/bantam_studio_logo.png","approved Bantam logo is configured as native boot splash")
	var bg:Color=ProjectSettings.get_setting("application/boot_splash/bg_color",Color.WHITE)
	check(bg.is_equal_approx(Color.BLACK),"native boot splash background is solid black")
	var packed:=load("res://scenes/ui/studio_splash.tscn") as PackedScene
	check(packed!=null,"studio splash scene loads")
	var splash:=packed.instantiate()
	check(splash.has_node("Content/Logo") and splash.has_node("Content/ProgressBar") and splash.has_node("Content/LoadingLabel"),"studio splash contains logo, progress and loading label")
	var logo:TextureRect=splash.get_node("Content/Logo")
	check(logo.texture!=null and logo.texture.resource_path=="res://assets/ui/bantam_studio_logo.png","splash uses approved no-domain Bantam logo")
	var source:=FileAccess.get_file_as_string("res://scripts/ui/studio_splash.gd")
	check(source.contains("load_threaded_request") and source.contains("load_threaded_get_status") and source.contains("THREAD_LOAD_LOADED"),"loading bar is wired to real threaded ResourceLoader status")
	check(source.contains("MIN_DISPLAY_SECONDS") and source.contains("change_scene_to_packed"),"splash has readable minimum display and transitions to loaded game scene")
	splash.free()
	print("BRANDING SPLASH COMPLETE failures=",failures)
	quit(failures)
