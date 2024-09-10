extends State

func enter():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(logic)
	timer.start(0.1)
	
	owner.anim.travel("Attack")
	owner.play_sound("Attack")
	
	if is_instance_valid(owner.hateBody):
		owner.animation_tree.set("parameters/Attack/blend_position", owner.global_position.direction_to(owner.hateBody.global_position))

	await owner.animation_tree.animation_finished
	if owner.isDead:
		return
	elif owner.hateBody:
		change.emit("walk")
	else:
		change.emit(["walk", "idle"].pick_random())
	


func update(delta):
	if owner.isDead:
		change.emit("death")


func logic():
	if owner.isDead:
		change.emit("death")
		return
		
	if owner.hateBody:
		if is_instance_valid(owner.hateBody):
			owner.direction = owner.global_position.direction_to(owner.hateBody.global_position)
		else:
			owner.hateBodies.erase(owner.hateBody)
			owner.hateBody = null


func exit():
	timer.queue_free()
