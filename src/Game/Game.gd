extends Node

signal summon_product

onready var map = $Map

func _ready():
	randomize()
	map.create_client($Products.get_children())
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and GameState.selected_product != null:
			emit_signal("summon_product", GameState.selected_product)

