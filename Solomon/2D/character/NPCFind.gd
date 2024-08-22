extends State

var target = null
var agent : NavigationAgent2D

var selfEat := false

func _ready():
	await owner._ready
	owner.enter.connect(find_food)
	agent = owner.get_node("NavigationAgent2D")

func enter():
	find_food()
	await get_tree().create_timer(10).timeout
	emit_signal("change", owner.states.pick_random())
	
func update(delta):
	if target:
		if not is_instance_valid(target):
			if !selfEat:
				owner.show_exp("angry")
			emit_signal("change", owner.states.pick_random())
			return
		agent.target_position = target.global_position
		agent.target_position = agent.get_final_position()
		if not agent.is_navigation_finished():
			owner.direction = owner.global_position.direction_to(agent.get_next_path_position())
			agent.velocity = owner.direction * owner.speed
		else:
			if target.pick(owner) == false:
				owner.show_exp("unhappy")
				selfEat = false
			else :
				owner.show_exp("happy")
				selfEat = true
			emit_signal("change", owner.states.pick_random())
			
func find_food():
	if get_parent().currentState.name.to_lower() != "find":
		return
	var foodBodies = owner.foodBodies
	var findBodies = owner.findBodies

	findBodies = findBodies.filter(check_instance)
	foodBodies = foodBodies.filter(check_instance)
	if findBodies.size() > 0:
		findBodies.sort_custom(func(a,b): return a.global_position.distance_to(owner.global_position) < b.global_position.distance_to(owner.global_position))
		target = findBodies[0]
		owner.show_exp("sex")
	else:
		if foodBodies.size() > 0:
			foodBodies.sort_custom(func(a, b): return a.global_position.distance_to(owner.global_position) < b.global_position.distance_to(owner.global_position))
			target = foodBodies[0]
			owner.show_exp("far")
		else :
			change.emit(owner.states.pick_random())
			owner.show_exp("no")
			
func check_instance(body):
	if is_instance_valid(body):
		return body.isGrown
