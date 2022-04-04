extends Node2D

signal add_to_cart
signal cost_changed

onready var client_scene = preload("res://src/Client/Client.tscn")
onready var nav = $Navigation2D
onready var floor_tile_map = $Navigation2D/FloorTileMap
onready var product_tile_map = $Navigation2D/ProductTileMap
onready var clients = $Navigation2D/Clients
onready var map_hover = $Navigation2D/MapHover
onready var camera = $Camera2D
onready var game = get_parent().get_parent()

var door_cells = null

var hover_position = Vector2(0, 0)

enum TILE_TYPES {
	AISLE = 0,
	CHECKOUT = 1,
	GROUND = 2,
	DOOR = 3
}

var product_locations
var product_per_location = {}
var checkout_locations

func _ready():
	self._init_dict()
	save_aisle_setup()

var original_aisle_setup
func save_aisle_setup():
	original_aisle_setup = floor_tile_map.get_used_cells_by_id(TILE_TYPES.AISLE)

func assess_cost():
	var current_aisle_setup = floor_tile_map.get_used_cells_by_id(TILE_TYPES.AISLE)
	var cost = 0
	for original_tile in original_aisle_setup:
		if current_aisle_setup.find(original_tile) == -1:
			cost -= Globals.AISLE_COST
	return cost + max(
		0,
		Globals.AISLE_COST*(current_aisle_setup.size() - original_aisle_setup.size())
	)

func _find_extra_aisles():
	var current_aisle_setup = floor_tile_map.get_used_cells_by_id(TILE_TYPES.AISLE)
	for tile in original_aisle_setup:
		var index = current_aisle_setup.find(tile)
		if index != -1:
			current_aisle_setup.remove(index)
	return current_aisle_setup

func reset_aisles():
	for original_tile in original_aisle_setup:
		floor_tile_map.set_cellv(original_tile, TILE_TYPES.AISLE)
	for tile in _find_extra_aisles():
		floor_tile_map.set_cellv(tile, TILE_TYPES.GROUND)
		product_tile_map.set_cellv(tile, -1)
		
	var rect = floor_tile_map.get_used_rect()
	floor_tile_map.update_bitmask_region(
		rect.position,
		rect.end
	)
	emit_signal("cost_changed", 0)

func _init_dict():
	init_checkout_locations()
	init_product_locations()

func init_checkout_locations():
	checkout_locations = []
	for coords in self.floor_tile_map.get_used_cells_by_id(TILE_TYPES.CHECKOUT):
		checkout_locations.append(floor_tile_map.map_to_world(coords) + global_position)
	
func init_product_locations():
	product_locations = {}
	for coords in self.product_tile_map.get_used_cells():
		var id = product_tile_map.get_cellv(coords)
		if product_locations[id] == null:
			product_locations[id] = []
		product_locations[id].append(product_tile_map.map_to_world(coords) + global_position)

