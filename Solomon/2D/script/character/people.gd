extends Life

class_name People

signal click(NPC)
#signal canMake(boolean)
signal signal_haveFire
signal signal_haveWisdom
signal help

@onready var bar_hv = $Bar/HBoxContainer/VBoxContainer/HvBar

var haveFire := false:
	set(v):
		haveFire = v
		signal_haveFire.emit()
var haveWisdom := false:
	set(v):
		haveWisdom = v
		signal_haveWisdom.emit()

var canWalk = true

var inventory : Inventory = null

##交互对象数组
var bodies := []

var hvMax : float = 100:
	set(v):
		hvMax = v
		bar_hv.max_value = hvMax
		
var hv : float = 100:
	set(v):
		var pre = hv
		hv = min(v, 100)
		bar_hv.value = hv
		call_deferred("hv_logic")
		if pre < hv and hv > 70:
			if has_method("show_exp"):
				call_deferred("show_exp", "full")
var noHV : bool = false

var canAttack : bool = true
var canShot : bool = true:
	set(v):
		var pre = canShot
		canShot = v
		if pre == true and canShot == false:
			await get_tree().create_timer(2).timeout
			canShot = true

var isTalking
var talkBody

var canInteract := true
var indicator : Sprite2D = null

var cNames := []
var cName
var age:
	set(v):
		age = v
		if has_method("update_panel"):
			call_deferred("update_panel")

var arrowLoad = preload("res://2D/objects/arrow.tscn")

var zombieVirus := false:
	set(v):
		zombieVirus = v
		if zombieVirus:
			await get_tree().create_timer(200).timeout
			zombieVirus = false

##物品状态记录
var itemData := {}

var goblinKill := 0:
	set(v):
		goblinKill = v
		if !has_method("accomplish"):
			return
		if goblinKill == 20:
			call_deferred("accomplish", "goblinKiller1")
		elif goblinKill == 50:
			call_deferred("accomplish", "goblinKiller2")
		elif goblinKill == 100:
			call_deferred("accomplish", "goblinKiller3")
var slimeKill := 0:
	set(v):
		slimeKill = v
		if !has_method("accomplish"):
			return
		if slimeKill == 20:
			call_deferred("accomplish", "slimeKiller1")
		elif slimeKill == 50:
			call_deferred("accomplish", "slimeKiller2")
		elif slimeKill == 100:
			call_deferred("accomplish", "slimeKiller3")
var animalKill := 0:
	set(v):
		animalKill = v
		if !has_method("accomplish"):
			return
		if animalKill == 20:
			call_deferred("accomplish", "animalKiller1")
		elif animalKill == 50:
			call_deferred("accomplish", "animalKiller2")
		elif animalKill == 100:
			call_deferred("accomplish", "animalKiller3")
var npcKill := 0:
	set(v):
		npcKill = v
		if !has_method("accomplish"):
			return
		if npcKill == 20:
			call_deferred("accomplish", "npcKiller1")
		elif npcKill == 50:
			call_deferred("accomplish", "npcKiller2")
		elif npcKill == 100:
			call_deferred("accomplish", "npcKiller3")
var natures := 0:
	set(v):
		natures = v
		if !has_method("accomplish"):
			return
		if natures == 50:
			call_deferred("accomplish", "natures1")
		elif natures == 100:
			call_deferred("accomplish", "natures2")
		elif natures == 200:
			call_deferred("accomplish", "natures3")

func _init():
	inventory = Inventory.new()
	for index in range(36):
		inventory.slots.append(Slot.new())
	#inventory.add_item(preload("res://2D/tres/tool/pepperoni.tres"), 10)
	#inventory.add_item(preload("res://2D/tres/tool/can.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/tool/medical.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/material/stick.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/food/apple.tres"), 99)
	#inventory.add_item(preload("res://2D/tres/food/apple.tres"), 99)


func _ready():
	super._ready()
	
	hpMax = 100
	hp = hpMax
	
	karma = 0
	
	age = 1
	cName = ""
	cNames = ["蔡","徐","坤","范","丞","王","立","农","丁","真","孙","笑","川","杨","源",
		"洋", "陈","易","兆","亿","万","千","百","十","一","零","白","黑","狗","蛋","王"]
	for n in range(randi_range(2, 3)):
		cName += cNames.pick_random()
	
	if world.has_signal("dayPass"):
		world.dayPass.connect(func(): age+=1)
		
	indicator = get_node_or_null("Indicator")


