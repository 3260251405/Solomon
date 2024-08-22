extends Resource

class_name Item

enum STYLE{FOOD, SEED}

@export var texture : Texture
@export var name : String
@export_enum("FOOD", "SEED") var style
@export var data : Dictionary
@export_multiline var description : String
