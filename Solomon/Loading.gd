extends Control

var progress := []

func _ready():
	ResourceLoader.load_threaded_request("res://world.tscn")
	
func _process(delta):
	var status := ResourceLoader.load_threaded_get_status("res://world.tscn", progress)
	$ProgressBar.value = progress[0] * 100
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		get_tree().change_scene_to_file("res://world.tscn")
