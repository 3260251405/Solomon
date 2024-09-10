extends State

func enter():
	owner.anim.travel("Walk")

func physics_update(delta):
	if !owner.direction:
		change.emit("Idle")
		
func update(delta):
	if owner.isDead:
		change.emit("death")
		return
	if owner.isTalking:
		change.emit("Idle")
		
func input(event: InputEvent):
	if event.is_action_released("Attack") and owner.canAttack:
		change.emit("Attack")
