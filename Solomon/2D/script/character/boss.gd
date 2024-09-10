extends Monster

class_name Boss

func _ready():
	type = "goblinKing"
	
	initSpeed = 10
	initHp = 1000
	initAttack = 10
	
	super._ready()
	
	lv = world.day
	
	scale = Vector2(2, 2)
	
	emit_isBoss(true)
	$HpTimer.timeout.connect(func(): if !isDead and hp < hpMax: hp += hpMax/100)
	

func emit_isBoss(boolean):
	world.signal_isBoss.emit(boolean)
