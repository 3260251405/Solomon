extends Node2D

@onready var map = $TileMap

var noise1 = FastNoiseLite.new()

var width := 150
var height := 150

var canGenerate := false
var test : People

var index := 0

var list := []:
	set(v):
		list = v
		print(list)

func _ready():
	noise1.seed = randi()
	Engine.time_scale = 2.0
	#$Herbivores.type = "hen"
	#var types := ["hen", "cow", "sheep", "rabbit"]
	#for type in types:
		#var animal = preload("res://2D/character/herbivores.tscn").instantiate()
		#add_child(animal)
		#animal.type = type
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		canGenerate = !canGenerate
	
func _process(delta):
	if canGenerate:
		generate_world($Player.global_position)
	
func get_random(value):
	print(floor((value+1)*2))
	return floor((value+1)*2)
	
func generate_world(position):
	var tile_pos = map.local_to_map(position)
	for w in range(width):
		for h in range(height):
			var x = tile_pos.x - width/2 + w
			var y = tile_pos.y - height/2 + h
			var noiseValue = noise1.get_noise_2d(x, y)
			var v = get_random(noiseValue)
			map.set_cell(0, Vector2i(x, y), 0, Vector2i(v, v))
