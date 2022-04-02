extends Node

signal new_product

func _ready():
	for product in get_children():
		emit_signal("new_product", product)
