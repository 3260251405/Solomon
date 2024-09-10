extends PanelContainer

@onready var container = $MarginContainer/ScrollContainer/GridContainer

var inventory
var slotLoad = preload("res://2D/inventory/slot.tscn")

func _ready():
	if !owner is People || !owner is Stuff:
		owner = get_onwer(owner)

	inventory = owner.inventory
	if not inventory:
		return
	for index in inventory.slots.size():
		var slot = slotLoad.instantiate()
		slot.isBag = true
		container.add_child(slot)
		slot_update(index)
	inventory.change.connect(update)
	
func get_onwer(body):
	if body is People || body is Stuff:
		return body
	return get_onwer(body.get_parent())

		
func slot_update(index):
	var slot = container.get_child(index)
	var data = inventory.slots[index]
	slot.update(data)
	
func update(indexes):
	for index in indexes:
		slot_update(index)