func upgrade():
	exp += 10
	hpMax += 5
	attackValue += 2
	speed += 2
	hp = hpMax


##保存物品栏物品
func get_item():
	var slots := []
	for slot in inventory.slots:
		if slot.item is Item:
			slots.append({"item"=slot.item.resource_path, "quantity"=slot.quantity})
	return slots


func use(index, item: Item):
	if item.style == item.STYLE.FOOD:
		var data = item.data
		for key in data.keys():
			set(key, get(key) + data.get(key))
		inventory.use_item(index, 1)
	elif item.style == item.STYLE.SEED:
		var type = item.name.split("seed_")[1]
		if to_plant(type):
			inventory.use_item(index, 1)
	elif item.style == item.STYLE.TOOL:
		var type = item.name.to_lower()
		call_deferred(type, index)
	elif item.style == item.STYLE.ANIMAL:
		call_deferred("animal", item.name.to_lower(), index)


func animal(type, index):
	var animal : Animal = null
	if type == "dog":
		animal = load("res://2D/character/dog.tscn").instantiate()
	else:
		animal = load("res://2D/character/herbivores.tscn").instantiate()
		
	var node = get_tree().current_scene.get_node_or_null("Animals")
	if !node:
		node = get_parent()
	node.add_child(animal)
	
	animal.type = type
	animal.global_position = indicator.global_position
	
	inventory.use_item(index, 1)
	
	
func medical(index):
	var slavers = bodies.filter(func(body): return is_instance_valid(body) and body is Life and body.master == self)
	if slavers.is_empty():
		return
	slavers.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	var slaver = slavers[0]
	if slaver.master == self and slaver.hp < slaver.hpMax:
		slaver.hp = slaver.hpMax
		inventory.use_item(index, 1)

	
func can(index):
	var monsterBodies = bodies.filter(func(body): return is_instance_valid(body) and body is Monster)
	if monsterBodies.is_empty():
		return
	monsterBodies.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	var monster = monsterBodies[0]
	if monster.master == null:
		monster.hp = monster.hpMax
		if monster.hateBody == self:
			monster.hateBody = null
		if monster.hateBodies.has(self):
			monster.hateBodies.erase(self)
		monster.master = self
		inventory.use_item(index, 1)


func pepperoni(index):
	var dogBodies = bodies.filter(func(body): return is_instance_valid(body) and body is Dog)
	if dogBodies.is_empty():
		return
	dogBodies.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	var dog = dogBodies[0]
	if dog.master == null:
		dog.hp = dog.hpMax
		if dog.hateBody == self:
			dog.hateBody = null
		if dog.hateBodies.has(self):
			dog.hateBodies.erase(self)
		dog.master = self
		inventory.use_item(index, 1)
	

func capture(index):
	var animalBodies = bodies.filter(func(body): return is_instance_valid(body) and body.is_in_group("animal"))
	if animalBodies.is_empty():
		return
	animalBodies.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	var animal : Animal = animalBodies[0]
	if animal.item:
		inventory.add_item(animal.item, 1)
		animal.queue_free()
		animalBodies.erase(animal)
		inventory.use_item(index, 1)


func hammer(index):
	var targetPosition = indicator.global_position if indicator else global_position
	var tilePos = map.local_to_map(targetPosition)
	var tileData = map.get_cell_tile_data(1, tilePos)
	if tileData:
		map.set_cell(1, tilePos)
		inventory.use_item(index, 1)
		return
	var objectBodies = bodies.filter(func(body): return is_instance_valid(body) and body.is_in_group("object"))
	if objectBodies.is_empty():
		return
	objectBodies.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	objectBodies[0].queue_free()
	objectBodies.remove_at(0)
	inventory.use_item(index, 1)


