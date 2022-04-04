extends Node

var money = 50
onready var map = null
onready var product_ui_list = $UI/ActionUI/VBoxContainer/HBoxContainer/VBoxContainer/Scroller/ProductList
onready var scroller = $UI/ActionUI/VBoxContainer/HBoxContainer/VBoxContainer/Scroller

var drag_build = false
var drag_destroy = false
var drag_line = false
var drag_start = null
var last_drag_deleted_tile = null

var clients_per_sec = 2e-1

var levels = [
	Level.new("Level 1", 1, 50, 100, "Map1"),
	Level.new("Level 2", 5, 50, 200, "Map2"),
	Level.new("Level 3", 5, 50, 300, "Map2"),
]

var level_index = -1

func get_level():
	return levels[level_index]

func not_dragging():
	return !drag_build and !drag_destroy

func _ready():
	randomize()
	on_next_level()

func on_next_level():
	level_index += 1
	var level = get_level()
	money = level.start_money
	$UI/HUD.update_current_day(0)
	$UI/HUD.update_total_days(level.days)
	$UI/HUD.update_goal(level.goal)
	$UI/HUD.update_money(money)

	level.connect("end_level", self, "on_end_level")

	var i = 0
	for product in $Products.get_children():
		product.type = i
		i+=1
	GameState.selected_product = $Products.get_child(0)
	map = get_node('Maps/'+ level.map)
	map.connect("simulation_ended", self, "_on_simulation_ended")
	map.show()

func on_end_level():
	# todo end screen
	on_next_level()

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

func _change_tool(next_product_id):
	if next_product_id < 0:
		next_product_id = $Products.get_child_count() - 1
	GameState.on_product_selected($Products.get_child(next_product_id))
	scroller.ensure_control_visible(product_ui_list.get_child(next_product_id))

func _previous_tool():
	if GameState.selected_tool == GameState.Tool.PRODUCT:
		_change_tool(GameState.selected_product.type - 1)

func _next_tool():
	if GameState.selected_tool == GameState.Tool.PRODUCT:
		_change_tool((GameState.selected_product.type + 1) % $Products.get_child_count())

func _input(event):
	if GameState.game_mode != GameState.GameMode.DESIGN:
		return

	if event.is_action_pressed("ui_play"):
		begin_simulation()

	if event.is_action_pressed("ui_switch_aisle_product"):
		if GameState.selected_tool == GameState.Tool.AISLE:
			GameState.on_tool_selected(GameState.Tool.PRODUCT)
			scroller.ensure_control_visible(product_ui_list.get_child(GameState.selected_product.type))
		else:
			GameState.on_tool_selected(GameState.Tool.AISLE)

	if event is InputEventMouseButton:
		if event.pressed:
			drag_start = map.get_mouse_world_coords()
			if event.shift:
				drag_line = true
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
			drag_line = false
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

func add_money(delta):
	money += delta
	$UI/HUD.update_money(money)

func update_money(new_value):
	money = new_value
	$UI/HUD.update_money(money)

func begin_simulation():
	var cost = map.assess_cost()
	if cost > money:
		return
	self.add_money(-cost)
	$UI/HUD.update_cost(0)
	
	drag_build = false
	drag_destroy = false
	GameState.game_mode = GameState.GameMode.SIMULATION
	$UI/ActionUI.hide()
	$SimulationModeTimer.start()
	$ClientSpawnTimer.start(randf() / clients_per_sec)
	$Music.chargeNextMusic(Globals.DSOTM)
	$Music.cutCurrentMusic()
	map.mode_changed(GameState.GameMode.SIMULATION)

func _on_ActionUI_begin_simulation():
	begin_simulation()

func _on_SimulationModeTimer_timeout():
	GameState.game_mode = GameState.GameMode.DESIGN
	if map.get_node("Navigation2D/Clients").n == 0:
		_on_simulation_ended()

func _on_simulation_ended():
	map.mode_changed(GameState.GameMode.DESIGN)
	get_level().next_day()
	$UI/HUD.update_current_day(get_level().current_day)

	$UI/ActionUI.show()
	$ClientSpawnTimer.stop()

func _on_ClientSpawnTimer_timeout():
	if GameState.game_mode == GameState.GameMode.SIMULATION:
		map.create_client($Products.get_children())
		$ClientSpawnTimer.start(randf() / clients_per_sec)

func _on_TickTimer_timeout():
	map.update_clients()

func _on_Map_cost_changed(new_cost):
	$UI/HUD.update_cost(new_cost)
	$UI/ActionUI.can_play = new_cost <= money

func _on_ActionUI_reset_map():
	map.reset_aisles()
