extends Node2D

@onready var map = $TileMap
@onready var camera = $Camera2D
@onready var option_button = $CanvasLayer/Menu/MarginContainer/VBoxContainer/Speed/OptionButton
@onready var bgmButton = $CanvasLayer/Menu/MarginContainer/VBoxContainer/BGM/CheckButton
@onready var sfxButton = $CanvasLayer/Menu/MarginContainer/VBoxContainer/SFX/CheckButton


var noiseTile :  FastNoiseLite

signal dayPass
signal dayChange
signal signal_isBoss

const LAYER_GROUND := 0
const LAYER_ENVIR := 1

var tile_land := []
var tile_grass := []
var tile_sea := Vector2i(0, 1)
var tile_trees := [Vector2i(12, 2), Vector2i(15, 2), Vector2i(12, 6), Vector2i(12, 9)]

var cell_list := []
var terrain_list := []
var terrain_list2 := []

var landPer = 0.5
var grassPer = 0.3
var dirtPer = 0.1

var width := 100
var height := 100

var value = Vector2(0.05, 0.05)
var mousePos
var currentPos
var isPress : bool

var index := 0

var cameraTarget : People = null

var player

var isNight := false:
	set(v):
		isNight = v
		dayChange.emit(isNight)
var day := 1:
	set(v):
		day = v
		$CanvasLayer/Day.text = "Day"+str(day)
		if day % 10 == 0 and player and !isBoss:
			add_body(get_node("Monster"), load("res://2D/character/goblin_king.tscn").instantiate(), "isLand", player.global_position)
		
var lightValue : float = 9.0 / 5.0 * 0.1 / 60
var dayLight : float = 0.0:
	set(v):
		dayLight = v
		clampf(dayLight, 0, 0.9)
		if dayLight > 0.4 and !isNight:
			isNight = true
		if dayLight <= 0.4 and isNight:
			isNight = false
		$DirectionalLight2D.energy = dayLight
		if dayLight <= 0.0:
			day += 1
			dayPass.emit()
			
			
			lightValue = abs(lightValue)
		elif dayLight >= 0.9:
			lightValue *= -1

var isBoss := false:
	set(v):
		var pre = isBoss
		isBoss = v
		if pre != isBoss:
			if isBoss:
				dayLight = 0.9
				$BGM.stop()
				$AttackBGM.play()
				$AttackBGM.finished.connect(func(): $AttackBGM.play())
				show_warn("永夜降临，请去击败BOSS!")
			else:
				$AttackBGM.stop()
				$BGM.play()
				$BGM.finished.connect(func(): $BGM.play())
				dayLight = 0
			
var monsters := []

var stone = preload("res://2D/nature/stone.tscn")
var tree = preload("res://2D/nature/tree.tscn")

var plant = preload("res://2D/objects/plant.tscn")

var npc = preload("res://2D/character/npc.tscn")

var dog = preload("res://2D/character/dog.tscn")
var herbivores = preload("res://2D/character/herbivores.tscn")

var slime = preload("res://2D/character/monsters/slime.tscn")
var goblin = preload("res://2D/character/monsters/goblin.tscn")
var zombie = preload("res://2D/character/monsters/zombie.tscn")


