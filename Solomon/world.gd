extends Node2D

@onready var map = $TileMap
@onready var camera = $Camera2D
@onready var option_button = $CanvasLayer/OptionButton

@export var noiseTileTexture : NoiseTexture2D
@export var noiseEnvirTexture : NoiseTexture2D
@export var noisePeopleTexture : NoiseTexture2D

const LAYER_GROUND := 0
const LAYER_ENVIR := 1

var tile_land := []
var tile_grass := []
var tile_sea := Vector2i(0, 1)
var tile_trees := [Vector2i(12, 2), Vector2i(15, 2)]

var width := 100
var height := 100

var value = Vector2(0.05, 0.05)
var mousePos
var currentPos
var isPress : bool

var cameraTarget : People = null

var lightValue := 8 / 5 * 0.1 / 60
var dayLight : float = 0.0:
	set(v):
		dayLight = v
		clampf(dayLight, 0, 0.85)
		$DirectionalLight2D.energy = dayLight
		if dayLight <= 0:
			lightValue = abs(lightValue)
		elif dayLight >= 0.85:
			lightValue *= -1

func _ready():
	for index in range(6):
		tile_grass.append(Vector2i(index, 0))
		if index >= 3:
			continue
		tile_land.append(Vector2i(index + 6, 0))
		
	var noiseTile = noiseTileTexture.noise
	var noiseEnvir = noiseEnvirTexture.noise
	var noisePeople = noisePeopleTexture.noise
	noiseTile.seed = randi()
	noiseEnvir.seed = randi()
	noisePeople.seed = randi()
	noiseTile.fractal_octaves = randi_range(1, 5)
	noiseTile.frequency = randf_range(0.01, 0.05)
	generate_world(noiseTile, noiseEnvir, noisePeople)
	
	var used = map.get_used_rect()
	var tileSize = map.tile_set.tile_size
	camera.limit_top = used.position.y * tileSize.y
	camera.limit_left = used.position.x * tileSize.y
	camera.limit_right = used.end.x * tileSize.x
	camera.limit_bottom = used.end.y * tileSize.y
	
	for child in get_node("People").get_children():
		child.dead.connect(update)
		child.click.connect(people_camera)
	update()
	
	option_button.add_item("0.5")
	option_button.add_item("1.0")
	option_button.add_item("1.5")
	option_button.add_item("2.0")
	option_button.add_item("5.0")
	option_button.add_item("0.0")
	option_button.select(1)
	
	
	add_body(preload("res://2D/character/player.tscn").instantiate())
	
	$Timer.timeout.connect(func(): dayLight+=lightValue)
	
func add_body(body: Node2D):
	var x := randi_range(-800, 800)
	var y := randi_range(-800, 800)
	body.global_position = Vector2(x, y)
	var data : TileData = map.get_cell_tile_data(0, map.local_to_map(body.global_position))
	
	
	var people = get_tree().get_nodes_in_group("people")
	var trees = get_tree().get_nodes_in_group("food")
	var list = people + trees
	var existList
	var canCreate
	
	
	if people and trees:
		existList = list.filter(func(body2): return body2.global_position.distance_to(body.global_position) < 5)
	
	if data:
		canCreate = !data.get_custom_data("isSea") and existList.size() <= 0
	
	if canCreate:
		add_child(body)
	else :
		add_body(body)

func people_camera(body):
	camera.offset = Vector2.ZERO
	camera.zoom = Vector2.ONE
	cameraTarget = body if cameraTarget == null else null

func update():
	var list = get_node("People").get_children()
	$CanvasLayer/Label.text = "人类存活数量：%s"%list.size()
	
func _process(delta):
	if cameraTarget:
		if is_instance_valid(cameraTarget):
			camera.global_position = cameraTarget.global_position

func _physics_process(delta):
	if isPress and not cameraTarget:
		currentPos = get_global_mouse_position()
		camera.offset -= currentPos - mousePos

func _unhandled_input(event):
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
	if event.is_action_released("ui_accept"):
		get_viewport().get_texture().get_image().save_png("D://ScreenShot.png")

func generate_world(noiseTile: Noise, noiseEnvir: Noise, noisePeople: Noise):
	var tileDict = get_world_per(noiseTile)
	var envirDict = get_world_per(noiseEnvir)
	var peopleDict = get_world_per(noisePeople)
	
	var dirts := []
	
	var landPer = randf_range(0.4, 0.8)
	var grassPer = min(0.3, landPer - randf_range(0.1, 0.3))
	var dirtPer = min(0.1, grassPer - randf_range(0.1, 0.2))
	
	var peoplePer = randf_range(0.01, 0.15)
	
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noiseTileVal = noiseTile.get_noise_2d(x, y)
			var noiseEnvirVal = noiseEnvir.get_noise_2d(x, y)
			var noisePeopleVal = noisePeople.get_noise_2d(x, y)
			if noiseTileVal < get_per(tileDict, landPer):
				#生成土地
				map.set_cell(LAYER_GROUND, Vector2(x, y), 0, tile_land.pick_random())
				if noisePeopleVal < get_per(peopleDict, peoplePer):
					var people = preload("res://2D/character/npc.tscn").instantiate()
					get_node("People").add_child(people)
					people.global_position = map.map_to_local(Vector2i(x, y))
				if noiseTileVal < get_per(tileDict, landPer-0.05) and noiseTileVal > get_per(tileDict, grassPer+0.05) and noiseEnvirVal > get_per(envirDict, randf_range(0.75, 0.9)):
					map.set_cell(LAYER_ENVIR, Vector2i(x, y), 0, tile_trees.pick_random())
				if noiseTileVal < get_per(tileDict, grassPer):
					#生成草地
					map.set_cell(LAYER_GROUND, Vector2(x, y), 0, tile_grass.pick_random())
					if noiseEnvirVal > get_per(envirDict, randf_range(0.7, 0.9)) and noiseTileVal < get_per(tileDict, grassPer - 0.05) and noiseTileVal > get_per(tileDict, dirtPer + 0.05):
						var tree = preload("res://2D/objects/tree.tscn").instantiate()
						get_node("Envir").add_child(tree)
						tree.global_position = map.map_to_local(Vector2i(x, y))
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

func plant():
	var mousePos = get_global_mouse_position()
	var tilePos = map.local_to_map(mousePos)
	var data : TileData = map.get_cell_tile_data(1, tilePos)
	var plants = get_tree().get_nodes_in_group("plant")
	var crops = plants.filter(func(crop): return mousePos.distance_squared_to(crop.global_position) < pow(17, 2))
	if data:
		var canPlant = data.get_custom_data("canPlant")
		if canPlant and crops.size() <= 0:
			var crop = preload("res://2D/objects/plant.tscn").instantiate()
			add_child(crop)
			crop.global_position = map.map_to_local(tilePos)
			


func _on_option_button_item_selected(index):
	Engine.time_scale = float(option_button.get_item_text(index))
	print(Engine.time_scale)
