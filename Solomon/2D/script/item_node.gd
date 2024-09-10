extends Area2D

var player : CharacterBody2D = null
var isGrown = true
var target
var bodies := []

var direction := Vector2.ZERO
var gravity2 := Vector2.ZERO
var velocity := Vector2.ZERO

var item

var interactable := false
var canFly := true

func _ready() -> void:
	if canFly:
		velocity = Vector2(randi_range(-70, 70), randi_range(-100, -140))
		gravity2 = Vector2(0, 1.5)
	await get_tree().create_timer(1.1).timeout
	canFly = false
	interactable = true
	await get_tree().create_timer(30).timeout
	queue_free()


func _process(delta: float) -> void:
	if bodies.is_empty():
		return
	bodies = bodies.filter(func(body): return is_instance_valid(body) and !body.isDead)
	if bodies.is_empty():
		target = null
		return
	bodies.sort_custom(func(a:People, b:People): global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position))
	target = bodies[0]


func _physics_process(delta: float) -> void:
	if target and interactable:
		if is_instance_valid(target):
			direction = global_position.direction_to(target.global_position)
			global_position += direction * 500 * delta
		else :
			bodies.erase(target)
			target = null
	
	if canFly:
		velocity += gravity2 * delta * 160
		global_position += velocity * delta


func generate(item: Item):
	self.item = item
	$Sprite2D.texture = item.texture
	$Sprite2D.set_deferred("scale", Vector2(max(16/$Sprite2D.texture.get_width(), 0.2), max(16/$Sprite2D.texture.get_height(), 0.2)))
	

func _on_body_entered(body: Node2D) -> void:
	if !interactable:
		return
	if body.is_in_group("people") and !body.isDead:
		if body.inventory.add_item(item, 1):
			queue_free()
		else:
			interactable = false
			direction = Vector2.ZERO
			bodies.erase(target)
			target = null
			await get_tree().create_timer(1).timeout
			interactable = true


func _on_find_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("people") && !bodies.has(body) and !body.isDead:
		bodies.append(body)


func _on_find_area_body_exited(body: Node2D) -> void:
	if bodies.has(body):
		bodies.erase(body)
