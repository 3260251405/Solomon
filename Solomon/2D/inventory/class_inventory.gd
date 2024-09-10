extends Resource

class_name Inventory

signal change
signal haveSeed
signal haveFood

@export var slots : Array[Slot]

func add_item(item: Item, quantity: int):
	var index = -1
	var usedSlots = slots.filter(func(slot): return slot.item == item and slot.item.stackable and slot.quantity < slot.item.maxStack)
	if not usedSlots.is_empty():
		
		usedSlots[0].quantity += quantity
		index = slots.find(usedSlots[0])
	else:
		var emptySlots = slots.filter(func(slot): return slot.item == null)
		if not emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].quantity = quantity
			index = slots.find(emptySlots[0])
		else:
			return false
	check_inventory()
	change.emit([index])
	return true
	
	
func set_item(item: Item, quantity, index):
	slots[index].item = item
	slots[index].quantity = quantity
	change.emit([index])


func use_item(index: int, quantity: int):
	var slot = slots[index]
	var temp_item = null
	if slot.item:
		temp_item = slot.item
		if slot.quantity > quantity:
			slot.quantity -= quantity
			change.emit([index])
		else:
			remove_item(index)
	return temp_item


func get_all_item():
	var dict := {}
	var fullSlots = slots.filter(func(slot): return slot.item is Item)
	if fullSlots.is_empty():
		return
	for slot:Slot in fullSlots:
		dict[slot.item.resource_path] = slot.quantity
	return dict


func find_item(index: int):
	var slot = slots[index]
	if slot.item:
		return slot.item


func remove_item(index):
	var slot = slots[index].duplicate()
	slots[index].item = null
	slots[index].quantity = 0
	check_inventory()
	change.emit([index])
	return slot


func clear():
	for index in slots.size():
		if slots[index].item is Item:
			remove_item(index)


func check_inventory():
	var fullSlots = slots.filter(func(slot): return slot.item is Item)
	if fullSlots.is_empty():
		haveSeed.emit(false)
		haveFood.emit(false)
		return
	var seedSlots = fullSlots.filter(func(slot): return slot.item.style == 1)
	if seedSlots.is_empty():
		haveSeed.emit(false)
	else:
		haveSeed.emit(true)
	var foodSlots = fullSlots.filter(func(slot): return slot.item.style == 0)
	if foodSlots.is_empty():
		haveFood.emit(false)
	else:
		haveFood.emit(true)


func have_item(item: Item, quantity: int):
	var fullSlots = slots.filter(func(slot): return slot.item is Item)
	if fullSlots.is_empty():
		return null
	var itemSlots = fullSlots.filter(func(slot): return slot.item == item)
	if itemSlots.is_empty():
		return null
	var quantitySlots = itemSlots.filter(func(slot): return slot.quantity >= quantity)
	if quantitySlots.is_empty():
		return null
	return slots.find(quantitySlots[0])
	
