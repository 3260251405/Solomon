extends CharacterBody2D

class_name People

signal dead
signal signalInteract
signal click(People)

@export_range(0, 200) var speed : int = 50

@onready var animation_tree = $AnimationTree
@onready var bar_hp = $Bar/HpBar
@onready var bar_hv = $Bar/HvBar
@onready var panel = %Panel
@onready var sprite = $Sprite2D
@onready var expression = $Expression

var anim

var inventory = null
var direction := Vector2.ZERO
var isCrazy : bool:
	set(v):
		var pre = isCrazy
		isCrazy = v
		if isCrazy and pre != isCrazy:
			show_exp("cry")
var cNames := []
var cName
var age:
	set(v):
		age=v
		if age > 1:
			update_panel()

var bodies := []
var interactBodies := []

var expDict := {}
var plantDict := {}

var map

var hp : int = 100:
	set(v):
		hp = min(v, 100)
		bar_hp.value = hp
		if hp <= 0:
			queue_free()

var hv : float = 100:
	set(v):
		var pre = hv
		hv = min(v, 100)
		bar_hv.value = hv
		hv_logic()
		if pre < hv and hv > 80:
			show_exp("full")
		
func _init():
	inventory = Inventory.new()
	for index in range(9):
		inventory.slots.append(Slot.new())
	inventory.add_item(preload("res://2D/inventory/items/seed_tomato.tres"), 2)

func _ready():
	$Timer/HvTimer.timeout.connect(func(): hv-=0.1)
	$Timer/AgeTimer.timeout.connect(func(): age+=1)
	
	anim = animation_tree.get("parameters/playback")
	
	map = get_tree().current_scene.get_node_or_null("TileMap")
	
	var files = DirAccess.open("res://assets/expression/")
	if files:
		for file in files.get_files():
			var fileName = file.split(".")[0]
			expDict[fileName] = load("res://assets/expression/"+fileName+".webp")
	
	age = 1
	cName = ""
	cNames = ["蔡","徐","坤","范","丞","王","立","农","丁","真","孙","笑","川","杨","源",
		"洋", "陈","易","千","万","白","黑","百","十","狗","蛋"]
	for n in range(randi_range(2, 3)):
		cName += cNames.pick_random()
	
	update_panel()
	
func update_panel():
	%Picture.texture = sprite.texture
	%Picture.vframes = sprite.vframes
	%Picture.hframes = sprite.hframes
	%Name.text = "姓名:"+cName
	%Age.text = "年龄:%s"%age
	var state = get_node("StateMachine")
	if state:
		%State.text = "状态:"+str(state.dict[state.currentState.name.to_lower()])

func _physics_process(delta):
	velocity = direction * speed
	if direction:
		$Sprite2D.flip_h = direction.x < 0
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)

	move_and_slide()
	global_position = global_position.clamp(Vector2(-800, -800), Vector2(800, 800))
	
func interact():
	if bodies.size() > 0:
		bodies[0].pick(self)
		bodies.erase(bodies[0])
		return true
	return false
	
func use(index, item: Item):
	#食物为0，种子为1
	if item.style == 0:
		var data = item.data
		for key in data.keys():
			set(key, get(key) + data.get(key))
		inventory.use_item(index)
	elif item.style == 1:
		var name = item.name.split("seed_")[1]
		if plant(name):
			inventory.use_item(index)
		
func plant(name):
	var tilePos = canPlant()
	if tilePos != null:
		var plant = preload("res://2D/objects/plant.tscn").instantiate() as Node2D
		plant.style = name
		get_tree().current_scene.add_child(plant)
		plant.global_position = map.map_to_local(tilePos)
		return true

func canPlant():
	if not map:
		return null
	var tilePos = map.local_to_map(global_position)
	var plants = get_tree().get_nodes_in_group("plant")
	var crops = plants.filter(func(crop): return global_position.distance_squared_to(crop.global_position) < pow(17, 2))
	var data = map.get_cell_tile_data(0, tilePos)
	if data and crops.size() <= 0:
		var canPlant = data.get_custom_data("canPlant")
		if canPlant:
			return tilePos
	return null
	
func hv_logic():
	if hv < 40:
		isCrazy = true
	if hv > 60:
		isCrazy = false
	if hv < 5:
		show_exp("bye")
	if hv <= 0:
		dead.emit()
		queue_free()

func show_exp(name):
	if not expression:
		return
	expression.visible = true
	expression.get_child(0).get_child(0).texture = load("res://assets/expression/%s.webp"%name)
	get_tree().create_tween().tween_property(expression, "visible", false, 1)

func _on_interace_area_area_entered(area):
	var body = area.owner if area.owner else area
	if body.is_in_group("food"):
		bodies.append(body)
	elif body.is_in_group("people"):
		interactBodies.append(body)

func _on_interace_area_area_exited(area):
	var body = area.owner if area.owner else area
	if bodies.has(body):
		bodies.erase(body)
	elif interactBodies.has(body):
		interactBodies.erase(body)
