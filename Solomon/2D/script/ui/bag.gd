extends PanelContainer

var inventory : Inventory
var slotLoad = preload("res://2D/inventory/slot.tscn")

var master

func _ready():
	if owner and owner is People:
		master = owner
	else:
		master = get_owner3(get_parent())
		
	inventory = master.inventory
	for index in inventory.slots.size():
		var slot = slotLoad.instantiate()
		slot.isBag = true
		$MarginContainer/GridContainer.add_child(slot)
		slot_update(index)
	inventory.change.connect(update)
	
	

func get_owner3(node):
	if node is People:
		return node
	return get_owner3(node.get_parent())


func slot_update(index):
	var slot = $MarginContainer/GridContainer.get_child(index)
	var data = inventory.slots[index]
	slot.update(data)


func update(indexes):
	for index in indexes:
		slot_update(index)


func _can_drop_data(at_position, data):
	return data and data.slot

func _drop_data(at_position, data):
	var slot : Slot = data.slot
	inventory.set_item(slot.item, slot.quantity, data.index)
