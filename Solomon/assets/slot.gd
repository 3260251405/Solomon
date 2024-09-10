extends TextureRect

var player : People = null
var inventory : Inventory = null
var item : Item = null

var isBag := false

@onready var panel = $Panel


func _ready():
	inventory = get_inventory(get_parent())
	player = get_owner2(get_parent())
	
	if !isBag:
		$Label.visible = true
		$Label.text = str(get_index() + 1)
	else:
		$Label.visible = false
		$Label.text = ""


func get_inventory(body):
	if body is People or body is Stuff :
		if body.inventory:
			return body.inventory
	return get_inventory(body.get_parent())


func get_owner2(body):
	if body is People:
		return body
	if !body.get_parent():
		return null
	return get_owner2(body.get_parent())


func update(slot):
	for child in $MarginContainer.get_children():
		child.queue_free()
	if slot.item is Item:
		item = slot.item
		var itemNode = preload("res://2D/inventory/item.tscn").instantiate()
		$MarginContainer.add_child(itemNode)
		itemNode.texture = item.texture
		itemNode.get_child(0).text = str(slot.quantity)
		itemNode.get_child(0).visible = slot.quantity > 1
		if item.style == item.STYLE.TOOL and item.amount > 1:
			itemNode.get_child(0).text = str(100-int(100/item.amount)*(item.amount-slot.quantity)) + "%"
			itemNode.get_child(0).visible = true
		if  item.style == item.STYLE.AUTO_TOOL and player:
			player.call_deferred(item.name.to_lower(), get_index())
	else:
		item = null
		panel.hide()


func _on_mouse_entered():
	if item is Item:
		panel.size = Vector2(100, 20)
		panel.position = global_position - Vector2(0, 20)
		panel.visible = true
		$Panel/MarginContainer/Label.text = item.description


func _on_mouse_exited():
	panel.visible = false


func _get_drag_data(at_position):
	if !isBag:
		return
	
	var index = get_index()
	var slot = inventory.remove_item(index)
	if slot.item:
		var data := {}
		data.slot = slot
		data.index = index
		var preview = TextureRect.new()
		preview.texture = slot.item.texture
		preview.scale = Vector2(max(16/preview.texture.get_width(), 0.2), max(16/preview.texture.get_height(), 0.2))
		set_drag_preview(preview)
		return data


func _can_drop_data(at_position, data):
	return data and data.slot


func _drop_data(at_position, data):
	var preSlot : Slot = data.slot
	var preIndex = data.index
	var index = get_index()
	var slot = inventory.slots[index]
	if slot.item and slot.item == preSlot.item and slot.item.stackable and slot.quantity < slot.item.maxStack:
		if slot.quantity + preSlot.quantity < slot.item.maxStack:
			inventory.set_item(preSlot.item, slot.quantity + preSlot.quantity, index)
		else:
			#slot.quantity = slot.item.maxStack
			var quantity = slot.quantity + preSlot.quantity - slot.item.maxStack
			inventory.set_item(slot.item, slot.item.maxStack, index)
			inventory.set_item(slot.item, quantity, preIndex)
	else:
		if slot.item:
			inventory.set_item(slot.item, slot.quantity, preIndex)
		inventory.set_item(preSlot.item, preSlot.quantity, index)


func _gui_input(event: InputEvent) -> void:
	if isBag or !player:
		return
		
	if event is InputEventScreenTouch || event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			var index = get_index()
			var item = inventory.find_item(index)
			if item:
				player.use(index, item)
