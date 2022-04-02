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
	CHECK_OUT = 1,
	GROUND = 2
}

var product_dict
var checkout_locations

func _ready():
	self._init_dict()
	
func _init_dict():
	product_dict = {}
	for sprite in products_sprite.get_children():
		var product = sprite.product
		if product_dict[product] == null:
			product_dict[product] = []
		product_dict[product].append(sprite)
		
	checkout_locations = []
	for tile in floor_tile_map.get_used_cells():
		if floor_tile_map.get_cell(tile.x, tile.y) == TILE_TYPES.CHECK_OUT:
			checkout_locations.append(floor_tile_map.map_to_world(tile))
			
func get_checkout_locations():
	return checkout_locations
	
func get_product_locations(product):
	var locations = []
	for sprite in self.product_dict[product]:
		locations.append(sprite.position + global_position)

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
	if current_tile == TILE_TYPES.GROUND:
		floor_tile_map.set_cell(tile_pos.x, tile_pos.y, TILE_TYPES.AISLE)
		var aisle = product_sprite_scene.instance()
		aisle.position = floor_tile_map.map_to_world(tile_pos)
		aisle.product = product
		products_sprite.add_child(aisle)
