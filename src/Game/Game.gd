extends Node

var money = 0
onready var map = $Map

var drag_build = false
var drag_destroy = false
var last_drag_deleted_tile = null

func not_dragging():
	return !drag_build and !drag_destroy

func _ready():
	randomize()
	$UI/HUD.update_money(money)
	var i = 0
	for product in $Products.get_children():
		product.type = i
		i+=1

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

func _previous_tool():
	if GameState.selected_tool == GameState.Tool.PRODUCT:
		var next_product_id = GameState.selected_product.type - 1
		if next_product_id < 0:
			GameState.on_tool_selected(GameState.Tool.AISLE)
		else:
			var next_prod = $Products.get_child(
				GameState.selected_product.type-1%$Products.get_child_count()
			)
			GameState.on_product_selected(next_prod)
	elif GameState.selected_tool == GameState.Tool.AISLE:
		var next_prod = $Products.get_child($Products.get_child_count()-1)
		GameState.on_product_selected(next_prod)

func _next_tool():
	if GameState.selected_tool == GameState.Tool.PRODUCT:
		var next_product_id = GameState.selected_product.type + 1
		if next_product_id >= $Products.get_child_count():
			GameState.on_tool_selected(GameState.Tool.AISLE)
		else:
			var next_prod = $Products.get_child(next_product_id)
			GameState.on_product_selected(next_prod)
	elif GameState.selected_tool == GameState.Tool.AISLE:
		var next_prod = $Products.get_child(0)
		GameState.on_product_selected(next_prod)

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
			elif event.button_index == BUTTON_WHEEL_UP:
				_previous_tool()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_next_tool()
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

func _on_Map_product_bought(product):
	money += product
	$UI/HUD.update_money(money)
