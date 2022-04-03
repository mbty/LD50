extends Node

onready var map = $Map

var drag_build = false
var drag_destroy = false
var last_drag_deleted_tile = null

func not_dragging():
	return !drag_build and !drag_destroy

func _ready():
	randomize()

func build():
	if GameState.selected_tool == GameState.Tool.AISLE:
		map.summon_aisle()
	elif GameState.selected_tool == GameState.Tool.PRODUCT:
		assert(GameState.selected_product != null)
		map.summon_product(GameState.selected_product)
	
func destroy():
	var tile_pos = map.get_tile_under_cursor()
	if tile_pos != last_drag_deleted_tile:
		map.remove_tile()
		last_drag_deleted_tile = tile_pos

func _input(event):
	if GameState.game_mode != GameState.GameMode.DESIGN:
		return

	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT and not_dragging():
				drag_build = true
				build()
			elif event.button_index == BUTTON_RIGHT and not_dragging():
				drag_destroy = true
				destroy()
		else:
			if event.button_index == BUTTON_LEFT:
				drag_build = false
			elif event.button_index == BUTTON_RIGHT:
				drag_destroy = false
				last_drag_deleted_tile = null

	if (
		event is InputEventMouseMotion
		and GameState.game_mode == GameState.GameMode.DESIGN
	):
		if drag_build:
			build()
		elif drag_destroy:
			destroy()

func _on_ActionUI_begin_simulation():
	GameState.game_mode = GameState.GameMode.SIMULATION
	$UI/ActionUI.hide()
	$SimulationModeTimer.start()
	map.create_client($Products.get_children())

func _on_SimulationModeTimer_timeout():
	GameState.game_mode = GameState.GameMode.DESIGN
	$UI/ActionUI.show()
