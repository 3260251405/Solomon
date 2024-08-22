extends Node2D

@onready var map = $TileMap

var noise1 = FastNoiseLite.new()

var width := 150
var height := 150

func _ready():
	noise1.seed = randi()
	
func _process(delta):
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
