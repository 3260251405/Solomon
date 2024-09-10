extends Area2D

class_name Plant

@onready var sprite = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var totalTime : int = 0
var time : int = 0

var isGrown : bool = false
var style = "tomato"

var index := -1

var dict := {}


func _ready():
	var foodPath = "res://2D/tres/food/"
	var seedPath = "res://2D/tres/seed/"
	var paths := [foodPath, seedPath]
	for path in paths:
		var files = DirAccess.open(path)
		if files:
			for file in files.get_files():
				dict[file.split(".")[0]] = load(path + file.split(".")[0] + "." + file.split(".")[1])
	sprite.stop()
	

func growing(i, type):
	index = i
	style = type
	var animation : SpriteFrames = sprite.sprite_frames
	var count = animation.get_frame_count(style)
	
	if index >= 0:
		sprite.animation = style
		
	sprite.frame = index
	if sprite.frame >= sprite.sprite_frames.get_frame_count(style) - 1:
		isGrown = true
		return
	else:
		totalTime = 50 * (index + 2)
		if timer.timeout.is_connected(growing.bind(index+1, type)):
			timer.timeout.disconnect(growing.bind(index+1, type))
		timer.timeout.connect(growing.bind(index+1, type))
		var value = totalTime if time == 0 else time
		timer.start(totalTime)


func pick(body: People):
	if isGrown:
		body.inventory.add_item(dict.get(style), floori(randf_range(1, 2)))
		body.inventory.add_item(dict.get("seed_"+style), floori(randf_range(0, 2)))
		queue_free()
		return true
	else:
		return false
