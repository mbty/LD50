extends Node

class_name Product

export var type: int
export var texture : Texture
export var product_name : String
export var cost : int
export var price : int
export var frequency : float

func get_name():
	return product_name

func get_texture():
	return texture 
