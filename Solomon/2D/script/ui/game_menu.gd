extends PanelContainer

@onready var option_button = $MarginContainer/VBoxContainer/Speed/OptionButton
@onready var bgm_button = $MarginContainer/VBoxContainer/BGM/BGMButton
@onready var sfx_button = $MarginContainer/VBoxContainer/SFX/SFXButton

const BGM_IDX := 1
const SFX_IDX := 2


func _ready():
	bgm_button.button_pressed = !AudioServer.is_bus_mute(BGM_IDX)
	sfx_button.button_pressed = !AudioServer.is_bus_mute(SFX_IDX)
	
	option_button.select(1)


func _on_bgm_button_pressed():
	AudioServer.set_bus_mute(BGM_IDX, !bgm_button.button_pressed)


func _on_sfx_button_pressed():
	AudioServer.set_bus_mute(SFX_IDX, !sfx_button.button_pressed)


func _on_back_pressed():
	hide()


func _on_exit_pressed():
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://2D/scenes/main_menu.tscn")


func _on_option_button_item_selected(index):
	Engine.time_scale = float(option_button.get_item_text(index))


func _on_visibility_changed():
	if !get_tree():
		return
	get_tree().paused = visible
		
