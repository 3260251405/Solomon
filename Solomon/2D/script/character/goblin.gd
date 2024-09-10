extends Monster

func _ready() -> void:
	type = "goblin"
	
	initSpeed = randi_range(40, 60)
	initHp = randi_range(150, 200)
	initAttack = randi_range(20, 40)
	
	drops.append(preload("res://2D/tres/food/meat.tres"))
	super._ready()
	
	
func _on_hp_timer_timeout() -> void:
	if isDead:
		return
		
	if hp < hpMax:
		hp += ceili(hpMax / 100)
