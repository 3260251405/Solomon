extends State

func enter():
	owner.anim.travel("Attack")
	owner.play_sound("Attack")
	owner.direction = Vector2.ZERO
	
	if is_instance_valid(owner.target):
		owner.animation_tree.set("parameters/Attack/blend_position", owner.global_position.direction_to(owner.target.global_position))
	else :
		owner.target = null
	
	await owner.animation_tree.animation_finished
	if owner.hateBody:
		change.emit("walk")
	elif owner.target:
		change.emit("find")
	else:
		change.emit(owner.states.pick_random())


func update(delta):
	if owner.isDead:
		change.emit("death")
