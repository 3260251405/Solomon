extends Stuff

func _ready() -> void:
	type = "campFire"
	anim.play("new_animation")


func _on_area_2d_body_entered(body):
	if body is People:
		body.haveWisdom = true


func _on_area_2d_body_exited(body):
	if body is People:
		body.haveWisdom = false
