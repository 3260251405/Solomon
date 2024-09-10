extends TouchScreenButton

const DRAG_RADIUS := 50.0

var finger_index := -1
var restPos 
var dragOffset : Vector2

func _ready() -> void:
	restPos = global_position

func _input(event: InputEvent) -> void:
	var st := event as InputEventScreenTouch
	if st:
		if st.pressed and finger_index == -1:
			var globalPos := st.position * get_canvas_transform()
			var localPos := to_local(globalPos)
			var rect := Rect2(Vector2.ZERO, texture_normal.get_size())
			if rect.has_point(localPos):
				finger_index = st.index
				dragOffset = globalPos - global_position
		elif not st.pressed and st.index == finger_index:
			Input.action_release("left")
			Input.action_release("right")
			Input.action_release("up")
			Input.action_release("down")
			finger_index = -1
			global_position = restPos
				
	var sd := event as InputEventScreenDrag
	if sd and sd.index == finger_index:
		var wishPos := sd.position * get_canvas_transform() - dragOffset
		var move = (wishPos - restPos).limit_length(DRAG_RADIUS)
		global_position = restPos + move
		
		move /= DRAG_RADIUS
		if move.x < 0:
			Input.action_release("left")
			Input.action_press("left", -move.x)
		elif move.x > 0:
			Input.action_release("right")
			Input.action_press("right", move.x)
		if move.y < 0:
			Input.action_release("up")
			Input.action_press("up", -move.y)
		elif move.y > 0:
			Input.action_release("down")
			Input.action_press("down", move.y)
