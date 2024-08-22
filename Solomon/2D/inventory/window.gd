extends MarginContainer

@onready var container = $MarginContainer/ScrollContainer/GridContainer

var inventory

func _ready():
	await owner._ready()
	inventory = owner.inventory
	if not inventory:
		return
	for index in inventory.slots.size():
		container.add_child(preload("res://2D/inventory/slot.tscn").instantiate())
		slot_update(index)
	inventory.change.connect(update)

		
func slot_update(index):
	var slot = container.get_child(index)
	var data = inventory.slots[index]
	slot.update(data)
	
func update(indexes):
	for index in indexes:
		slot_update(index)
