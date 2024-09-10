extends State

func enter():
	owner.canWalk = false
	owner.direction = Vector2.ZERO
	owner.anim.travel("Attack")
	
	owner.play_sound("Sword")
	
	await get_tree().create_timer(0.5).timeout
	if !owner.isDead:
		change.emit("idle")

func update(delta):
	if owner.isDead:
		change.emit("death")


func exit():
	owner.canWalk = true
