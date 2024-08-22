extends CharacterBody3D

@onready var navigation = $NavigationAgent3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var target = null

func _ready():
	target = get_parent().get_node("Player")
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	navigation.target_position = target.global_position
		
	if navigation.is_navigation_finished():
		return
	
	var direction = global_position.direction_to(navigation.get_next_path_position())

	if direction:
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