func _ready():
	signal_isBoss.connect(func(boolean): isBoss = boolean)
	get_tree().quit_on_go_back = false
	
	$BGM.play()
	$BGM.finished.connect($BGM.play)
	
	for index in range(6):
		tile_grass.append(Vector2i(index, 0))
		if index >= 3:
			continue
		tile_land.append(Vector2i(index + 6, 0))
	
	monsters = [slime, goblin, zombie]
		
	noiseTile = FastNoiseLite.new()
	var noiseEnvir = FastNoiseLite.new()
	
	noiseEnvir.frequency = 0.8
	
	var data : Dictionary

	if Global.isNew:
		width = Global.worldSize
		height = Global.worldSize
		noiseTile.seed = randi()
		noiseTile.fractal_octaves = randi_range(1, 5)
		noiseTile.frequency = randf_range(0.01, 0.05)
	else:
		data = load_game()
		var worldData = data.get("world")
		width = worldData.get("size")[0]
		height = worldData.get("size")[1]
		noiseTile.seed = worldData.get("seed")
		noiseTile.fractal_octaves = worldData.get("fractal")
		noiseTile.frequency = worldData.get("frequency")
		dayLight = worldData.get("dayLight")
		day = worldData.get("day")
		cell_list = worldData.get("cell_list")
		terrain_list = worldData.get("terrain_list")
		terrain_list2 = worldData.get("terrain_list2")
		index = worldData.get("index")

	generate_world(noiseTile, noiseEnvir)
	if !cell_list.is_empty():
		for cellDict in cell_list:
			for key in cellDict:
				var cell = key.split("|")
				map.set_cell(0, Vector2(int(cell[0]), int(cell[1])), 0, Vector2i(cellDict.get(key)[0], cellDict.get(key)[1]))
				
	if !terrain_list.is_empty():
		var list := []
		for terrain in terrain_list:
			list.append(Vector2(terrain[0], terrain[1]))
		map.set_cells_terrain_connect(0, list, 0, 0)
		
	if !terrain_list2.is_empty():
		var list := []
		for terrain in terrain_list2:
			list.append(Vector2(terrain[0], terrain[1]))
		map.set_cells_terrain_connect(1, list, 3, 0, false)
	
	var used = map.get_used_rect()
	var tileSize = map.tile_set.tile_size
	camera.limit_top = used.position.y * tileSize.y
	camera.limit_left = used.position.x * tileSize.y
	camera.limit_right = used.end.x * tileSize.x
	camera.limit_bottom = used.end.y * tileSize.y
	
	if Global.isNew:
		add_body(get_node("People"), load("res://2D/character/player.tscn").instantiate(), "isLand")
		for index in range(Global.peopleAmount):
			call_deferred("add_body", get_node("People"), npc.instantiate(), "isLand")
			#add_body(get_node("People"), npc.instantiate(), "isLand")
			if index % 5 == 0:
				call_deferred("add_body", get_node("Animals"), dog.instantiate(), "isLand")
				call_deferred("add_body", get_node("Monster"), monsters.pick_random().instantiate(), "isLand")
				#add_body(get_node("Animals"), dog.instantiate(), "isLand")
				#add_body(get_node("Monster"), monsters.pick_random().instantiate(), "isLand")
			call_deferred("add_body", get_node("Envir"), stone.instantiate(), "isSand")
			call_deferred("add_body", get_node("Animals"), herbivores.instantiate(), "isGrass")
			#add_body(get_node("Envir"), stone.instantiate(), "isSand")
			#add_body(get_node("Animals"), herbivores.instantiate(), "isGrass")
		
	else:
		var peopleData = data.get("people")
		var people : People
		for key in peopleData.keys():
			if key == "Player":
				people = load("res://2D/character/player.tscn").instantiate()
			else:
				people = npc.instantiate()
			get_node("People").add_child(people)
			people.global_position = Vector2(peopleData.get(key).get("position")[0], peopleData.get(key).get("position")[1])
			people.hpMax = peopleData.get(key).get("hpMax")
			people.hp = peopleData.get(key).get("hp")
			people.hvMax = peopleData.get(key).get("hvMax")
			people.hv = peopleData.get(key).get("hv")
			
			people.sprite.texture = load(peopleData.get(key).get("sprite"))
			people.cName = peopleData.get(key).get("name")
			people.age = peopleData.get(key).get("age")
			people.speed = peopleData.get(key).get("speed")
			people.attackValue = peopleData.get(key).get("attackValue")
			people.lv = peopleData.get(key).get("lv")
			people.natures = peopleData.get(key).get("natures")
			people.goblinKill = peopleData.get(key).get("goblinKill")
			people.slimeKill = peopleData.get(key).get("slimeKill")
			people.npcKill = peopleData.get(key).get("npcKill")
			people.animalKill = peopleData.get(key).get("animalKill")
			people.nowExp = peopleData.get(key).get("nowExp")

			people.call_deferred("update_panel")
			people.inventory.clear()
			for slot in peopleData.get(key).get("inventory"):
				people.inventory.add_item(load(slot.item), slot.quantity)
				
		var plantData = data.get("plant")
		var body : Plant
		for key in plantData.keys():
			body = plant.instantiate()
			get_node("Plants").add_child(body)
			body.global_position = Vector2(plantData.get(key).get("position")[0], plantData.get(key).get("position")[1])
			body.style = plantData.get(key).get("style")
			body.index = plantData.get(key).get("index")
			body.time = plantData.get(key).get("time")
			body.call_deferred("growing", body.index, body.style)
			
		var natureData = data.get("nature")
		var nature : Nature
		for key in natureData.keys():
			if key.split("_")[0] == "tree":
				nature = tree.instantiate()
			else:
				nature = stone.instantiate()
			get_node("Envir").add_child(nature)
			nature.global_position = Vector2(natureData.get(key).get("position")[0], natureData.get(key).get("position")[1])
			nature.state = natureData.get(key).get("state")
			nature.hpMax = natureData.get(key).get("hpMax")
		
		var monsterData = data.get("monster")
		var monster : Monster
		for key in monsterData.keys():
			if key.split("_")[0] == "goblin":
				monster = goblin.instantiate()
			elif key.split("_")[0] == "slime":
				monster = slime.instantiate()
			elif key.split("_")[0] == "zombie":
				monster = zombie.instantiate()
			get_node("Monster").add_child(monster)
			monster.global_position = Vector2(monsterData.get(key).get("position")[0], monsterData.get(key).get("position")[1])
			monster.isDead = monsterData.get(key).get("isDead")
			monster.hpMax = monsterData.get(key).get("hpMax")
			monster.speed = monsterData.get(key).get("speed")
			monster.attackValue = monsterData.get(key).get("attackValue")
			monster.lv = monsterData.get(key).get("lv")
			monster.nowExp = monsterData.get(key).get("nowExp")
			if monsterData.get(key).get("master"):
				for master in get_node("People").get_children():
					if master.name == monsterData.get(key).get("master"):
						monster.master = master
			monster.hp = monsterData.get(key).get("hp")
			
		var objectData = data.get("object")
		var object : Stuff
		for key in objectData.keys():
			var type = key.split("_")[0]
			if  type == "campFire":
				object = load("res://2D/objects/camp_fire.tscn").instantiate()
			elif type == "door":
				object = load("res://2D/objects/door.tscn").instantiate()
			elif type == "box":
				object = load("res://2D/objects/box.tscn").instantiate()
				object.inventory.clear()
				for slot in objectData.get(key).get("inventory"):
					object.inventory.add_item(load(slot.item), slot.quantity)
			get_node("Object").add_child(object)
			object.global_position = Vector2(objectData.get(key).get("position")[0], objectData.get(key).get("position")[1])
			for master in get_node("People").get_children():
					if master.name == objectData.get(key).get("master"):
						object.master = master
			
		var animalData = data.get("animal")
		var animal : Animal
		for key in animalData.keys():
			var type = key.split("_")[0]
			if type == "dog":
				animal = dog.instantiate()
			else:
				animal = herbivores.instantiate()
			get_node("Animals").add_child(animal)
			animal.global_position = Vector2(animalData.get(key).get("position")[0], animalData.get(key).get("position")[1])
			animal.type = type
			animal.initHp = animalData.get(key).get("initHp")
			animal.initSpeed = animalData.get(key).get("initSpeed")
			animal.lv = animalData.get(key).get("lv")
			animal.hp = animalData.get(key).get("hp")
			if animalData.get(key).get("master"):
				for master in get_node("People").get_children():
					if master.name == animalData.get(key).get("master"):
						animal.master = master
			
		var dropData = data.get("drop")
		var drop : Area2D
		for key in dropData.keys():
			drop = load("res://2D/objects/item_node.tscn").instantiate()
			get_node("Drops").add_child(drop)
			drop.global_position = Vector2(dropData.get(key).get("position")[0], dropData.get(key).get("position")[1])
			drop.generate(load(dropData.get(key).get("item")))
	
	
	for child in get_node("People").get_children():
		child.click.connect(people_camera)

	$Timer.timeout.connect(func(): if !isBoss: dayLight+=lightValue)
	
	await get_tree().process_frame
	player = get_node("People").get_node_or_null("Player")
	if player:
		player.dead.connect(player_camera)
	else:
		$Camera2D.enabled = true
		
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_game()
		Global.save_history()
		$CanvasLayer/GameMenu.visible = !$CanvasLayer/GameMenu.visible
		show_warn("游戏保存成功！")


