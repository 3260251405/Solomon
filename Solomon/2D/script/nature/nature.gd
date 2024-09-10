extends StaticBody2D

class_name Nature

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var spawner

var item = preload("res://2D/tres/material/wood.tres")
#var itemLoad = preload("res://2D/objects/item_node.tscn")

var type = "tree"
var index

var isGrown
var state = "default":
	set(v):
		state = v
		if has_method("state_logic"):
			call_deferred("state_logic")
		
				
var quantity := 1

var hpMax := randi_range(10, 200):
	set(v):
		hpMax = v
		scale = Vector2(1+(hpMax-100)/200, 1+(hpMax-100)/200)
		quantity = randi_range(floori(hpMax/100), ceili(hpMax/100) + 2)
		

var hp = hpMax:
	set(v):
		hp = v
		if hp <= 0 and has_method("die"):
			call_deferred("die")


func _ready():
	state = "default"
	
	hpMax = randi_range(10, 200)
	hp = hpMax
	
	clamp(quantity, 1, 10)
	
	var node = get_tree().current_scene.get_node_or_null("Drops")
	spawner = node if node else get_parent()


func drop(item: Item, quantity: int, canFly: bool):
	for index in quantity:
		var itemNode = Global.itemNode.instantiate()
		itemNode.canFly = canFly
		spawner.add_child(itemNode)
		itemNode.generate(item)
		itemNode.global_position = global_position + Vector2(randi_range(-10, 10), randi_range(-10, 0))


func shake():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "offset", sprite.offset + Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.2)
	tween.tween_callback(func(): sprite.offset = Vector2.ZERO)


func _on_hurt_box_hurt(hitbox: Variant) -> void:
	if state == "cut" or hp <= 0:
		return
		
	var hitBody = hitbox.owner
		
	hp -= hitBody.attackValue
	if hitBody.has_signal("help"):
		hitBody.help.emit(self)
	
	shake()
	
	if hp <= 0 and hitBody is People:
		hitBody.natures += 1