func campfire():
	var targetPosition = indicator.global_position if indicator else global_position
	var tilePos = map.local_to_map(targetPosition)
	var dict = world.update_data()
	if dict.has("%s%s"%[tilePos.x, tilePos.y]):
		return false
	var campFire = preload("res://2D/objects/camp_fire.tscn").instantiate()
	get_tree().current_scene.get_node("Object").add_child(campFire)
	
	if indicator:
		campFire.global_position = indicator.global_position
	else:
		campFire.global_position = global_position
	return true
	
	
func box():
	var targetPosition = indicator.global_position if indicator else global_position
	var tilePos = map.local_to_map(targetPosition)
	var dict = world.update_data()
	if dict.has("%s%s"%[tilePos.x, tilePos.y]):
		return false
	var campFire = load("res://2D/objects/box.tscn").instantiate()
	campFire.master = self
	get_tree().current_scene.get_node("Object").add_child(campFire)
	
	if indicator:
		campFire.global_position = indicator.global_position
	else:
		campFire.global_position = global_position
	return true


func door():
	var tilePos = map.local_to_map(indicator.global_position) if indicator else map.local_to_map(global_position)
	var dict = world.update_data()
	if dict.has("%s%s"%[tilePos.x, tilePos.y]):
		return false
	var door = load("res://2D/objects/door.tscn").instantiate()
	door.master = self
	get_tree().current_scene.get_node("Object").add_child(door)
	
	if indicator:
		door.global_position = indicator.global_position
	else:
		door.global_position = global_position
	return true


func fencing():
	var list := []
	var tilePos = map.local_to_map(indicator.global_position) if indicator else map.local_to_map(global_position)
	var mapData = map.get_cell_tile_data(1, tilePos)
	var dict = world.update_data()
	if dict.has("%s%s"%[tilePos.x, tilePos.y]):
		return false
	if mapData and mapData.get_custom_data("notEmpty"):
		return false
	list.append(tilePos)
	if !list.is_empty():
		map.set_cells_terrain_connect(1, list, 3, 0, false)
		world.terrain_list2.append([tilePos.x, tilePos.y])
		return true
	return false


func sandbox(index):
	var tilePos = map.local_to_map(indicator.global_position) if indicator else map.local_to_map(global_position)
	var mapData = map.get_cell_tile_data(0, tilePos)
	if !mapData:
		return
	if mapData.get_custom_data("isSea"):
		var cell = world.tile_land.pick_random()
		map.set_cell(0, tilePos, 0, cell)
		world.cell_list.append({str(tilePos.x)+"|"+str(tilePos.y) : [cell.x, cell.y]})
		inventory.use_item(index, 1)


func kettle(index):
	var tilePos = map.local_to_map(indicator.global_position) if indicator else map.local_to_map(global_position)
	var mapData = map.get_cell_tile_data(0, tilePos)
	if !mapData:
		return
	if itemData.has("canWater") and itemData.canWater:
		if mapData.get_custom_data("isSand"):
			var cell = world.tile_grass.pick_random()
			map.set_cell(0, tilePos, 0, cell)
			world.cell_list.append({str(tilePos.x)+"|"+str(tilePos.y) : [cell.x, cell.y]})
			inventory.use_item(index, 1)
			itemData.canWater = false
	else:
		if mapData.get_custom_data("isSea"):
			itemData["canWater"] = true


func shovel(index):
	var tilePos = map.local_to_map(indicator.global_position) if indicator else map.local_to_map(global_position)
	var mapData = map.get_cell_tile_data(0, tilePos)
	if !mapData:
		return
	if mapData.get_custom_data("isSand"):
		inventory.add_item(preload("res://2D/tres/material/sand.tres"), 1)
		inventory.use_item(index, 1)


##使用锄头
func hoe(index):
	var list := []
	var tilePos = map.local_to_map(indicator.global_position) if indicator else map.local_to_map(global_position)
	var mapData = map.get_cell_tile_data(0, tilePos)
	if !mapData:
		return
	if mapData.get_custom_data("isGrass"):
		list.append(tilePos)
	if !list.is_empty():
		map.set_cells_terrain_connect(0, list, 0, 0)
		world.terrain_list.append([tilePos.x, tilePos.y])
		inventory.use_item(index, 1)


