extends Animal

class_name Dog

@onready var agent: NavigationAgent2D = $NavigationAgent2D

var hateBodyTime := 20
var attackRange := 35
var findRange := 300


func _ready() -> void:
	type = "dog"
	state = "idle"
	
	item = preload("res://2D/tres/life/dog.tres")

	initSpeed = randi_range(90, 110)
	initHp = randi_range(90, 120)
	initAttack = randi_range(10, 15)
	initExp = roundi((initSpeed + initHp + initAttack * 2) / 10)
	
	super._ready()


func state_enter():
	match state:
		"idle":
			anim.travel("Idle")
			direction = Vector2.ZERO
			
		"walk":
			anim.travel("Walk")
			direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			
			if hateBody:
				hateBodyTime = 20
				if is_instance_valid(hateBody) and global_position.distance_squared_to(hateBody.global_position) <= pow(findRange, 2):
						agent.target_position = hateBody.global_position
						#agent.target_position = agent.get_final_position()
						direction = global_position.direction_to(agent.get_next_path_position())
				else:
					hateBodies.erase(hateBody)
					hateBody = null
			elif master and is_instance_valid(master) and global_position.distance_squared_to(master.global_position) > pow(100, 2):
				agent.target_position = master.global_position
				#agent.target_position = agent.get_final_position()
				direction = global_position.direction_to(agent.get_next_path_position())
		"attack":
			anim.travel("Attack")
			play_sound("Attack")
			direction = Vector2.ZERO
			if is_instance_valid(hateBody):
				animation_tree.set("parameters/Attack/blend_position", global_position.direction_to(hateBody.global_position))
			await animation_tree.animation_finished
			state = ["idle", "walk"].pick_random()
			if is_instance_valid(hateBody) and global_position.distance_squared_to(hateBody.global_position) <= pow(40, 2):
				state = "idle"


func to_hurt(body):
	if body is Dog and body.master == master:
		return
	
	if body == master:
		return
		
	super.to_hurt(body)

	if !hateBodies.has(body):
		hateBodies.append(body)
	await get_tree().create_timer(50).timeout
	if hateBodies.has(body):
		hateBodies.erase(body)


func _on_logic_timer_timeout() -> void:
	hateBodies = hateBodies.filter(check_body)
	if hateBodies.size() > 0:
		hateBodies.sort_custom(func(a, b): 
			return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
		hateBody = hateBodies[0]
	else :
		hateBody = null

	index += 0.8
	
	match state:
		"idle":
			if hateBody:
				if is_instance_valid(hateBody):
					if global_position.distance_squared_to(hateBody.global_position) < pow(attackRange, 2):
						state = "attack"
						return
					else:
						state = "walk"
						return
				else:
					hateBodies.erase(hateBody)
					hateBody = null
			elif master:
				if is_instance_valid(master):
					if global_position.distance_squared_to(master.global_position) > pow(100, 2):
						state = "walk"
						return
				else :
					master = null
		"walk":
			if hateBody:
				hateBodyTime -= 0.8
				if hateBodyTime <= 0:
					if is_instance_valid(hateBody) and global_position.distance_squared_to(hateBody.global_position) < pow(100, 2):
						hateBodyTime = 20
					else:
						hateBodies.erase(hateBody)
						hateBody = null
						
				if is_instance_valid(hateBody):
					if global_position.distance_squared_to(hateBody.global_position) < pow(attackRange, 2):
						state = "attack"
						return
					elif global_position.distance_squared_to(hateBody.global_position) <= pow(findRange, 2):
						agent.target_position = hateBody.global_position
						#agent.target_position = agent.get_final_position()
						direction = global_position.direction_to(agent.get_next_path_position())
					else:
						hateBodies.erase(hateBody)
						hateBody = null
				else:
					hateBodies.erase(hateBody)
					hateBody = null
						
			elif master:
				if is_instance_valid(master):
					if global_position.distance_squared_to(master.global_position) < pow(50, 2):
						state = "idle"
						return
					else:
						agent.target_position = master.global_position
						#agent.target_position = agent.get_final_position()
						direction = global_position.direction_to(agent.get_next_path_position())
				else:
					master = null
