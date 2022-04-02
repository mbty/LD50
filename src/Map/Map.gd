extends Node2D

onready var product_sprite_scene = preload("res://src/Product/ProductSprite.tscn")
onready var client_scene = preload("res://src/Client/Client.tscn")
onready var nav = $Navigation2D
onready var floor_tile_map = $Navigation2D/FloorTileMap
onready var product_tile_map = $Navigation2D/ProductTileMap
onready var door_tile_map = $Navigation2D/DoorTileMap
onready var products_sprite = $ProductSprites
onready var clients = $Navigation2D/Clients

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
	for coords in self.floor_tile_map.get_used_cells():
		var id = floor_tile_map.get_cell(coords.x, coords.y)
		if id == TILE_TYPES.CHECKOUT:
			checkout_locations.append(floor_tile_map.map_to_world(coords) + global_position)
	
func init_product_locations():
	product_locations = {}
	for coords in self.product_tile_map.get_used_cells():
		var id = product_tile_map.get_cell(coords.x, coords.y)
		if product_locations[id] == null:
			product_locations[id] = []
		product_locations[id].append(product_tile_map.map_to_world(coords) + global_position)

func get_checkout_locations():
	return checkout_locations

func get_product_locations(product):
	return product_locations[product]

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

	var door_cells = door_tile_map.get_used_cells()
	var cell = door_cells[randi() % door_cells.size()]
	var to_shift = (door_tile_map.map_to_world(cell) - global_position) + Vector2(16, 16)
	client.position += to_shift
	clients.add_child(client)

func get_tile_under_cursor():
	return floor_tile_map.world_to_map(get_viewport().get_mouse_position() - floor_tile_map.get_global_transform_with_canvas().origin)

func _on_Game_summon_product(product):
	var tile_pos = get_tile_under_cursor()
	if tile_pos == null:
		return
	var current_tile = floor_tile_map.get_cell(tile_pos.x, tile_pos.y)
	# Can only drop an aisle/product on a floor tile
	if current_tile == TILE_TYPES.AISLE:
		var current_value = product_tile_map.get_cell(tile_pos.x, tile_pos.y)
		if current_value != -1:
			remove_product_from_dict(tile_pos, current_value)

		product_tile_map.set_cell(tile_pos.x, tile_pos.y, product.type)		
		add_product_to_dict(tile_pos, product)
