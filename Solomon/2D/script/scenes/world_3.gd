extends Node2D

var map_data := {}
var second : int = 0
var minute : int = 0

func _ready():
	$Player.canAttack = false
	$Player.global_position = Vector2(randf_range(100, 700), randf_range(100, 500))
	$Player.noHV = true
	$Player.dead.connect(game_over)
	
	$AudioStreamPlayer.play()
	$AudioStreamPlayer.finished.connect($AudioStreamPlayer.play)
	
	for index in range(8):
		var npc = preload("res://2D/character/npc.tscn").instantiate()
		npc.global_position = Vector2(randf_range(100, 700), randf_range(100, 500))
		npc.hateBodies.append(get_node("Player"))
		npc.noHV = true
		npc.speed = randf_range(100, 200)
		npc.attackRange = 500
		get_node("NPCs").add_child(npc)
		
	if !FileAccess.file_exists("user://history.sav"):
		var write = FileAccess.open("user://history.sav", FileAccess.WRITE)
		write.store_string(JSON.stringify({"history":0}))
		write.close()
	

func game_over(body):
	$CanvasLayer/Menu.show()
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
	$GameOver.play()
		
	var history : int
	var score : int = minute * 60 + second

	var read = FileAccess.open("user://history.sav", FileAccess.READ)
	var data : Dictionary = JSON.parse_string(read.get_as_text())
	read.close()
	if !data or !data.has("history"):
		var write = FileAccess.open("user://history.sav", FileAccess.WRITE)
		write.store_string(JSON.stringify({"history":0}))
		write.close()
	else:
		history = data.get("history")
		if score > history:
			var write = FileAccess.open("user://history.sav", FileAccess.WRITE)
			write.store_string(JSON.stringify({"history":score}))
			write.close()
	
	%Score.text = "当前分数：%02d秒"%score
	%History.text = "历史最高：%02d秒"%history

func _on_timer_timeout():
	second += 1
	if second >= 60:
		second = 0
		minute += 1
	$CanvasLayer/Time.text = "%02d:%02d"%[minute, second]


func _input(event):
	if event.is_action_released("ui_cancel"):
		$CanvasLayer/GameMenu.visible = !$CanvasLayer/GameMenu.visible

func _on_menu_visibility_changed() -> void:
	get_tree().paused = $CanvasLayer/Menu.visible


func _on_re_start_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_back_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://2D/ui/main_menu.tscn")
	