func show_warn(text):
	var warn = load("res://2D/ui/warn.tscn").instantiate()
	$CanvasLayer.add_child(warn)
	warn.show_text(text)

func get_world_size():
	if !map:
		return
	var used = map.get_used_rect()
	var tileSize = map.tile_set.tile_size
	return [Vector2(used.position.x * tileSize.y, used.position.y * tileSize.y), 
		Vector2(used.end.x * tileSize.x, used.end.y * tileSize.y)]
	
	
func add_body(node:Node2D, body:Node2D, sign, random=Vector2.ZERO):
	var x
	var y
	if !random:
		x = randi_range(camera.limit_left+100, camera.limit_right-100)
		y = randi_range(camera.limit_top+100, camera.limit_bottom-100)
	else:
		x = randi_range(random.x-200, random.x+200)
		y = randi_range(random.y-200, random.y+200)
	
	var tilePos = map.local_to_map(Vector2(x, y))
	var dictKey := "%s%s"%[tilePos.x, tilePos.y]
	var data : TileData = map.get_cell_tile_data(0, tilePos)
	
	if !data:
		call_deferred("add_body", node, body, sign, random)
		#add_body(node, body, sign, random)
		return
	
	var map_data = update_data()
	
	var canGenerate := true
	if map_data.has(dictKey) and map_data.get(dictKey) != 0:
		canGenerate = false
	
	if data.get_custom_data(sign) and canGenerate:
		node.call_deferred("add_child", body)
		body.set_deferred("global_position", Vector2(x, y))
	else :
		call_deferred("add_body", node, body, sign, random)
		#add_body(node, body, sign)
	
