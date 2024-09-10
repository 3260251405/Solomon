extends Label


func show_text(str: String):
	text = str
	var tween := get_tree().create_tween()
	#tween.tween_property(self, "position", position + Vector2(0, -30), 0.5)
	tween.parallel().tween_property(self, "modulate:a", 1, 0.5)
	tween.tween_property(self, "modulate:a", 0, 1)
	tween.tween_callback(queue_free)
