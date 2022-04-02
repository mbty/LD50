extends Node

class_name Product

export var texture : Texture
export var product_name : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_name():
	return product_name

func get_texture():
	return texture 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
