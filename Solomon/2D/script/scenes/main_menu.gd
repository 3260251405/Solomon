extends Control

@onready var worldSizeButton = $PanelContainer/MarginContainer/VBoxContainer2/WroldSize/Button
@onready var NPCCountButton = $PanelContainer/MarginContainer/VBoxContainer2/NPCCount/Button
@onready var TreeCountButton = $PanelContainer/MarginContainer/VBoxContainer2/TreeCount/Button

enum AMOUNT {SELDOM, FEW, NORMAL, LITTLE, MUCH}
var amount
var dict := {}


func _ready():
	dict = {
		"很少":randi_range(0, 10),
		"少":randi_range(10, 20),
		"小":100,
		"普通":randi_range(20, 40),
		"中等":200,
		"大":500,
		"很大":800,
		"超级无敌巨他妈大":1000,
		"随机大小":null,
		"多":randi_range(40, 70),
		"很多":randi_range(70, 100),
	}
	worldSizeButton.select(2)
	NPCCountButton.select(2)
	TreeCountButton.select(2)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()

func _on_start_pressed():
	$PanelContainer/MarginContainer/VBoxContainer3.visible = true
	$PanelContainer/MarginContainer/VBoxContainer2.visible = false

func _on_new_pressed():
	$PanelContainer/MarginContainer/VBoxContainer.visible = false
	$PanelContainer/MarginContainer/VBoxContainer2.visible = true

func _on_survive_pressed():
	var wordSizeKey = worldSizeButton.get_item_text(worldSizeButton.get_selected_id())
	var NPCCountKey = NPCCountButton.get_item_text(NPCCountButton.get_selected_id())
	if !dict.has(wordSizeKey):
		return
	var worldSize = dict.get(wordSizeKey)
	var NPCCount = dict.get(NPCCountKey)
	if worldSize:
		Global.worldSize = worldSize
	if NPCCount:
		match worldSize:
			"小":
				pass
			"中等":
				pass
			"大":
				pass
			"很大":
				pass
			"超级无敌巨他妈大":
				pass
		Global.peopleAmount = NPCCount
	Global.isNew = true
	get_tree().change_scene_to_file("res://2D/scenes/loading.tscn")

func _on_live_pressed():
	get_tree().change_scene_to_file("res://2D/scenes/world_3.tscn")

func _on_button_pressed() -> void:
	if $PanelContainer/MarginContainer/VBoxContainer2.visible:
		$PanelContainer/MarginContainer/VBoxContainer2.hide()
		$PanelContainer/MarginContainer/VBoxContainer.show()
	elif $PanelContainer/MarginContainer/VBoxContainer3.visible:
		$PanelContainer/MarginContainer/VBoxContainer2.show()
		$PanelContainer/MarginContainer/VBoxContainer3.hide()

func _on_v_box_container_visibility_changed() -> void:
	$PanelContainer/Button.visible = !$PanelContainer/MarginContainer/VBoxContainer.visible
	$PanelContainer/Button2.visible = $PanelContainer/MarginContainer/VBoxContainer.visible

func _on_continue_pressed() -> void:
	if !FileAccess.file_exists(Global.SAVE_PATH):
		var warn = load("res://2D/ui/warn.tscn").instantiate()
		add_child(warn)
		warn.show_text("没有找到存档！")
		return
	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if !data:
		return
	if !data.get("world"):
		return
	file.close()
	Global.isNew = false
	get_tree().change_scene_to_file("res://2D/scenes/loading.tscn")


func _on_war_pressed() -> void:
	var warn = load("res://2D/ui/warn.tscn").instantiate()
	get_tree().current_scene.add_child(warn)
	warn.show_text("开发中...")


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://2D/scenes/show_panel.tscn")
