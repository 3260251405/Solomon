extends TextureRect

var player = null
var inventory = null
var item : Item = null

@onready var panel = $Panel

func _ready():
	player = get_parent().owner.get_parent().owner
	inventory = player.inventory

func update(slot):
	for child in $MarginContainer.get_children():
		child.queue_free()
	if slot.item is Item:
		item = slot.item
		var itemNode = preload("res://2D/inventory/item.tscn").instantiate()
		$MarginContainer.add_child(itemNode)
		itemNode.texture = slot.item.texture
		itemNode.get_child(0).text = str(slot.quantity)
		itemNode.get_child(0).visible = slot.quantity > 1
	else:
		item = null

func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_MASK_RIGHT:
		var index = get_index()
		var item = inventory.find_item(index)
		if item:
			player.use(index, item)


func _on_mouse_entered():
	panel.position = global_position + Vector2(0, 20)
	panel.size = Vector2(100, 20)
	if item:
		panel.visible = true
		$Panel/MarginContainer/Label.text = item.description
		
func _on_mouse_exited():
	panel.visible = false
