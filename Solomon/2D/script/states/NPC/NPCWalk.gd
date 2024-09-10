extends State

var index

func enter():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(logic)
	timer.start(1.2)
	
	owner.anim.travel("Walk")
	waitTime = randf_range(1, 5)
	index = 0
	
	owner.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	if !owner.hateBody:
		return
		
	if is_instance_valid(owner.hateBody):
		if owner.global_position.distance_squared_to(owner.hateBody.global_position) <= pow(80, 2):
			owner.show_exp("scary")
			owner.direction = owner.global_position.direction_to(owner.hateBody.global_position) * -1
	else:
		owner.hateBodies.erase(owner.hateBody)
		owner.hateBody = null


func update(delta):
	if owner.isDead:
		change.emit("death")
		return
	if owner.isTalking:
		change.emit("idle")


func logic():
	waitTime -= 1.2
	index += 1.2
	
	if owner.hateBody:
		if !is_instance_valid(owner.hateBody):
			owner.hateBodies.erase(owner.hateBody)
			owner.hateBody = null
		else:
			if owner.global_position.distance_squared_to(owner.hateBody.global_position) <= pow(80, 2):
				owner.direction = owner.global_position.direction_to(owner.hateBody.global_position) * -1
				return
				
	if owner.is_on_wall() and roundi(index) % randi_range(1,3) == 0:
		owner.direction *= -1
	
	if waitTime <= 0:
		if owner.isCrazy:
			change.emit("find")
		else:
			change.emit(owner.states.pick_random())


func exit():
	timer.queue_free()
