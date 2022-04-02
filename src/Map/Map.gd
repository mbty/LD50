extends Node2D

onready var product_sprite_scene = preload("res://src/Product/ProductSprite.tscn")
onready var client_scene = preload("res://src/Client/Client.tscn")
onready var nav = $Navigation2D
onready var floor_tile_map = $Navigation2D/FloorTileMap
onready var product_tile_map = $Navigation2D/ProductTileMap
onready var products_sprite = $ProductSprites
onready var clients = $Navigation2D/Clients

enum TILE_TYPES {
	AISLE = 0,
	CHECKOUT = 1,
	GROUND = 2
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
	
func create_client(products):
	var client = client_scene.instance()
	client.build_wishlist(products)
	client.set_strategy(Globals.STRATEGY_TYPE.MIND_OF_STEEL)
	client.position += Vector2(20.0, 20.0)
	clients.add_child(client)

func get_tile_under_cursor():
	return floor_tile_map.world_to_map(get_viewport().get_mouse_position() - floor_tile_map.get_global_transform_with_canvas().origin)

func _on_Game_summon_aisle(product):
	var tile_pos = get_tile_under_cursor()
	if tile_pos == null:
		return
	var current_tile = floor_tile_map.get_cell(tile_pos.x, tile_pos.y)
	# Can only drop an aisle/product on a floor tile
	if current_tile == TILE_TYPES.AISLE:
		product_tile_map.set_cell(tile_pos.x, tile_pos.y, product.type)
