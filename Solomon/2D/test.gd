extends Node2D

@onready var map = $TileMap
@onready var camera = $Camera2D

@export var noiseTexture : NoiseTexture2D
@export var noiseTreeTexture : NoiseTexture2D
@export var noisePeopleTexture : NoiseTexture2D

var noise : Noise
var noiseTree : Noise
var noisePeople : Noise

var width := 100
var height := 100

var sands := []
var grasses := []
var dirts := []
var trees := []

var grassesRand := []

var value = Vector2(0.1, 0.1)
var mousePos
var currentPos
var isPress : bool

var quantity := 0
var second := 0

func _physics_process(delta):
	if isPress:
		currentPos = get_global_mouse_position()
		camera.offset -= currentPos - mousePos
	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.zoom += value
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.zoom -= value
		camera.zoom = clamp(camera.zoom, Vector2(0.3, 0.3), Vector2(2, 2))
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mousePos = get_global_mouse_position()
				isPress = true
			elif event.is_released():
				isPress = false

func _ready():
	noise = noiseTexture.noise
	noise.seed = randi()
	noise.frequency = randf_range(0.01, 0.05)
	noise.fractal_octaves = randi_range(1, 5)
	noiseTree = noiseTreeTexture.noise
	noisePeople = noisePeopleTexture.noise
	for index in range(5):
		grassesRand.append(Vector2i(index, 0))
	generate_world()
	
	
	
func generate_world():
	var list := []
	var tileList := []
	var tileMin
	var tileMax
	var tiles
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noiseVal = noise.get_noise_2d(x, y)
			tileList.append(noiseVal)
	tileMax = tileList.max()
	tileMin = tileList.min()
	tiles = tileMax - tileMin
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noiseVal = noise.get_noise_2d(x, y)
			var treeVal = noiseTree.get_noise_2d(x, y)
			var peopleVal = noisePeople.get_noise_2d(x, y)
			if noiseVal > tileMax - tiles * 0.4:
				map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 1))
				if noiseVal > tileMax - tiles * 0.1:
					map.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 0))
			else :
				map.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 0))
				if noiseVal < tileMax - tiles * 0.65:
					grasses.append(Vector2i(x, y))
				if noiseVal < tileMax - tiles * 0.9:
					dirts.append(Vector2i(x, y))
			if treeVal > 0.8:
				if noiseVal < tileMax - tiles * 0.4 and noiseVal > tileMax - tiles * 0.6:
						map.set_cell(1, Vector2i(x, y), 0, [Vector2i(12, 2), Vector2i(15, 2)].pick_random())
				if noiseVal < tileMax - tiles * 0.65 and noiseVal > tileMax - tiles * 0.9:
						var tree = preload("res://2D/objects/tree.tscn").instantiate()
						add_child(tree)
						tree.global_position = map.map_to_local(Vector2i(x, y))
			
			
	print("total: ", tiles)
	print("max: ", tileMax)
	print("min: ", tileMin)
	print(tileMax - tiles * 0.1)
	map.set_cells_terrain_connect(0, grasses, 1, 0)
	map.set_cells_terrain_connect(0, dirts, 0, 0)
	
func generate_object(object: Node2D, x, y):
	add_child(object)
	object.global_position = map.map_to_local(Vector2i(x, y))
