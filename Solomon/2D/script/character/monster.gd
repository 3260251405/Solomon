extends Life

class_name Monster

@onready var agent : NavigationAgent2D = $NavigationAgent2D

var type : String

var quantity := 0
var drops := []


func _ready() -> void:
	super._ready()
	
	world.dayChange.connect(func(boolean): isNight = boolean)
	
	hpMax = initHp
	speed = initSpeed
	hp = hpMax
	attackValue = initAttack
	exp = initExp
	initExp = roundi((initSpeed + initHp + initAttack * 2) / 10)
	
	lv = randi_range(1, world.day * 2)
	
	var seedPath = "res://2D/tres/seed/"
	var files = DirAccess.open(seedPath)
	if files:
		for file in files.get_files():
			drops.append(load(seedPath+file.split(".")[0]+"."+file.split(".")[1]))


func hp_logic():
	if isDead:
		return
		
	if hp <= 0:
		dead.emit(self)
		isDead = true
		
		for index in quantity:
			drop(drops.pick_random(), randi_range(0, 2), true)
		
		if is_instance_valid(hitBody):
			hitBody.karma += 20
			if hitBody.has_method("show_exp"):
				hitBody.call_deferred("show_exp", "ye")


func lv_logic():
	hpMax = initHp + lv * 10
	attackValue = initAttack + lv * 5
	speed = initSpeed + lv * 5
	exp = initExp + lv * 20
	hp = hpMax
	quantity = randi_range(ceili((hpMax + attackValue * 10 + speed + lv * 10) / 100), floori((hpMax + attackValue * 10 + speed + lv * 10) / 100))


##怪物无需判定
func to_hurt(hitBody):
	if isDead:
		return

	hurt(hitBody)
	
	if hitBody != master:
		if hitBody.has_signal("help"):
			hitBody.help.emit(self)
	
	if is_instance_valid(hitBody):
		hitBody.karma += 2
	
	if hitBody is Monster or hitBody == master:
		return
	
	hateBodies.append(hitBody)
	
	if hp <= 0 and hitBody is People:
		if type == "goblin":
			hitBody.goblinKill += 1
		elif type == "slime":
			hitBody.slimeKill += 1
		elif type == "goblinKing":
			hitBody.accomplish("goblinKiller5")



func _on_find_body_entered(body):
	if master:
		return
		
	if body.is_in_group("people") and !hateBodies.has(body) and body.karma > -100:
		hateBodies.append(body)


func _on_find_body_exited(body):
	if hateBodies.has(body) and type != "slime":
		hateBodies.erase(body)
		if hateBody == body:
			hateBody = null


func _on_timer_timeout() -> void:
	if isDead:
		$Timer.stop()
		return
	
	hateBodies = hateBodies.filter(check_body)
	if hateBodies.is_empty():
		hateBody = null
		return
		
	hateBodies.sort_custom(func(a, b): 
		return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
	hateBody = hateBodies[0]
	
	#if hateBody:
		#agent.target_position = hateBody.global_position
		#agent.target_position = agent.get_final_position()
