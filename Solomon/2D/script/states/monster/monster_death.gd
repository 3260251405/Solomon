extends State

func enter():
	owner.anim.travel("Death")
	owner.direction = Vector2.ZERO
	
	owner.hateBodies.clear()
	owner.hateBody = null
	
	if owner.type == "slime":
		if randi_range(0, 3) == 1:
			for index in randi_range(0, 2):
				var slime = load("res://2D/character/monsters/slime.tscn").instantiate()
				owner.get_parent().add_child(slime)
				slime.global_position = owner.global_position + Vector2(randi_range(-10, 10), randi_range(-10, 10))

	await get_tree().create_timer(40).timeout
	owner.queue_free()
