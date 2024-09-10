extends StaticBody2D

class_name Stuff

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var type = "none"
var master : People = null:
	set(v):
		master = v
		if master:
			masterName = master.name
var masterName := ""
