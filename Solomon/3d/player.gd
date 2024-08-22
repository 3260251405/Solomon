extends CharacterBody3D


const SPEED = 5.0
const CROUCH_SPEED = 2.0
const JUMP_VELOCITY = 8

var gravity = 24.8
var speed
var isCrouch = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta):
	speed = CROUCH_SPEED if isCrouch else SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if isCrouch:
			isCrouch = false
			$AnimationPlayer.play("stand")
		
	if Input.is_action_pressed("Crouch"):
		if not isCrouch:
			isCrouch = true
			$AnimationPlayer.play("crouch")
	else:
		if isCrouch:
			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position+Vector3(0, 2, 0), 1, [self]))
			if result.size() == 0:
				isCrouch = false
				$AnimationPlayer.play("stand")


	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * 0.005)
		$Camera3D.rotate_x(-event.relative.y * 0.005)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	if event.is_action_pressed("F"):
		$Camera3D/Flash/SpotLight3D.visible = !$Camera3D/Flash/SpotLight3D.visible
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
