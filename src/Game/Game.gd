extends Node

onready var map = $Map

func _ready():
	randomize()
	
func _input(event):
	if (
		event is InputEventMouseButton
		and event.pressed
		and GameState.game_mode == GameState.GameMode.DESIGN
	):
		if event.button_index == BUTTON_LEFT:
			if GameState.selected_tool == GameState.Tool.AISLE:
				map.summon_aisle()
			elif GameState.selected_tool == GameState.Tool.PRODUCT:
				assert(GameState.selected_product != null)
				map.summon_product(GameState.selected_product)
		elif event.button_index == BUTTON_RIGHT:
			map.remove_tile()

func _on_ActionUI_begin_simulation():
	GameState.game_mode = GameState.GameMode.SIMULATION
	$UI/ActionUI.hide()
	$SimulationModeTimer.start()
	map.create_client($Products.get_children())

func _on_SimulationModeTimer_timeout():
	GameState.game_mode = GameState.GameMode.DESIGN
	$UI/ActionUI.show()