func _process(delta):
	var tile_under_cursor = get_tile_under_cursor()
	$Tween.interpolate_property(map_hover, "rect_position",
		map_hover.rect_position, product_tile_map.map_to_world(tile_under_cursor), .05,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	var cell = floor_tile_map.get_cellv(tile_under_cursor)
	camera.offset = (get_viewport().get_mouse_position() - get_viewport().size / 2) / 4

	if GameState.selected_tool == GameState.Tool.PRODUCT:
		map_hover.show_product = cell == TILE_TYPES.AISLE
	elif GameState.selected_tool == GameState.Tool.AISLE:
		map_hover.show_product = cell == TILE_TYPES.GROUND

func get_checkout_locations():
	return checkout_locations

func get_product_locations(product_type):
	if not product_locations.has(product_type):
		return []
	return product_locations[product_type]

func add_product_to_dict(coords, product):
	product_per_location[coords] = product.type
	if not product_locations.has(product.type):
		product_locations[product.type] = []
	product_locations[product.type].append(product_tile_map.map_to_world(coords))

func remove_product_from_dict(coords, product_id):
	var world_coords = product_tile_map.map_to_world(coords)
	var index = product_locations[product_id].find(world_coords)
	product_locations[product_id].remove(index)
	product_per_location.erase(coords)

func create_client(products):
	var client = client_scene.instance()
	client.build_wishlist(products)
	client.set_strategy(Globals.STRATEGY_TYPE.MIND_OF_STEEL)
	client.connect("add_to_cart", self, "added_to_cart")
	client.connect("buy", self, "bought")

	var door_cells = floor_tile_map.get_used_cells_by_id(TILE_TYPES.DOOR)
	var cell = door_cells[randi() % door_cells.size()]
	var to_shift = (floor_tile_map.map_to_world(cell) - global_position)
	client.position += to_shift + Vector2(16, 16)
	clients.add_child(client)

func added_to_cart(client, product):
	var in_stock = true;
	if in_stock:
		if not client.in_cart.has(product):
			client.in_cart[product] = 0
		client.in_cart[product] += 1
		print("add_to_cart", product)
		emit_signal("add_to_cart", product)

func bought(client):
	for k in client.in_cart:
		var n = client.in_cart[k]
		game.money += 1 * n
	client.in_cart.clear()

func get_mouse_world_coords():
	return (get_viewport().get_mouse_position() - floor_tile_map.get_global_transform_with_canvas().origin) * camera.zoom

func get_tile_under_cursor():
	var coords = get_mouse_world_coords()
	if game.drag_line:
		var line_dir = game.drag_start.direction_to(get_mouse_world_coords())
		line_dir = line_dir.rotated(-PI / 4.0).sign().rotated(PI / 4.0).normalized()
		coords = (coords - game.drag_start) * line_dir.abs() + game.drag_start
	return floor_tile_map.world_to_map(coords)

func re_bake(changed_tile):
	# Re-bake autotiling
	floor_tile_map.update_bitmask_region(
		Vector2(changed_tile.x-1, changed_tile.y-1),
		Vector2(changed_tile.x+1, changed_tile.y+1)
	)

func summon_aisle():
	var tile_pos = get_tile_under_cursor()
	var current_tile = floor_tile_map.get_cellv(tile_pos)
	if current_tile == TILE_TYPES.GROUND || current_tile == TILE_TYPES.DOOR:
		floor_tile_map.set_cellv(tile_pos, TILE_TYPES.AISLE)
		re_bake(tile_pos)
		emit_signal("cost_changed", assess_cost())
	
func summon_product(product):
	var tile_pos = get_tile_under_cursor()
	var current_tile = floor_tile_map.get_cellv(tile_pos)
	var current_product = product_tile_map.get_cellv(tile_pos)
	# Can only drop an product on an aisle
	if current_tile == TILE_TYPES.AISLE and current_product != product.type:
		if current_product != -1:
			remove_product_from_dict(tile_pos, current_product)
		product_tile_map.set_cellv(tile_pos, product.type)
		add_product_to_dict(tile_pos, product)

func remove_tile():
	var tile_pos = get_tile_under_cursor()
	var product_type = product_tile_map.get_cellv(tile_pos)
	if product_type != -1:
		product_tile_map.set_cellv(tile_pos, -1)
		remove_product_from_dict(tile_pos, product_type)
	elif floor_tile_map.get_cellv(tile_pos) == TILE_TYPES.AISLE:
		floor_tile_map.set_cellv(tile_pos, TILE_TYPES.GROUND)
		re_bake(tile_pos)
		emit_signal("cost_changed", assess_cost())

const diag_factor = 1.4142;
const diag_avoid_wall_factor = 1.5;

func is_navigable_type(tile_type):
	return tile_type == Globals.TILE_TYPES.GROUND

func is_navigable_simple(tile):
	return is_navigable_type(floor_tile_map.get_cell(tile.x, tile.y))

# Cost of 0 = unreachable
func get_navigation_cost_corner(tile, direct1, direct2):
	if !is_navigable_type(floor_tile_map.get_cell(tile.x, tile.y)) || !is_navigable_type(floor_tile_map.get_cell(direct1.x, direct1.y)) && !is_navigable_type(floor_tile_map.get_cell(direct2.x, direct2.y)):
		return 0
	if is_navigable_type(floor_tile_map.get_cell(direct1.x, direct1.y)) && is_navigable_type(floor_tile_map.get_cell(direct2.x, direct2.y)):
		return diag_factor
	return diag_avoid_wall_factor

func get_navigable_neighbors(x, y):
	var res = []
	if is_navigable_simple(Vector2(x, y + 1)):
		res.append(Vector2(x, y + 1))
	if is_navigable_simple(Vector2(x, y - 1)):
		res.append(Vector2(x, y - 1))
	if is_navigable_simple(Vector2(x - 1, y)):
		res.append(Vector2(x - 1, y))
	if is_navigable_simple(Vector2(x + 1, y)):
		res.append(Vector2(x + 1, y))
	return res

func heuristic(current, goal):
	return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y, 2))

func path_from_backtrack_map(bm, current):
	var path = []
	while bm.has(current):
		path.append(floor_tile_map.map_to_world(current) + Vector2(16, 16))
		current = bm[current]
	path.invert()
	return path

func get_path_(origin, destination):
	var origin_tile = floor_tile_map.world_to_map(origin)
	var destination_tile = floor_tile_map.world_to_map(destination)
	
	var frontier = PriorityQueue.new()
	var backtrack_map = {}
	var computed_costs = {}
	computed_costs[origin_tile] = 0
	frontier.push(origin_tile, heuristic(origin_tile, destination))
	
	while not frontier.is_empty():
		var current = frontier.pop()
		if (current - destination_tile).length() < 2:
			return path_from_backtrack_map(backtrack_map, current)
		for candidate in get_navigable_neighbors(current.x, current.y):
			var cost = computed_costs[current] + 1
			if !computed_costs.has(candidate) || cost < computed_costs[candidate]:
				computed_costs[candidate] = cost
				backtrack_map[candidate] = current
				frontier.push(candidate, cost + heuristic(current, destination_tile))
	return []

func update_clients():
	for client in clients.get_children():
		client.move()
