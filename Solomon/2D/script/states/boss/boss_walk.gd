extends State

var value := 40
var index := 0


func enter():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(logic)
	timer.start(1.2)
	
	waitTime = randf_range(1, 4)
	index = 0
	
	value = 80
	
	owner.anim.travel("Walk")
	owner.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	if owner.hateBody:
		if is_instance_valid(owner.hateBody) and owner.global_position.distance_squared_to(owner.hateBody.global_position) <= pow(300, 2):
			owner.agent.target_position = owner.hateBody.global_position
			#owner.agent.target_position = owner.agent.get_final_position()
			owner.direction = owner.global_position.direction_to(owner.agent.get_next_path_position())
		else:
			owner.hateBodies.erase(owner.hateBody)
			owner.hateBody = null
	elif owner.master:
		if is_instance_valid(owner.master) and owner.global_position.distance_squared_to(owner.master.global_position) >= pow(100, 2):
			owner.agent.target_position = owner.master.global_position
			#owner.agent.target_position = owner.agent.get_final_position()
			owner.direction = owner.global_position.direction_to(owner.agent.get_next_path_position())
		else:
			owner.master = null


func update(delta):
	if owner.isDead:
		change.emit("death")


func logic():
	if owner.isDead:
		change.emit("death")
		return
	
	waitTime -= 1.2
	index += 1.2
	
	if index > 20 and is_instance_valid(owner.hateBody):
		if owner.global_position.distance_squared_to(owner.hateBody.global_position) > pow(120, 2):
			owner.hateBodies.erase(owner.hateBody)
			owner.hateBody = null
			change.emit(["idle", "walk"].pick_random())
			return
		else:
			index = 0
		
	if owner.hateBody:
		if is_instance_valid(owner.hateBody):
			owner.agent.target_position = owner.hateBody.global_position
			if owner.agent.is_navigation_finished() or owner.global_position.distance_squared_to(owner.hateBody.global_position) <= pow(value, 2):
				change.emit("Attack")
				return
			else:
				owner.agent.target_position = owner.hateBody.global_position
				#owner.agent.target_position = owner.agent.get_final_position()
				owner.direction = owner.global_position.direction_to(owner.agent.get_next_path_position())
		else:
			owner.hateBodies.erase(owner.hateBody)
			owner.hateBody = null
	elif owner.master:
		if is_instance_valid(owner.master):
			if owner.global_position.distance_squared_to(owner.master.global_position) >= pow(100, 2):
				owner.agent.target_position = owner.master.global_position
				#owner.agent.target_position = owner.agent.get_final_position()
				owner.direction = owner.global_position.direction_to(owner.agent.get_next_path_position())
		else:
			owner.master = null
	else:
		if owner.is_on_wall() and roundi(index) % randi_range(1,3) == 0:
			owner.direction *= -1
		if waitTime <= 0:
			change.emit(["idle", "walk"].pick_random())


func exit():
	timer.queue_free()
