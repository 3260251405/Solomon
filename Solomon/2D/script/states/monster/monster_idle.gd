extends State

func enter():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(logic)
	timer.start(1.2)
	
	if owner.anim:
		owner.anim.travel("Idle")
		
	if randi_range(0, 3) == 1:
		owner.play_sound("Zombie")

	owner.direction = Vector2.ZERO
	waitTime = randf_range(1, 4)


func update(delta):
	if owner.isDead:
		change.emit("death")


func logic():
	if owner.isDead:
		change.emit("death")
		return
		
	if is_instance_valid(owner.hateBody) and owner.global_position.distance_squared_to(owner.hateBody.global_position) <= pow(200, 2):
		change.emit("Walk")
		return
	elif is_instance_valid(owner.master) and owner.global_position.distance_squared_to(owner.master.global_position) >= pow(100, 2):
		change.emit("Walk")
		return
		
	waitTime -= 1.2
	if waitTime <= 0:
		change.emit(["Walk","Idle"].pick_random())
		return


func exit():
	timer.queue_free()
