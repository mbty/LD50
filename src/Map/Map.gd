extends Node2D

signal product_bought

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
var checkout_locations

func _ready():
	self._init_dict()
	
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
	if not product_locations.has(product.type):
		product_locations[product.type] = []
	product_locations[product.type].append(product_tile_map.map_to_world(coords))

func remove_product_from_dict(coords, product_id):
	var world_coords = product_tile_map.map_to_world(coords)
	var index = product_locations[product_id].find(world_coords)
	product_locations[product_id].remove(index)

func create_client(products):
	var client = client_scene.instance()
	client.build_wishlist(products)
	client.set_strategy(Globals.STRATEGY_TYPE.MIND_OF_STEEL)
	client.connect("buy_product", self, "product_bought")

	var door_cells = floor_tile_map.get_used_cells_by_id(TILE_TYPES.DOOR)
	var cell = door_cells[randi() % door_cells.size()]
	var to_shift = (floor_tile_map.map_to_world(cell) - global_position) + Vector2(16, 16)
	client.position += to_shift
	clients.add_child(client)

func product_bought(product):
	emit_signal("product_bought", product)

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

# Returns [tile * factor]
func get_navigable_neighbors(x, y):
	var up = Vector2(x, y + 1)
	var down = Vector2(x, y - 1)
	var left = Vector2(x - 1, y)
	var right = Vector2(x + 1, y)
	var ul = Vector2(x - 1, y + 1)
	var ur = Vector2(x + 1, y + 1)
	var dl = Vector2(x - 1, y - 1)
	var dr = Vector2(x + 1, y - 1)
	var ul_cost = get_navigation_cost_corner(ul, up, left)
	var ur_cost = get_navigation_cost_corner(ur, up, right)
	var dl_cost = get_navigation_cost_corner(dl, down, left)
	var dr_cost = get_navigation_cost_corner(dr, down, right)
	
	var res = []
	if is_navigable_simple(up):
		res.append([up, 1])
	if is_navigable_simple(down):
		res.append([down, 1])
	if is_navigable_simple(left):
		res.append([left, 1])
	if is_navigable_simple(right):
		res.append([right, 1])
	if ul_cost != 0.0:
		res.append([ul, ul_cost])
	if ur_cost != 0.0:
		res.append([ur, ur_cost])
	if dl_cost != 0.0:
		res.append([dl, dl_cost])
	if dr_cost != 0.0:
		res.append([dr, dr_cost])
	return res

func heuristic(current, goal):
	return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y, 2))

func path_from_backtrack_map(bm, current):
	var path = []
	while bm.has(current):
		path.append(floor_tile_map.map_to_world(current))
		current = bm[current]
	path.invert()
	return path

# TODO memoize paths
func get_path_raw(origin, destination):
	var origin_tile = floor_tile_map.world_to_map(origin)
	var destination_tile = floor_tile_map.world_to_map(destination)
	
	var frontier = PriorityQueue.new()
	var backtrack_map = {}
	var computed_costs = {}
	computed_costs[origin_tile] = 0
	frontier.push(origin_tile, heuristic(origin_tile, destination))

	var current
	
	while not frontier.is_empty():
		current = frontier.pop()
		if (current - destination_tile).length() < 2:
			return path_from_backtrack_map(backtrack_map, current)
		for candidate in get_navigable_neighbors(current.x, current.y):
			var cost = computed_costs[current] + candidate[1]
			if !computed_costs.has(candidate[0]) || cost < computed_costs[candidate[0]]:
				computed_costs[candidate[0]] = cost
				backtrack_map[candidate[0]] = current
				frontier.push(candidate[0], cost + heuristic(current, destination_tile))
	return path_from_backtrack_map(backtrack_map, current)

# TODO
func smooth_path(path):
	return path

func get_path_(origin, destination):
	return get_path_raw(origin, destination)
