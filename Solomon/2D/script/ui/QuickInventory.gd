extends PanelContainer

var inventory : Inventory
var slotLoad = preload("res://2D/inventory/slot.tscn")

func _ready():
	inventory = owner.inventory
	for index in range(9):
		var slot = slotLoad.instantiate()
		slot.isBag = false
		$MarginContainer/HBoxContainer.add_child(slot)
		slot_update(index)
	inventory.change.connect(update)


func slot_update(index):
	var slot = $MarginContainer/HBoxContainer.get_child(index)
	if !slot:
		return
	var data = inventory.slots[index]
	slot.update(data)


func update(indexes):
	for index in indexes:
		slot_update(index)
