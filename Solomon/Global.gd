extends Node

const SAVE_PATH := "user://data.sav"
const ACC_PATH := "user://acc.sav"

var worldSize : int = randi_range(100, 600)
var peopleAmount : int = randi_range(10, 100)
var treePer : float = randf_range(0.05, 0.5)
var stoneAmount : int = randi_range(10, 50)

var isNew : bool

enum MAP_DATA {LIFE, NATURE, PLANT, OBJECT}

#var zombie = preload("res://2D/character/monsters/zombie.tscn")
#var goblin = preload("res://2D/character/monsters/goblin.tscn")
#var slime = preload("res://2D/character/monsters/slime.tscn")
#var npc = preload("res://2D/character/npc.tscn")
var itemNode = preload("res://2D/objects/item_node.tscn")

var dict := {}


func _ready():
	load_history()
	var files = DirAccess.open("res://2D/tres/accomplishment/").get_files()

	if dict.keys().size() == files.size():
		return
		
	
	for file in files:
		var type = file.split(".")
		dict[type[0]] = false
		
		
func save_history():
	var file = FileAccess.open(ACC_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(dict))
	file.close()
	

func load_history():
	var file = FileAccess.open(ACC_PATH, FileAccess.READ)
	if !file:
		return
	dict = JSON.parse_string(file.get_as_text())
	file.close()
	
