extends Node2D

var currentState : State
var states : Dictionary
var dict := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.change.connect(change_state)
	currentState = states.get("idle")
	if currentState:
		currentState.enter()
	
	dict = {
		"idle" = "发呆",
		"walk" = "散步",
		"find" = "觅食"
	}

func _process(delta):
	if currentState:
		currentState.update(delta)
		
func _physics_process(delta):
	if currentState:
		currentState.physics_update(delta)
		
func _unhandled_input(event):
	if currentState:
		currentState.input(event)

func change_state(nextState: String):
	var state = states.get(nextState)
	if not state:
		return
	if currentState:
		currentState.exit()
	currentState = state
	currentState.enter()
