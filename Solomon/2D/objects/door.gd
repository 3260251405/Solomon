extends Stuff


func _ready() -> void:
	type = "door"
	anim.play("close")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_instance_valid(master) and master == body:
		anim.play("open")
		if !$OpenDoor.playing:
			$OpenDoor.play()
		$CollisionShape2D.set_deferred("disabled", true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if is_instance_valid(master) and master == body:
		anim.play("close")
		$CollisionShape2D.set_deferred("disabled", false)