func update_data():
	var dict := {}
	#map_data.clear()
	var people = get_tree().get_nodes_in_group("people")
	var plants = get_tree().get_nodes_in_group("plant")
	var monster = get_tree().get_nodes_in_group("monster")
	var nature = get_tree().get_nodes_in_group("nature")
	var object = get_tree().get_nodes_in_group("object")
	var list = people + plants + monster + nature + object
	for body in list:
		var data = map.local_to_map(body.global_position)
		var key = "%s%s"%[data.x, data.y]
		if body.is_in_group("people") or body.is_in_group("monster"):
			dict[key] = Global.MAP_DATA.LIFE
			#map_data[key] = Global.MAP_DATA.LIFE
		elif body.is_in_group("nature"):
			dict[key] = Global.MAP_DATA.NATURE
			#map_data[key] = Global.MAP_DATA.NATURE
		elif body.is_in_group("plant"):
			dict[key] = Global.MAP_DATA.PLANT
			#map_data[key] = Global.MAP_DATA.PLANT
		elif body.is_in_group("object"):
			dict[key] = Global.MAP_DATA.OBJECT
			#map_data[key] = Global.MAP_DATA.OBJECT
	return dict


func people_camera(body):
	camera.offset = Vector2.ZERO
	camera.zoom = Vector2.ONE
	cameraTarget = body if cameraTarget == null else null


func player_camera(player):
	player.camera.enabled = false
	camera.enabled = true
	camera.offset = Vector2.ZERO
	camera.global_position = player.global_position

func _process(delta):
	if cameraTarget and is_instance_valid(cameraTarget):
		camera.global_position = cameraTarget.global_position

func _physics_process(delta):
	if isPress and not cameraTarget:
		currentPos = get_global_mouse_position()
		camera.offset -= currentPos - mousePos


func _input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.zoom += value
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.zoom -= value
		camera.zoom = clamp(camera.zoom, Vector2(0.2, 0.2), Vector2(2, 2))
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mousePos = get_global_mouse_position()
				isPress = true
			elif event.is_released():
				isPress = false
	if event.is_action_released("ui_cancel"):
		save_game()
		Global.save_history()
		show_warn("游戏保存成功！")
		$CanvasLayer/GameMenu.visible = !$CanvasLayer/GameMenu.visible


