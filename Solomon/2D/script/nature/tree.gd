extends Nature

@onready var timer: Timer = $Timer

var apple = preload("res://2D/tres/food/apple.tres")

func _ready() -> void:
	super._ready()
	
	type = "tree"
	item = preload("res://2D/tres/material/wood.tres")
	
	timer.timeout.connect(timer_logic)
	timer.start(randi_range(50, 80))
	

func state_logic():
	match state:
		"default":
			$CollisionShape2D.set_deferred("disabled", false)
			isGrown = false
			sprite.play("default")
		"cut":
			$CollisionShape2D.set_deferred("disabled", true)
			isGrown = false
			sprite.play("cut")
		"grown":
			isGrown = true
			sprite.play("grown")


func pick(body):
	if state == "grown":
		state = "default"
		if !body.inventory.add_item(apple, randi_range(1, roundi(hpMax/100))):
			var itemNode = Global.itemNode.instantiate()
			itemNode.canFly = false
			spawner.add_child(itemNode)
			itemNode.generate(apple)
		timer.start(randi_range(50, 80))
		return true
	return false


func die():
	if state == "grown":
		drop(apple, randi_range(1, roundi(hpMax/100)), false)
	drop(item, quantity, false)
	
	state = "cut"
	hpMax = randi_range(10, 200)
	timer.start(hpMax)


func timer_logic():
	if state == "cut":
		hp = hpMax
		state = "default"
	elif state == "default":
		state = "grown"
