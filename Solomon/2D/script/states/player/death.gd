extends State

func enter():
	owner.direction = Vector2.ZERO
	owner.anim.travel("Death")
	await get_tree().create_timer(50).timeout
	owner.queue_free()
	
