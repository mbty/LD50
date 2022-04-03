extends Node

class_name Product

var type = null
export var texture : Texture
export var product_name : String
export var cost : int
export var price : int
export var frequency : float

func _ready():
	pass

func get_name():
	return product_name

func get_texture():
	return texture 
