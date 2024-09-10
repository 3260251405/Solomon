extends Control

var master : People = null

var inventory : Inventory
var slotLoad = preload("res://2D/inventory/slot.tscn")

@onready var grid = $HBoxContainer/Bag/MarginContainer/GridContainer


func _ready():
	if owner and owner is People:
		master = owner
	else:
		master = get_owner3(get_parent())
	
	update_panel()
	$Button.global_position = global_position + Vector2(size.x-15, -8)


func get_owner3(node):
	if node is People:
		return node
	return get_owner3(node.get_parent())


func update_panel():
	if !master:
		return
	%LV.text = "等级："+str(master.lv)
	%HP.text = "生命值："+str(roundi(master.hp)) + "/" + str(master.hpMax)
	%HV.text = "饱食度："+str(roundi(master.hv)) + "/" + str(master.hvMax)
	%EXP.text = "经验值："+str(master.nowExp) + "/" + str(master.maxExp)
	%Attack.text = "攻击："+str(master.attackValue)
	%Speed.text = "速度："+str(master.speed)
	%Karma.text = "善恶值："+str(master.karma)
	$Button.global_position = global_position + Vector2(size.x-15, -8)


func _on_button_pressed():
	visible = false


func _on_visibility_changed():
	update_panel()
