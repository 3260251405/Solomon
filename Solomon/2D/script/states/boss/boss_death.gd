extends State

func enter():
	owner.anim.travel("Death")
	owner.direction = Vector2.ZERO
	
	owner.hateBodies.clear()
	owner.hateBody = null
	
	owner.emit_isBoss(false)
	
	await get_tree().create_timer(40).timeout
	owner.queue_free()
