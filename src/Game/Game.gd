extends Node

signal summon_aisle

onready var map = $Map

func _ready():
	randomize()
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and GameState.selected_product != null:
			emit_signal("summon_aisle", GameState.selected_product)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ActionUI_product_selected(product):
	GameState.selected_product = product
