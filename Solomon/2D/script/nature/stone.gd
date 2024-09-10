extends Nature

func _ready() -> void:
	super._ready()
	
	type = "stone"
	item = preload("res://2D/tres/material/stone.tres")
	
	sprite.stop()
	var spriteFrame : SpriteFrames = sprite.sprite_frames

	var count = spriteFrame.get_frame_count("default")
	
	sprite.frame = randi_range(0, count)


func die():
	drop(item, quantity, false)

	queue_free()
