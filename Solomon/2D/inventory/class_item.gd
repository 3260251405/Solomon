extends Resource

class_name Item

enum STYLE{FOOD, SEED, MATERIAL, TOOL, AUTO_TOOL, OBJECT, ANIMAL}

@export var texture : Texture
@export var name : String
@export var ChineseName : String
@export_multiline var description : String

@export var stackable : bool
@export var maxStack : int

@export var amount : int = 1

@export var needFire : bool = false

@export_enum("FOOD", "SEED", "MATERIAL", "TOOL", "AUTO_TOOL", "OBJECT", "ANIMAL") var style

@export var data : Dictionary
@export var material : Dictionary
