extends State

func enter():
	owner.anim.travel("Walk")
	owner.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	await get_tree().create_timer(randf_range(1, 3)).timeout
	if owner.isCrazy:
		change.emit("find")
	else:
		change.emit(owner.states.pick_random())


