extends State

var finds := [Callable(find_animal), Callable(find_food)]
var find

var isKilled := false
var selfEat := false

func enter():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(logic)
	timer.start(0.6)

	owner.anim.travel("Walk")
	
	owner.canInteract = false
	
	waitTime = 20
	
	finds.shuffle()
	for find in finds:
		if owner.target:
			return
		find.call()
	
	#if find == "":
		#owner.show_exp("no")
		#change.emit(owner.states.pick_random())
	owner.show_exp("no")
	change.emit(owner.states.pick_random())
	
func update(delta):
	if owner.isDead:
		change.emit("death")


func find_animal():
	owner.animalBodies = owner.animalBodies.filter(func(body): return is_instance_valid(body))
	if owner.animalBodies.is_empty():
		owner.target = null
		change.emit(owner.states.pick_random())
		find = ""
		return
	owner.animalBodies.sort_custom(func(a:Animal, b:Animal): return a.global_position.distance_squared_to(owner.global_position) < b.global_position.distance_squared_to(owner.global_position))
	owner.show_exp("heihei")
	owner.target = owner.animalBodies[0]
	find = "animal"
	waitTime = 25
	#animal_logic()


func find_food():
	waitTime = 20
	owner.findBodies = owner.findBodies.filter(func(body): return is_instance_valid(body) and body.isGrown)
	owner.foodBodies = owner.foodBodies.filter(func(body): return is_instance_valid(body))
	if owner.findBodies.size() > 0:
		owner.findBodies.sort_custom(func(a,b): return a.global_position.distance_squared_to(owner.global_position) < b.global_position.distance_squared_to(owner.global_position))
		owner.show_exp("sex")
		owner.target = owner.findBodies[0]
		owner.agent.target_position = owner.target.global_position
		owner.direction = owner.global_position.direction_to(owner.agent.get_next_path_position())
		
		find = "food"
		#food_logic()
	else:
		var foodBoides = owner.foodBodies.filter(func(body): return is_instance_valid(body) and body.isGrown)
		if foodBoides.size() > 0:
			foodBoides.sort_custom(func(a, b): return a.global_position.distance_squared_to(owner.global_position) < b.global_position.distance_squared_to(owner.global_position))
			owner.target = foodBoides[0]
			owner.agent.target_position = owner.target.global_position
			owner.direction = owner.global_position.direction_to(owner.agent.get_next_path_position())
		
			owner.show_exp("far")
			find = "food"
			#food_logic()
		else :
			owner.target = null
			find = ""


func logic():
	waitTime -= 0.6
	
	if owner.hateBody:
		if is_instance_valid(owner.hateBody):
			if owner.global_position.distance_squared_to(owner.hateBody.global_position) < pow(80, 2):
				owner.target = null
				change.emit("Walk")
				find = ""
				return
		else:
			owner.hateBodies.erase(owner.hateBody)
			owner.hateBody = null
	
	if find == "animal":
		animal_logic()
	elif find == "food":
		food_logic()
	else:
		owner.target = null
		
	if waitTime <= 0:
		if find == "animal":
			if owner.global_position.distance_squared_to(owner.target.global_position) < pow(100, 2):
				waitTime = waitTime / 2
				return
				
		owner.show_exp("sad")
		owner.target = null
		emit_signal("change", owner.states.pick_random())
		return
	
	if owner.direction == Vector2.ZERO and find == "food":
		emit_signal("change", owner.states.pick_random())



func animal_logic():
	isKilled = false
	if owner.target:
		if is_instance_valid(owner.target):
			owner.agent.target_position = owner.target.global_position
			#owner.agent.target_position = owner.agent.get_final_position()
			if owner.agent.is_navigation_finished() or owner.global_position.distance_squared_to(owner.target.global_position) < pow(25, 2):
				isKilled = true
				owner.show_exp("kill")
				change.emit("attack")
				return
			else:
				owner.direction = owner.global_position.direction_to(owner.agent.get_next_path_position())
		else:
			if isKilled:
				owner.show_exp("ye")
			owner.animalBodies.erase(owner.target)
			owner.target = null
			find = ""
			#owner.agent.target_position = Vector2.ZERO
			change.emit(owner.states.pick_random())
			return
	else:
		change.emit(owner.states.pick_random())


func food_logic():
	if owner.target:
		if is_instance_valid(owner.target):
			owner.agent.target_position = owner.target.global_position
			#owner.agent.target_position = owner.agent.get_final_position()
			if owner.agent.is_navigation_finished() or owner.bodies.has(owner.target):
				if !owner.target.has_method("pick"):
					return
				if owner.target.pick(owner) == false:
					owner.show_exp("unhappy")
					selfEat = false
				else :
					owner.show_exp("happy")
					selfEat = true
				owner.findBodies.erase(owner.target)
				owner.bodies.erase(owner.target)
				owner.target = null
				find = ""
				#owner.agent.target_position = Vector2.ZERO
				emit_signal("change", owner.states.pick_random())
				return
			else:
				owner.direction = owner.global_position.direction_to(owner.agent.get_next_path_position())
		else:
			if !selfEat:
				owner.show_exp("sad")
			owner.bodies.erase(owner.target)
			owner.findBodies.erase(owner.target)
			owner.target = null
			find = ""
			#owner.agent.target_position = Vector2.ZERO
			emit_signal("change", owner.states.pick_random())
			return
	else :
		find = ""
		#owner.agent.target_position = Vector2.ZERO
		emit_signal("change", owner.states.pick_random())
		return
	
		
	


func exit():
	owner.canInteract = true
	timer.queue_free()
