extends Life

class_name Animal

var waitTime = randi_range(1, 4)

var drops := []
var qunantity : int = 1

var item : Item = null

var type : String:
	set(v):
		type = v
		if has_method("type_init"):
			call("type_init")

var states := ["idle", "walk"]
var state : String:
	set(v):
		state = v
		if has_method("state_enter"):
			call_deferred("state_enter")

var index = 0:
	set(v):
		index = v
		if hateBody:
			return
		
		if is_on_wall() and roundi(index) % randi_range(1,4) == 0:
			direction *= -1
		
		if roundi(index) % waitTime == 0:
			waitTime = randi_range(1, 4)
			state = states.pick_random()


func _ready():
	super._ready()
	
	hpMax = initHp
	speed = initSpeed
	hp = hpMax
	
	initExp = roundi((initSpeed + initHp + initAttack) / 10)
	exp = initExp
	
	qunantity = randi_range(floori(hpMax / 100), ceili(hpMax / 100) + 2)
	
	lv = randi_range(1, world.day * 2)
	
	drops.append(preload("res://2D/tres/food/meat.tres"))


func to_hurt(body):
	if isDead:
		return
	hurt(body)
	
	if hitBody.has_signal("help"):
		hitBody.help.emit(self)
	
	if hp <= 0 and hitBody is People:
		hitBody.animalKill += 1


func lv_logic():
	hpMax = initHp + lv * 20
	attackValue = initAttack + lv * 10
	speed = initSpeed + lv * 5
	exp = initExp + lv * 20
	hp = hpMax
	qunantity = randi_range(floori(hpMax / 100), ceili(hpMax / 100) + 2)


func hp_logic():
	if isDead:
		return
		
	if hp <= 0:
		isDead = true
		dead.emit(self)
		
		drop(drops.pick_random(), qunantity, true)
		
		queue_free()
