extends Control

var panelLoad = preload("res://2D/ui/accom_shower.tscn")
@onready var container = $PanelContainer/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer


func _ready():
	for key in Global.dict.keys():
		var str = "res://2D/tres/accomplishment/" + key + ".tres"
		var acc = load(str)
		var panel = panelLoad.instantiate()
		container.add_child(panel)
		panel.texture.texture = acc.texture
		panel.type.text = acc.name
		panel.description.text = acc.description
		if Global.dict.get(key) == false:
			panel.modulate = Color(1, 1, 1, 0.2)
		elif Global.dict.get(key) == true:
			panel.modulate = Color(1, 1, 1, 1)


func _on_button_pressed():
	get_tree().change_scene_to_file("res://2D/scenes/main_menu.tscn")
