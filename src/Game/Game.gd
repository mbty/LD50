extends Node

signal summon_product

onready var map = $Map
var building_mode = true

func _ready():
	randomize()
	
func _input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == BUTTON_LEFT
		and event.pressed
		and GameState.selected_product != null
		and self.building_mode
	):
		emit_signal("summon_product", GameState.selected_product)

func _on_ActionUI_begin_simulation():
	building_mode = false
	$UI/ActionUI.hide()
	$SimulationModeTimer.start()
	map.create_client($Products.get_children())

func _on_SimulationModeTimer_timeout():
	building_mode = true
	$UI/ActionUI.show()
