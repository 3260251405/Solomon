extends People

class_name NPC

@onready var agent = $NavigationAgent2D
@onready var expression = $Expression

var expDict := {}

var isCrazy : bool:
	set(v):
		var pre = isCrazy
		isCrazy = v
		if isCrazy and pre != isCrazy:
			show_exp("cry")

var animalBodies := []
##视野范围内的食物
var findBodies := []
##记忆中的食物
var foodBodies := []

var states := ["idle", "walk", "find"]

var target : Node2D = null

var dialogs := []

var haveSeed := false
var haveFood := false

var attackRange := 200.0


func  _ready():
	super._ready()
	
	exp = 30
	
	var files = DirAccess.open("res://assets/expression/")
	if files:
		for file in files.get_files():
			var fileName = file.split(".")[0]
			expDict[fileName] = load("res://assets/expression/"+fileName+".webp")
	
	attackValue = 10

	var list := []
	var files2 = DirAccess.open("res://assets/rpg/")
	if files:
		for file in files2.get_files():
			list.append(load("res://assets/rpg/"+file.split(".")[0]+".png"))
	
	sprite.texture = list.pick_random()
	speed = randi_range(50, 70)
	scale = Vector2(0.6, 0.6)
	
	dialogs = JSON.parse_string(FileAccess.open("res://dialog.json", FileAccess.READ).get_as_text())
	
	if inventory.haveSeed:
		inventory.haveSeed.connect(func(boolean): haveSeed = boolean)
	if inventory.haveFood:
		inventory.haveFood.connect(func(boolean): haveFood = boolean)
	
	update_panel()


func update_panel():
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/TextureRect2/TextureRect.texture = sprite.texture
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/TextureRect2/TextureRect.vframes = sprite.vframes
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/TextureRect2/TextureRect.hframes = sprite.hframes
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Name.text = "姓名:"+cName
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Age.text = "年龄:"+str(age)
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/State.text = "善恶值:"+str(karma)


func talkOver():
	$Panel.hide()


func talk():
	$Panel.show()
	if !talkBody:
		return
	match talkBody.direction2:
		"up":
			$Panel.position = Vector2i(-40, -170)
		"right":
			$Panel.position = Vector2i(10, -90)
		"left":
			$Panel.position = Vector2i(-120, -90)
		"down":
			$Panel.position = Vector2i(-40, 0)


##返回物品栏存在物品的第一个物品
func can_use(style):
	var slots = inventory.slots.filter(func(slot): return slot.item is Item)
	if slots.is_empty():
		return
	var fullSlots = slots.filter(func(slot): return slot.item.style == style)
	if fullSlots.is_empty():
		return
	var index = inventory.slots.find(fullSlots[0])
	var item = inventory.find_item(index)
	if item:
		var data := {}
		data.index = index
		data.item = item
		return data


func hv_logic():
	super.hv_logic()
	if hv < 90:
		if randi_range(0, 50) == 5:
			if haveFood:
				var data = can_use(0)
				if data:
					use(data.index, data.item)
			
	if hv < 70 or hp < 30:
		if haveFood:
			var data = can_use(0)
			if data:
				use(data.index, data.item)
	if hv < 40:
		isCrazy = true
	if hv > 60:
		isCrazy = false
	if hv < 10:
		show_exp("bye")


func show_exp(type):
	if not expression:
		return
	expression.visible = true
	expression.get_child(0).get_child(0).texture = load("res://assets/expression/%s.webp"%type)
	get_tree().create_tween().tween_property(expression, "visible", false, 1.5)


func _on_find_area_entered(area):
	var body = area.owner if area.owner else area
	if body.is_in_group("food"):
		if !findBodies.has(body):
			findBodies.append(body)
		if !foodBodies.has(body):
			foodBodies.append(body)
	#if body.is_in_group("drop") and !findBodies.has(body):
		#findBodies.append(body)
	if body.is_in_group("monster") and !hateBodies.has(body):
		hateBodies.append(body)
	if body.is_in_group("people") and body.karma <= -100:
		if !hateBodies.has(body):
			hateBodies.append(body)
	if body.is_in_group("herbivores") and body not in animalBodies:
		animalBodies.append(body)
	


func _on_find_area_exited(area):
	var body = area.owner if area.owner else area
	if body in findBodies:
		findBodies.erase(body)
	if body in animalBodies and target != body:
		animalBodies.erase(body)


func _on_interactable_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("isCrazy:%s\nstate:%s"%[isCrazy, get_node("StateMachine").currentState.name])
			print("----------------------------------")
		if event.button_index == MOUSE_BUTTON_RIGHT:
			update_panel()
			$Panel.visible = !$Panel.visible
			click.emit(self)
	if event is InputEventScreenTouch and event.is_pressed():
		update_panel()
		$Panel.visible = !$Panel.visible
		click.emit(self)


func to_hurt(body):
	if body is NPC:
		return
		
	hurt(body)
	help.emit(hitBody)
	if hitBody.has_signal("help"):
		hitBody.help.emit(self)
		
	if isTalking and is_instance_valid(talkBody):
		talkBody.talkOver()
		talkOver()
	
	if is_instance_valid(hitBody):
		hitBody.karma -= 2
		
	if hp <= 0 and hitBody is People:
		hitBody.npcKill += 1
	
	show_exp("angry")
	if !hateBodies.has(body):
		hateBodies.append(body)
	await get_tree().create_timer(60).timeout
	if hateBodies.has(body):
		if is_instance_valid(body) and body is Monster:
			return
		hateBodies.erase(body)


func _on_logic_timer_timeout() -> void:
	var map_data : TileData = map.get_cell_tile_data(0, map.local_to_map(global_position))
	if map_data:
		if map_data.get_custom_data("canPlant") and haveSeed:
			var data = can_use(1)
			if data:
				use(data.index, data.item)
				
	hateBodies = hateBodies.filter(func(body): return is_instance_valid(body) and !body.isDead)
	if hateBodies.size() > 0:
		hateBodies.sort_custom(func(a:Life, b:Life): 
			return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
		hateBody = hateBodies[0]
	else :
		hateBody = null

	if hateBody and global_position.distance_squared_to(hateBody.global_position) < pow(attackRange,2):
		attack(hateBody.global_position)
