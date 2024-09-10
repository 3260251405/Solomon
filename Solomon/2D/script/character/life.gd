extends CharacterBody2D

class_name Life

signal dead(Life)

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var anim : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@onready var bar_hp = $Bar/HBoxContainer/VBoxContainer/HpBar

@onready var sprite : Sprite2D = $Sprite2D



var isNight := false:
	set(v):
		isNight = v
		if has_method("day_logic"):
			call_deferred("day_logic")

var isDead := false

var hpMax : int = 100:
	set(v):
		hpMax = v
		bar_hp.max_value = hpMax

var hp : int = 100:
	set(v):
		var pre = hp
		hp = min(v, hpMax)
		bar_hp.value = hp
		
		var operater = ""
		if hp < pre:
			hp_text(hp - pre, "", Color(1, 0, 0, 1))
		elif hp > pre:
			hp_text(hp - pre, "+", Color(0, 1, 0, 1))
	
			
		if has_method("hp_logic"):
			call_deferred("hp_logic")

var world : Node2D
var worldSize := []
var map : TileMap

var direction := Vector2.ZERO

var speed : int = 50
var attackValue : int = 10

var maxExp : int = 100
var nowExp : int = 0:
	set(v):
		nowExp = v
		if nowExp >= maxExp:
			nowExp = 0
			lv += 1
			if has_method("upgrade"):
				call_deferred("upgrade")

var exp : int = 20
var lv : int = 1:
	set(v):
		lv = v
		maxExp = lv * 50 + 50
		$Bar/HBoxContainer/Label.text = str(lv)
		if has_method("lv_logic"):
			call("lv_logic")
		
var initHp := 0
var initSpeed := 0
var initAttack := 0
var initExp := 0

var hitBody : Life = null

var spawner

var hateBody = null
var hateBodies := []

var karma := 0:
	set(v):
		karma = v
		if has_method("update_panel"):
			call_deferred("update_panel")
		var LV = get_node_or_null("CanvasLayer/LV")
		if LV:
			LV.text = "善恶值: %d"%karma
			
var masterName := ""
var master : People = null:
	set(v):
		master = v
		if !master:
			return
		masterName = master.name
		master.help.connect(func(body): if !hateBodies.has(body): hateBodies.append(body))


func _ready():
	world = get_tree().current_scene
	if world.has_method("get_world_size"):
		worldSize = world.get_world_size()
	
	isNight = world.isNight
	
	map = get_tree().current_scene.get_node_or_null("TileMap")
	
	spawner = get_tree().current_scene.get_node_or_null("Drops")
	if !spawner:
		spawner = get_parent()
	
	check_sea()
	

func check_sea():
	if !map or isDead:
		return
	var mapData = map.get_cell_tile_data(0, map.local_to_map(global_position))
	if !mapData:
		return
	if mapData.get_custom_data("isSea"):
		hp -= 20
		direction *= -1
	await get_tree().create_timer(5).timeout
	check_sea()


func _physics_process(delta):
	velocity = direction * speed
	if direction:
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
		animation_tree.set("parameters/Attack/blend_position", direction)
		animation_tree.set("parameters/Death/blend_position", direction)
		
		play_sound("Walk")
	move_and_slide()
	if worldSize:
		global_position = global_position.clamp(worldSize[0], worldSize[1])


func play_sound(nodeName):
	var sound : AudioStreamPlayer2D = get_node_or_null("Audios").get_node_or_null(nodeName)
	if !sound:
		return
	
	if !sound.playing:
		sound.play()
		


func _on_hurt_box_hurt(hitbox):
	var body = hitbox.owner
	if body == self:
		return
	
	call("to_hurt", body)


func drop(item: Item, quantity: int, canFly: bool):
	for index in quantity:
		var itemNode = Global.itemNode.instantiate()
		spawner.add_child(itemNode)
		itemNode.canFly = canFly
		itemNode.generate(item)
		itemNode.global_position = global_position + Vector2(randi_range(-10, 10), randi_range(-10, 0))


func check_body(body):
	if is_instance_valid(body):
		if body.is_in_group("nature"):
			return body.state != "cut"
		elif body.is_in_group("animal"):
			return body.master != master
		elif body != self:
			return !body.isDead


##受伤文字浮现
func hp_text(value, operater, color):
	var label = Label.new()
	add_child(label)
	label.scale = Vector2(0.8, 0.8)
	label.top_level = true
	label.z_index = 99
	label.global_position = global_position + Vector2(-5, -5)
	label.set_deferred("modulate", color)
	
	label.text = operater + str(value)
	
	#文字动画
	var tween = get_tree().create_tween()
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -20), 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.5, 0.5)
	tween.tween_callback(func(): if label: label.queue_free())


func hurt(body):
	hitBody = body
		
	hp -= body.attackValue

	if hp <= 0:
		if body:
			body.nowExp += exp
		return
		
	get_tree().create_tween().tween_property(sprite, "modulate", Color(255, 0, 0), 0.2)
	get_tree().create_tween().tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)
	
	var direction3 = global_position.direction_to(body.global_position)
	
	var prePosition = global_position
	
	position += direction3 * -10
	
	if !map:
		return
	var mapData : TileData =  map.get_cell_tile_data(0, map.local_to_map(global_position))
	if mapData and mapData.get_custom_data("isSea"):
		global_position = prePosition
