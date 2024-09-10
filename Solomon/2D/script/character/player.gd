extends People

class_name Player

@export var direction2 : String
@onready var bag = $CanvasLayer/Panel/HBoxContainer/Bag
@onready var info = $CanvasLayer/Panel/HBoxContainer/PanelContainer
@onready var panel = $CanvasLayer/Panel
@onready var accomplishMent = $CanvasLayer/PanelContainer
@onready var camera = $Camera2D


func _ready():
	super._ready()
	#inventory.add_item(preload("res://2D/tres/food/jam.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/food/flesh.tres"), 99)
	inventory.add_item(preload("res://2D/tres/tool/pepperoni.tres"), 1)
	#inventory.add_item(preload("res://2D/tres/food/apple.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/material/stone.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/material/wood.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/material/plank.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/tool/can.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/tool/medical.tres"), 99)
	
	exp = 100
	
	attackValue = 20
	speed = 100
	
	#karma = -200
	#speed = 150
	
	
	if !worldSize:
		return
	$Camera2D.limit_left = worldSize[0].x
	$Camera2D.limit_top = worldSize[0].y
	$Camera2D.limit_right = worldSize[1].x
	$Camera2D.limit_bottom = worldSize[1].y


func _physics_process(delta: float) -> void:
	if canWalk and !isTalking and !isDead:
		direction = Input.get_vector("left", "right", "up", "down")
		
	super._physics_process(delta)
	
	if !direction or !indicator:
		return
	var tilePos = map.local_to_map(sprite.global_position + Vector2(2, 2))
	match direction2:
		"up":
			indicator.global_position = map.map_to_local(tilePos + Vector2i(0, -1))
		"left":
			indicator.global_position = map.map_to_local(tilePos + Vector2i(-1, 0))
		"right":
			indicator.global_position = map.map_to_local(tilePos + Vector2i(1, 0))
		"down":
			indicator.global_position = map.map_to_local(tilePos + Vector2i(0, 1))
	if indicator.visible:
		$Areaes/Interact.global_position = indicator.global_position


func accomplish(str):
	if Global.dict[str] == true:
		return
	Global.dict[str] = true
	var file = "res://2D/tres/accomplishment/" + str + ".tres"
	var acc = load(file)
	accomplishMent.texture.texture = acc.texture
	accomplishMent.type.text = acc.name
	accomplishMent.description.text = acc.description
	var tween = get_tree().create_tween()
	tween.tween_property(accomplishMent, "position", accomplishMent.position + Vector2(0, 35), 0.5)
	tween.tween_interval(1)
	tween.tween_property(accomplishMent, "position", accomplishMent.position, 0.5)
	

func interact():
	if bodies.is_empty():
		return
	bodies = bodies.filter(func(body): return is_instance_valid(body))
	if bodies.is_empty():
		return

	bodies.sort_custom(func(a:Node2D, b:Node2D): return a.global_position.distance_squared_to($Indicator.global_position) < b.global_position.distance_squared_to($Indicator.global_position))
	if bodies[0].has_method("pick"):
		bodies[0].pick(self)
		
	if bodies[0] is NPC and !isTalking and bodies[0].canInteract and !bodies[0].hateBody:
		bodies[0].talkBody = self
		talkBody = bodies[0]
		isTalking = true
		bodies[0].isTalking = true
		talk()
		bodies[0].talk()


func talkOver():
	talkBody.isTalking = false
	talkBody.talkOver()
	isTalking = false
	$CanvasLayer/Dialog.hide()


func _unhandled_input(event):
	if isDead:
		return
	if event.is_action_released("Interact"):
		interact()
	if event.is_action_released("F"):
		attack(get_global_mouse_position())
	if event is InputEventKey and event.is_released():
		match event.keycode:
			KEY_1:
				use_item(0)
			KEY_2:
				use_item(1)
			KEY_3:
				use_item(2)
			KEY_4:
				use_item(3)
			KEY_5:
				use_item(4)
			KEY_6:
				use_item(5)
			KEY_7:
				use_item(6)
			KEY_8:
				use_item(7)
			KEY_9:
				use_item(8)
			KEY_Z:
				radial(3)
			KEY_B:
				$CanvasLayer/Panel.visible = !$CanvasLayer/Panel.visible


func to_hurt(hitBody):
	if isDead:
		return
	if hitBody is Dog and hitBody.master == self:
		return
	hurt(hitBody)
	if hitBody is Monster and hitBody.master == self:
		return
	help.emit(hitBody)
	if hitBody.has_signal("help"):
		hitBody.help.emit(self)


func talk():
	if !$CanvasLayer/Dialog.visible:
		$CanvasLayer/Dialog.show_dialog_box(talkBody.cName, talkBody.dialogs.pick_random())


func use_item(index):
	var item = inventory.find_item(index)
	if item:
		use(index, item)