func to_plant(type):
	var tilePos = canPlant()
	if tilePos != null:
		var plant = preload("res://2D/objects/plant.tscn").instantiate()
		get_tree().current_scene.get_node("Plants").add_child(plant)
		plant.growing(-1, type)
		var indicator = get_node_or_null("Indicator")
		if indicator:
			plant.global_position = map.map_to_local(map.local_to_map(indicator.global_position))
		else:
			plant.global_position = map.map_to_local(tilePos)
		return true


func canPlant():
	if not map:
		return null
	var targetPosition = indicator.global_position if indicator else global_position
	var tilePos = map.local_to_map(targetPosition)
	var dict : Dictionary = world.update_data()
	var dictKey = "%s%s"%[tilePos.x, tilePos.y]
	var data : TileData = map.get_cell_tile_data(0, tilePos)
	if !data or !data.get_custom_data("canPlant"):
		return null
	if !dict.has(dictKey):
		return tilePos
	elif dict[dictKey] == Global.MAP_DATA.LIFE:
		return tilePos
	return null


func torch(index):
	var light = preload("res://2D/objects/light.tscn").instantiate()
	add_child(light)
	light.global_position = global_position
	await get_tree().create_timer(100).timeout
	light.queue_free()
	inventory.remove_item(index)


func hv_logic():
	if hv <= 0:
		to_die()


func hp_logic():
	if hp <= 0:
		to_die()
		

func to_die():
	if isDead:
		return
	dead.emit(self)
	isDead = true
	
	if self is Player and has_method("accomplish"):
		if world.day <= 1:
			call_deferred("accomplish", "game1")
		if world.day > 10:
			call_deferred("accomplish", "game2")
		if world.day > 30:
			call_deferred("accomplish", "game3")
		if world.day > 50:
			call_deferred("accomplish", "game4")
		if world.day > 100:
			call_deferred("accomplish", "game5")
	
	if zombieVirus:
		var zombie = load("res://2D/character/monsters/zombie.tscn").instantiate()
		get_tree().current_scene.get_node("Monster").add_child(zombie)
		zombie.global_position = global_position
	
	if is_instance_valid(hitBody):
		hitBody.karma -= 30
	
	var items = inventory.get_all_item()
	if items:
		for key in items.keys():
			drop(load(key), items.get(key), true)
			
	drop(load("res://2D/tres/food/flesh.tres"), randi_range(0, 2), true)
	inventory.clear()
			
	#call_deferred("queue_free")


func attack(targetPosition):
	if canAttack:
		shot(targetPosition)
		if randi_range(0, 30) == 10:
			call_deferred("show_exp", "attack1")


func shot(targetPosition):
	#if canShot:
	play_sound("Arrow")
	$Marker2D.look_at(targetPosition)
	var arrow : Area2D = arrowLoad.instantiate()
	arrow.global_position = $Marker2D.global_position - Vector2(0, 15)
	#arrow.rotation = $Marker2D.rotation
	arrow.direction = arrow.global_position.direction_to(targetPosition)
	add_child(arrow)
	#canShot = false


func multi_shot(count, delay, position):
	for index in count:
		shot(position)
		await get_tree().create_timer(delay).timeout


func angle_shot(angle, i):
	var arrow = arrowLoad.instantiate()
	arrow.global_position = $Marker2D.global_position - Vector2(0, 15)
	arrow.direction = Vector2(cos(angle), sin(angle))
	
	add_child(arrow)
	

func radial(count):
	for i in count:
		angle_shot((float(i) / count) * 2.0 * PI, i)


func _on_interact_area_entered(area):
	var body = area.owner if area.owner else area
	if !bodies.has(body):
		bodies.append(body)


func _on_interact_area_exited(area):
	var body = area.owner if area.owner else area
	if bodies.has(body):
		bodies.erase(body)


func _on_hv_timer_timeout() -> void:
	if noHV or isDead:
		return
	
	var value := 0.5
	if hp < hpMax:
		hp += roundi(hpMax / 100)
		value = 1
	hv -= value


func _on_interact_body_entered(body):
	if !bodies.has(body):
		bodies.append(body)


func _on_interact_body_exited(body):
	if bodies.has(body):
		bodies.erase(body)
