extends State

func enter():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(logic)
	timer.start(1.4)
	
	if owner.anim:
		owner.anim.travel("Idle")
		
	if owner.isTalking and is_instance_valid(owner.talkBody):
		owner.animation_tree.set("parameters/Idle/blend_position", owner.talkBody.direction)

	owner.direction = Vector2.ZERO
	
	if randi_range(1, 5) == 2:
		owner.call_deferred("show_exp", ["idle3", "idle2"].pick_random())
	
	waitTime = randf_range(1, 4)


func update(delta):
	if owner.isDead:
		change.emit("death")
		return
	if owner.isTalking:
		var direction = owner.global_position.direction_to(owner.talkBody.global_position)
		owner.animation_tree.set("parameters/Idle/blend_position", direction)


func logic():
	waitTime -= 1.4
	if waitTime <= 0 and !owner.isTalking:
		if owner.isCrazy:
			change.emit("find")
		else:
			change.emit(owner.states.pick_random())
	
	if owner.hateBody:
		if is_instance_valid(owner.hateBody):
			if owner.global_position.distance_squared_to(owner.hateBody.global_position) <= pow(100, 2):
				change.emit("Walk")
		else:
			print(owner.hateBody)
			owner.hateBodies.erase(owner.hateBody)
			owner.hateBody = null


func exit():
	timer.queue_free()
