extends State

func enter():
	await get_tree().create_timer(randf_range(1, 3)).timeout
	change.emit()