func generate_world(noiseTile: Noise, noiseEnvir: Noise):
	var tileDict = get_world_per(noiseTile)
	var envirDict = get_world_per(noiseEnvir)
	
	var dirts := []
	
	if Global.isNew:
		landPer = randf_range(0.4, 0.8)
		grassPer = min(0.3, landPer - randf_range(0.1, 0.3))
		dirtPer = min(0.1, grassPer - randf_range(0.1, 0.2))
	else:
		var data = load_game()
		var worldData = data.get("world")
		
		landPer = worldData.get("landPer")
		grassPer = worldData.get("grassPer")
		dirtPer = worldData.get("dirtPer")
	
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noiseTileVal = noiseTile.get_noise_2d(x, y)
			var noiseEnvirVal = noiseEnvir.get_noise_2d(x, y)
			if noiseTileVal < get_per(tileDict, landPer):
				#生成土地
				map.set_cell(LAYER_GROUND, Vector2(x, y), 0, tile_land.pick_random())
				if noiseTileVal < get_per(tileDict, landPer-0.05) and noiseTileVal > get_per(tileDict, grassPer+0.05) and noiseEnvirVal > get_per(envirDict, randf_range(0.75, 0.9)):
					map.set_cell(LAYER_ENVIR, Vector2i(x, y), 0, tile_trees.pick_random())
				if noiseTileVal < get_per(tileDict, grassPer):
					#生成草地
					map.set_cell(LAYER_GROUND, Vector2(x, y), 0, tile_grass.pick_random())
					if Global.isNew:
						if noiseEnvirVal > get_per(envirDict, randf_range(0.7, 0.9)) and noiseTileVal < get_per(tileDict, grassPer - 0.05) and noiseTileVal > get_per(tileDict, dirtPer + 0.05):
							var tree = preload("res://2D/nature/tree.tscn").instantiate()
							get_node("Envir").add_child(tree)
							tree.global_position = to_global(map.map_to_local(Vector2i(x, y)))
					if noiseTileVal < get_per(tileDict, dirtPer):
						#生成泥土
						dirts.append(Vector2i(x, y))
			else:
				#生成大海
				map.set_cell(LAYER_GROUND, Vector2i(x, y), 0, tile_sea)
	map.set_cells_terrain_connect(LAYER_GROUND, dirts, 0, 0)
	
func get_per(dict : Dictionary, per: float):
	var min = dict.min
	var max = dict.max
	var total = max - min
	return min + total * per

func get_world_per(noise : Noise):
	var list := []
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			list.append(noise.get_noise_2d(x, y))
	var dict := {}
	dict.min = list.min()
	dict.max = list.max()
	dict.total = list.max() - list.min()
	return dict


func save_game():
	var file := FileAccess.open(Global.SAVE_PATH, FileAccess.WRITE)
	var dataDict := {}
	
	var peopleDict := {}
	var worldDict := {}
	var plantDict := {}
	var monsterDict := {}
	var natureDict := {}
	var objectDict := {}
	var animalDict := {}
	var dropDict := {}
	
	for body:People in get_tree().get_nodes_in_group("people"):
		peopleDict[body.name] = {
			"position" : [body.global_position.x, body.global_position.y],
			"hpMax" : body.hpMax,
			"hp" : body.hp,
			"hvMax" : body.hvMax,
			"hv" : body.hv,
			"sprite" : body.sprite.texture.resource_path,
			"inventory" : body.get_item(),
			"age" : body.age,
			"name" : body.cName,
			"lv" : body.lv,
			"nowExp" : body.nowExp,
			"attackValue" : body.attackValue,
			"speed" : body.speed,
			"natures" : body.natures,
			"goblinKill" : body.goblinKill,
			"slimeKill" : body.slimeKill,
			"npcKill" : body.npcKill,
			"animalKill" : body.animalKill,
		}
	
	worldDict.size = [width, height]
	worldDict.seed = noiseTile.seed
	worldDict.frequency = noiseTile.frequency
	worldDict.fractal = noiseTile.fractal_octaves
	worldDict.landPer = landPer
	worldDict.grassPer = grassPer
	worldDict.dirtPer = dirtPer
	worldDict.dayLight = dayLight
	worldDict.day = day
	worldDict.cell_list = cell_list
	worldDict.terrain_list = terrain_list
	worldDict.terrain_list2 = terrain_list2
	worldDict.index = index
	
	for body in get_tree().get_nodes_in_group("plant"):
		plantDict[body.name] = {
			"position" = [body.global_position.x, body.global_position.y],
			"index" = body.index,
			"style" = body.style,
			"time" = body.timer.time_left,
		}
		
	for index in range(get_tree().get_nodes_in_group("nature").size()):
		var body :Nature = get_tree().get_nodes_in_group("nature")[index]
		natureDict[body.type + "_" + str(index)] = {
			"position" = [body.global_position.x, body.global_position.y],
			"state" = body.state,
			"hpMax" = body.hpMax,
		}
		
	
	for index in range(get_tree().get_nodes_in_group("monster").size()):
		var body = get_tree().get_nodes_in_group("monster")[index]
		monsterDict[body.type + "_" + str(index)] = {
			"position" = [body.global_position.x, body.global_position.y],
			"hpMax" = body.hpMax,
			"hp" = body.hp,
			"type" = body.type,
			"lv" = body.lv,
			"attackValue" = body.attackValue,
			"speed" = body.speed,
			"nowExp" = body.nowExp,
			"isDead" = body.isDead,
			"master" = body.masterName,
		}
		
	for index in range(get_tree().get_nodes_in_group("object").size()):
		var body = get_tree().get_nodes_in_group("object")[index]
		var inventory = null
		if body.has_method("get_item"):
			inventory = body.get_item()
		
		objectDict[body.type + "_" + str(index)] = {
			"position" = [body.global_position.x, body.global_position.y],
			"inventory" = inventory,
			"master" = body.masterName,
		}

	for index in range(get_tree().get_nodes_in_group("animal").size()):
		var body : Animal = get_tree().get_nodes_in_group("animal")[index]
		animalDict[body.type + "_" + str(index)] = {
			"position" = [body.global_position.x, body.global_position.y],
			"hp" = body.hp,
			"lv" = body.lv,
			"initSpeed" = body.initSpeed,
			"master" = body.masterName,
			"initHp" = body.initHp,
		}
		
			
	
	for body in get_tree().get_nodes_in_group("drop"):
		dropDict[body.name] = {
			"position" = [body.global_position.x, body.global_position.y],
			"item" = body.item.resource_path,
		}
	
	dataDict = {
		"world" : worldDict,
		"people" : peopleDict,
		"plant" : plantDict,
		"monster" : monsterDict,
		"nature" : natureDict,
		"object" : objectDict,
		"animal" : animalDict,
		"drop" : dropDict,
	}
	file.store_string(JSON.stringify(dataDict))
	file.close()


