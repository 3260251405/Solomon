extends Area2D

var egg = preload("res://2D/inventory/items/egg.tres")
var player : CharacterBody2D = null
var isGrown = true


func pick(body):
	body.inventory.add_item(egg, 1)
	isGrown = false
	queue_free()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		queue_free()
