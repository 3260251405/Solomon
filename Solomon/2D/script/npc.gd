extends "res://2D/script/people.gd"

signal enter
signal tt

var states = ["idle", "walk", "find"]

var findBodies = []
var foodBodies := []

var target : Node2D = null

var grownBodies


func  _ready():
	super._ready()
	var list := []
	var files = DirAccess.open("res://assets/rpg/")
	if files:
		for file in files.get_files():
			list.append(load("res://assets/rpg/"+file.split(".")[0]+".png"))
	
	sprite.texture = list.pick_random()
	speed = randf_range(50, 100)
	scale = Vector2(0.8, 0.8)
	
	tt.connect(test)


func _process(delta):
	if hv < 80:
		var data = can_use(0)
		if data:
			use(data.index, data.item)
	var data = can_use(1)
	if data:
		use(data.index, data.item)
		
func can_use(style):
	var slots = inventory.slots.filter(func(slot): return slot.item is Item)
	if slots.size() <= 0:
		return
	var foodSlots = slots.filter(func(slot): return slot.item.style == style)
	if foodSlots.size() <= 0:
		return
	var index = inventory.slots.find(foodSlots[0])
	var item = inventory.find_item(index)
	if item:
		var data := {}
		data.index = index
		data.item = item
		return data
		
func interact2():
	pass
	
func _on_find_area_area_entered(area):
	var body = area.owner if area.owner else area
	if body.is_in_group("food"):
		if not body in findBodies:
			findBodies.append(body)
		if not body in foodBodies:
			foodBodies.append(body)
		enter.emit()


func _on_find_area_area_exited(area):
	var body = area.owner if area.owner else area
	if body in findBodies:
		findBodies.erase(body)


func _on_interace_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("isCrazy:%s\nstate:%s"%[isCrazy, get_node("StateMachine").currentState.name])
			print("----------------------------------")
		if event.button_index == MOUSE_BUTTON_RIGHT:
			update_panel()
			panel.visible = !panel.visible
			click.emit(self)
			
func test():
	print("!")


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity


func _on_hurt_box_hurt(hitbox):
	pass
