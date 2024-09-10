extends Monster

func _ready() -> void:
	type = "zombie"

	initSpeed = randi_range(30, 50)
	initHp = randi_range(100, 200)
	initAttack = randi_range(10, 30)
	
	scale = Vector2(0.8, 0.8)
	
	super._ready()
	

func day_logic():
	if isNight:
		speed = initSpeed + lv * 5 + 100
		attackValue = initAttack + lv * 10 + 30
	else:
		speed = initSpeed + lv * 5
		attackValue =initAttack + lv * 10


func _on_hit_box_hit(hurtbox: Variant) -> void:
	if hurtbox.owner is People:
		hurtbox.owner.zombieVirus = true
