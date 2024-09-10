extends Monster

func _ready() -> void:
	type = "slime"
	
	initSpeed = randi_range(110, 130)
	initHp = randi_range(80, 120)
	initAttack = randi_range(10, 30)
	
	super._ready()
