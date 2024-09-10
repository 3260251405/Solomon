extends Control

var dialogs := []
var index := -1

var tween : Tween

func _ready():
	var content = JSON.parse_string(FileAccess.open("res://dialog.json", FileAccess.READ).get_as_text())
	dialogs = content


func show_dialog_box(speaker, _dialogs):
	$VBoxContainer/Name.text = speaker + ":"
	dialogs = _dialogs
	show()
	show_dialog(0)


func _unhandled_input(event):
	if !visible:
		return
	if event.is_action_released("Interact"):
		if not tween:
			return
		if tween.is_running():
			tween.stop()
			$VBoxContainer/Label.visible_ratio = 1
		elif index < dialogs.size() -1:
			show_dialog(index+1)
		else:
			owner.talkOver()
		get_viewport().set_input_as_handled()

func show_dialog(i: int):
	index = i
	$VBoxContainer/Label.visible_ratio = 0
	var dialog = dialogs[index]
	$VBoxContainer/Label.text = dialog
	
	tween = get_tree().create_tween()
	tween.tween_property($VBoxContainer/Label, "visible_ratio", 1, $VBoxContainer/Label.text.length() * 0.1)
	
