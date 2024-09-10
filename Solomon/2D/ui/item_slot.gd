extends HBoxContainer

var inventory : Inventory
var item : Item
var master : People

var goodsLoad = preload("res://2D/ui/material.tscn")

var dict := {
	"attackValue" = "攻击",
	"hp" = "生命",
	"hpMax" = "最大生命",
	"hv" = "饱食",
	"hvMax" = "最大饱食",
	"speed" = "速度",
	"karma" = "善恶值",
}


func generate(invent, i, body) -> void:
	inventory = invent
	item = i
	master = body
	
	if master.has_signal("signal_haveFire"):
		master.signal_haveFire.connect(can_make)
	
	var operator = ""
	$Button.icon = item.texture
	%Name.text = item.ChineseName
	if item.amount > 1 and item.style != item.STYLE.TOOL:
		$Button.text = "x"+str(item.amount)
	
	if item.data.keys().size() > 0:
		for key in item.data.keys():
			#var content = preload("res://2D/ui/item_data.tscn").instantiate()
			var content = get_content()
			var value = item.data.get(key)
			if value > 0:
				operator = "+"
				
			$VBoxContainer/ItemProfile.add_child(content)
			content.text = dict[key] + operator + str(value)
	elif item.description:
		var dict := {"autowrap_mode"=TextServer.AUTOWRAP_ARBITRARY, 
				"custom_minimum_size"=Vector2(160, 0)}
		var content = get_content(dict)
		#var content = preload("res://2D/ui/item_data.tscn").instantiate()
		#content.custom_minimum_size = Vector2(150, 0)
		#content["theme_override_font_sizes/font_size"] = 12
		#content.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		$VBoxContainer/ItemProfile.add_child(content)
		
		
		content.text = item.description
	
	if item.material != null:
		for key in item.material.keys():
			var goods = goodsLoad.instantiate()
			%MaterialSlot.add_child(goods)
			goods.get_node("TextureRect").texture = key.texture
			goods.get_node("Label").text = "x%d"%item.material.get(key)
	
	can_make()


func get_content(dict: Dictionary={}):
	var content = Label.new()
	for key in dict.keys():
		content[key] = dict.get(key)
	content["theme_override_colors/font_color"] = Color(0, 1, 0, 1)
	content["theme_override_colors/font_outline_color"] = Color(0, 0, 0)
	content["theme_override_constants/outline_size"] = 5
	content["theme_override_font_sizes/font_size"] = 12
	return content


func can_make():
	if item.needFire:
		if master.haveFire:
			show()
			return true
		else:
			hide()
			return false
	return true


func _on_button_pressed() -> void:
	var list := []
	var canGenerate := false
	for key in item.material.keys():
		var data = inventory.have_item(key, item.material.get(key))
		if data != null:
			list.append({data:item.material.get(key)})
	canGenerate = list.size() >= item.material.size()
	if canGenerate and can_make():
		if item.style == item.STYLE.OBJECT:
			if master.call(item.name.to_lower()):
				for index in list:
					inventory.use_item(index.keys()[0], index.values()[0])
		else:
			for index in list:
				inventory.use_item(index.keys()[0], index.values()[0])
			var value = 1 if item.amount <= 0 else item.amount
			if !inventory.add_item(item, value):
				var node = Global.itemNode.instantiate()
				get_tree().current_scene.get_node("Drops").add_child(node)
				node.generate(item)
				node.global_position = master.global_position
	else:
		var warn = load("res://2D/ui/warn.tscn").instantiate()
		add_child(warn)
		warn.show_text("材料不足！")
