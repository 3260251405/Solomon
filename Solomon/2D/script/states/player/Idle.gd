extends State

func enter():
	owner.direction = Vector2.ZERO
	if owner.anim:
		owner.anim.travel("Idle")


func input(event: InputEvent):
	if event.is_action_released("Attack") and owner.canAttack:
		change.emit("Attack")
		

func update(delta):
	if owner.isDead:
		change.emit("death")


func physics_update(delta):
	if owner.direction:
		change.emit("walk")
