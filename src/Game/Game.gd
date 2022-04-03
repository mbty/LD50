extends Node

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
		map.summon_product(GameState.selected_product)

func _on_ActionUI_begin_simulation():
	GameState.game_mode = GameState.GameMode.SIMULATION
	$UI/ActionUI.hide()
	$SimulationModeTimer.start()
	map.create_client($Products.get_children())

func _on_SimulationModeTimer_timeout():
	GameState.game_mode = GameState.GameMode.DESIGN
	$UI/ActionUI.show()
