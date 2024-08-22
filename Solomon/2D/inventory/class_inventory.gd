extends Resource

class_name Inventory

signal change

@export var slots : Array[Slot]


func add_item(item: Item, quantity: int):
	var index = -1
	var slot = slots.filter(func(slot): return slot.item == item)
	if not slot.is_empty():
		slot[0].quantity += quantity
		index = slots.find(slot[0])
	else:
		var emptySlots = slots.filter(func(slot): return slot.item == null)
		if not emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].quantity = quantity
			index = slots.find(emptySlots[0])
	change.emit([index])
	
func use_item(index: int):
	var slot = slots[index]
	var temp_item = null
	if slot.item:
		temp_item = slot.item
		if slot.quantity > 1:
			slot.quantity -= 1
			change.emit([index])
		else:
			remove_item(index)
	return temp_item
	
func find_item(index: int):
	var slot = slots[index]
	if slot.item:
		return slot.item
	
func remove_item(index):
	slots[index].item = null
	slots[index].quantity = 0
	change.emit([index])
	
