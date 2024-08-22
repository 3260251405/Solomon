extends People

func _ready():
	super._ready()
	speed = 100
	
	

func _process(delta):
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

func _unhandled_input(event):
	if event.is_action_released("Interact"):
		interact()
		if interactBodies.size() > 0:
			interactBodies[0].tt.emit()
	if event.is_action_released("Bag"):
		pass
	if event.is_action_released("F"):
		$Marker2D.look_at(get_global_mouse_position())
		var arrow : Area2D = preload("res://2D/objects/arrow.tscn").instantiate()
		arrow.global_position = $Marker2D.global_position
		arrow.rotation = $Marker2D.rotation
		arrow.direction = direction
		add_child(arrow)
