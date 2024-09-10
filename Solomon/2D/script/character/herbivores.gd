extends Animal

var types = ["hen", "cow", "rabbit", "sheep", "pig"]


var eggTime = randi_range(50, 200)


#根据类型初始化变量
func type_init():
	match type:
		"hen":
			item = preload("res://2D/tres/life/hen.tres")
			initHp = randi_range(50, 80)
			initSpeed = randi_range(50, 70)
			
		"cow":
			item = preload("res://2D/tres/life/cow.tres")
			initSpeed = randi_range(20, 50)
			initHp = randi_range(180, 230)
		"rabbit":
			item = preload("res://2D/tres/life/rabbit.tres")
			initHp = randi_range(30, 50)
			initSpeed = randi_range(90, 130)
		"sheep":
			item = preload("res://2D/tres/life/sheep.tres")
			initSpeed = randi_range(50, 80)
			initHp = randi_range(80, 120)
		"pig":
			item = preload("res://2D/tres/life/pig.tres")
			initSpeed = randi_range(30, 50)
			initHp = randi_range(100, 150)
	
	#hpMax = initHp
	#speed = initSpeed
	#hp = hpMax
	#
	#initExp = roundi((initSpeed + initHp + initAttack) / 10)
	#exp = initExp
	#
	#qunantity = randi_range(floori(hpMax / 100), ceili(hpMax / 100) + 2)
	
	var path = "res://assets/animal/"
	var file = path + type + ".png"
	$Sprite2D.texture = load(file)
	
	

func _ready() -> void:
	attackValue = 0
	
	type = types.pick_random()
	state = "idle"
	
	drops.append(preload("res://2D/tres/food/meat.tres"))
	
	super._ready()
	


func state_enter():
	if randi_range(0, 4) == 1:
		play_sound(type.to_lower())
		
	match state:
		"idle":
			anim.travel("Idle")
			direction = Vector2.ZERO
		
		"walk":
			anim.travel("Walk")
			direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			
			if hateBody:
				if is_instance_valid(hateBody):
					if global_position.distance_squared_to(hateBody.global_position) < pow(100, 2):
						direction = global_position.direction_to(hateBody.global_position) * -1
				else:
					hateBodies.erase(hateBody)
					hateBody = null
					
func lv_logic():
	super.lv_logic()
	scale = Vector2(0.4 + lv * 0.05, 0.4 + lv * 0.05)


func to_hurt(body):
	super.to_hurt(body)
	
	state = "walk"
	
	if randi_range(0, 2) == 0:
		play_sound(type.to_lower())
		

	if !hateBodies.has(body):
		hateBodies.append(body)
	await get_tree().create_timer(50).timeout
	if hateBodies.has(body):
		hateBodies.erase(body)


func _on_logic_timer_timeout() -> void:
	hateBodies = hateBodies.filter(func(body): return is_instance_valid(body) and !body.isDead)
	if hateBodies.size() > 0:
		hateBodies.sort_custom(func(a:Life, b:Life): 
			return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
		hateBody = hateBodies[0]
	else :
		hateBody = null

	index += 1.7
	if world:
		nowExp += 1.7 * world.day
	
	if type == "hen" and roundi(index) % eggTime == 0:
		eggTime = randi_range(50, 200)
		drop(preload("res://2D/tres/food/egg.tres"), randi_range(0, 2), false)
	
	match state:
		"idle":
			if is_instance_valid(hateBody) and global_position.distance_squared_to(hateBody.global_position) < pow(100, 2):
				state = "walk"
		"walk":
			if hateBody:
				if is_instance_valid(hateBody):
					if global_position.distance_squared_to(hateBody.global_position) < pow(100, 2):
						direction = global_position.direction_to(hateBody.global_position) * -1
				else:
					hateBodies.erase(hateBody)
					hateBody = null