func load_game():
	if !FileAccess.file_exists(Global.SAVE_PATH):
		return
	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.READ)
	var data : Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	return data

func _on_monster_timer_timeout() -> void:
	if isBoss:
		return
		
	index += 1
	
	if index % 2 == 0:
		call_deferred("add_body", get_node("Object"), stone.instantiate(), "isSand")
		#add_body(get_node("Object"), stone.instantiate(), "isSand")
	if index % 3 == 0:
		call_deferred("add_body", get_node("Animals"), herbivores.instantiate(), "isGrass")
		#add_body(get_node("Animals"), herbivores.instantiate(), "isGrass")
		if randi_range(0, 5) == 1:
			call_deferred("add_body", get_node("Animals"), dog.instantiate(), "isLand")
			#add_body(get_node("Animals"), dog.instantiate(), "isLand")
	if index % 4 == 0:
		var enemies = get_node_or_null("Monster").get_children()
		enemies = enemies.filter(func(enemy): return !enemy.isDead)
		if enemies.size() < Global.worldSize / 10:
			call_deferred("add_body", get_node("Monster"), monsters.pick_random().instantiate(), "isLand")
		#add_body(get_node("Monster"), monsters.pick_random().instantiate(), "isLand")
	if index % 5 == 0:
		call_deferred("add_body", get_node("People"), npc.instantiate(), "isLand")
		#add_body(get_node("People"), npc.instantiate(), "isLand")
		
		
	
	
	#for i in range(1, 3): 
		#if enemies.size() > roundi(Global.worldSize / 10):
			#break
		#add_body(get_node("Monster"), monsters.pick_random().instantiate(), "isLand")
		#
	#var peoples = get_node_or_null("People").get_children().size()
	#for i in range(0, 2): 
		#if peoples > roundi(Global.worldSize / 10):
			#break
		#add_body(get_node("People"), npc.instantiate(), "isLand")
			#
	#var stones = get_tree().get_nodes_in_group("stone").size()
	#for i in range(0, 3):
		#if stones > roundi(Global.worldSize / 10):
			#break
		#add_body(get_node("Object"), stone.instantiate(), "isSand")
		#
	#var animals = get_tree().get_nodes_in_group("animal").size()
	#if randi_range(0, 3) == 2:
		#for index in randi_range(0, 2):
			#add_body(get_node("Animals"), dog.instantiate(), "isLand")
	#for i in range(0, 4):
		#if animals > roundi(Global.worldSize / 8):
			#break
		#add_body(get_node("Animals"), herbivores.instantiate(), "isGrass")
