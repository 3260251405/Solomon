extends Stuff


func _ready() -> void:
	type = "campFire"
	anim.play("new_animation")
	await get_tree().create_timer(100).timeout
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is People:
		body.haveFire = true
	if body is Monster:
		body.direction = body.global_position.direction_to(global_position) * -1


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is People:
		body.haveFire = false
