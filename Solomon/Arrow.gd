extends Area2D

var direction

func _physics_process(delta):
	position += (Vector2(1, 0) * 300).rotated(rotation) * delta


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
