extends PanelContainer

var inventory : Inventory


func _ready() -> void:
	if !owner:
		return
	inventory = owner.inventory
	
	add_slot("res://2D/tres/food/", get_node("MarginContainer/HBoxContainer/FoodPanel/ScrollContainer/VBoxContainer"), owner)
	add_slot("res://2D/tres/tool/", get_node("MarginContainer/HBoxContainer/ToolPanel/ScrollContainer/VBoxContainer"), owner)
	add_slot("res://2D/tres/object/", get_node("MarginContainer/HBoxContainer/ObjectPanel/ScrollContainer/VBoxContainer"), owner)
	add_slot("res://2D/tres/material/", get_node("MarginContainer/HBoxContainer/OtherPanel/ScrollContainer/VBoxContainer"), owner)


func add_slot(path: String, node, master):
	var list := []
	var files = DirAccess.open(path)
	if files:
		for file in files.get_files():
			list.append(load(path+file.split(".")[0]+"."+file.split(".")[1]))
	
	if list.is_empty():
		return
	list = list.filter(func(s): return s != null)
	var items = list.filter(func(item): return item.material)
	if items.is_empty():
		return
	for item in items:
		var itemSlot = preload("res://2D/ui/item_slot.tscn").instantiate()
		node.add_child(itemSlot)
		itemSlot.generate(inventory, item, master)


func _on_food_pressed() -> void:
	$MarginContainer/HBoxContainer/OtherPanel.visible = false
	$MarginContainer/HBoxContainer/ObjectPanel.visible = false
	$MarginContainer/HBoxContainer/ToolPanel.visible = false
	$MarginContainer/HBoxContainer/FoodPanel.visible = !$MarginContainer/HBoxContainer/FoodPanel.visible


func _on_object_pressed() -> void:
	$MarginContainer/HBoxContainer/OtherPanel.visible = false
	$MarginContainer/HBoxContainer/FoodPanel.visible = false
	$MarginContainer/HBoxContainer/ToolPanel.visible = false
	$MarginContainer/HBoxContainer/ObjectPanel.visible = !$MarginContainer/HBoxContainer/ObjectPanel.visible


func _on_tool_pressed() -> void:
	$MarginContainer/HBoxContainer/OtherPanel.visible = false
	$MarginContainer/HBoxContainer/ObjectPanel.visible = false
	$MarginContainer/HBoxContainer/FoodPanel.visible = false
	$MarginContainer/HBoxContainer/ToolPanel.visible = !$MarginContainer/HBoxContainer/ToolPanel.visible


func _on_other_pressed() -> void:
	$MarginContainer/HBoxContainer/ToolPanel.visible = false
	$MarginContainer/HBoxContainer/ObjectPanel.visible = false
	$MarginContainer/HBoxContainer/FoodPanel.visible = false
	$MarginContainer/HBoxContainer/OtherPanel.visible = !$MarginContainer/HBoxContainer/OtherPanel.visible
