extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer

var isGrown : bool
var style = "tomato"
var index = 0

var dict := {}

func _ready():
	isGrown = false
	var path = "res://2D/inventory/items/"
	var files = DirAccess.open(path)
	if files:
		for file in files.get_files():
			dict[file.split(".")[0]] = path + file
	var timer = get_tree().create_timer(5)
	timer.timeout.connect(growing.bind(0))

	
func growing(index):
	var animation : SpriteFrames = sprite.sprite_frames
	var count = animation.get_frame_count(style)
	if index == 0:
		sprite.animation = style
		sprite.stop()
	sprite.frame = index
	if sprite.frame >= sprite.sprite_frames.get_frame_count(style) - 1:
		isGrown = true
		return
	else:
		await get_tree().create_timer(5 * (index + 1)).timeout
		growing(index+1)

		
func _on_timer_timeout():
	growing(0)

func pick(body):
	if not isGrown:
		return
	body.inventory.add_item(load(dict[style]), 1)
	body.inventory.add_item(load(dict["seed_"+style]), randi_range(0, 2))
	queue_free()
