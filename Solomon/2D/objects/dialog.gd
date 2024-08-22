extends Control

var dialogs := []
var index := -1

var tween : Tween

func _ready():
	var content = JSON.parse_string(FileAccess.open("res://dialog.json", FileAccess.READ).get_as_text())
	dialogs = content
	
func show_dialog_box():
	show()
	show_dialog(0)

func _unhandled_input(event):
	if event.is_action_released("ui_accept"):
		if tween.is_running():
			tween.stop()
			$Label.visible_ratio = 1
		elif index < dialogs.size() -1:
			show_dialog(index+1)
		else:
			hide()

func show_dialog(i: int):
	index = i
	$Label.visible_ratio = 0
	var dialog = dialogs[index]
	$Label.text = dialog
	
	tween = get_tree().create_tween()
	tween.tween_property($Label, "visible_ratio", 1, $Label.text.length() * 0.1)
	
