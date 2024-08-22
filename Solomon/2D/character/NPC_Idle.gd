extends State

func enter():
	owner.direction = Vector2.ZERO
	if owner.anim:
		owner.anim.travel("Idle")
	await get_tree().create_timer(randf_range(1, 3)).timeout
	if owner.isCrazy:
		change.emit("find")
	else:
		change.emit(owner.states.pick_random())
