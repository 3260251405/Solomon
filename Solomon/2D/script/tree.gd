extends StaticBody2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer

var apple = preload("res://2D/inventory/items/apple.tres")

var isGrown : bool = false

func _ready():
	sprite.play("default")
	timer.start(randf_range(2, 10))
	

func _process(delta):
	if isGrown:
		sprite.play("apple")
	else: 
		sprite.play("default")
		
	
func pick(body):
	if isGrown:
		body.inventory.add_item(apple, 1)
		timer.start(randf_range(5, 20))
		isGrown = false
		return true
	return false


func _on_timer_timeout():
	if not isGrown:
		isGrown = true
