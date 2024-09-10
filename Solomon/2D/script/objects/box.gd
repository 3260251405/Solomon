extends Stuff

var inventory : Inventory = null


func _init():
	inventory = Inventory.new()
	for index in range(9):
		inventory.slots.append(Slot.new())
		
func _ready():
	type = "box"
	anim.play("default")


func get_item():
	var slots := []
	for slot in inventory.slots:
		if slot.item is Item:
			slots.append({"item"=slot.item.resource_path, "quantity"=slot.quantity})
	return slots


func _on_area_2d_body_entered(body):
	if is_instance_valid(master) and body == master:
		anim.play("open")
		$Window.visible = true
		#master.panel.visible = true
		master.info.visible = false


func _on_area_2d_body_exited(body):
	if is_instance_valid(master) and body == master:
		anim.play("close")
		$Window.visible = false
		master.info.visible = true
