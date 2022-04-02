extends Node2D

onready var product_sprite_scene = preload("res://src/Product/ProductSprite.tscn")
onready var client_scene = preload("res://src/Client/Client.tscn")
onready var nav = $Navigation2D
onready var tilemap = $Navigation2D/TileMap
onready var products_sprite = $ProductSprites
onready var clients = $Navigation2D/Clients

enum TILE_TYPES {
	AISLE = 0,
	CHECK_OUT_V = 1,
	CHECK_OUT_H = 2,
	GROUND = 3
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
	for tile in tilemap.get_used_cells():
		if tilemap.get_cell(tile.x, tile.y) in [TILE_TYPES.CHECK_OUT_V || TILE_TYPES.CHECK_OUT_H]:
			checkout_locations.append(tilemap.map_to_world(tile))
			
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
	return tilemap.world_to_map(get_viewport().get_mouse_position() - tilemap.get_global_transform_with_canvas().origin)

func _on_Game_summon_aisle(product):
	var tile_pos = get_tile_under_cursor()
	if tile_pos == null:
		return
	var current_tile = tilemap.get_cell(tile_pos.x, tile_pos.y)
	# Can only drop an aisle/product on a floor tile
	if current_tile == TILE_TYPES.GROUND:
		tilemap.set_cell(tile_pos.x, tile_pos.y, TILE_TYPES.AISLE)
		var aisle = product_sprite_scene.instance()
		aisle.position = tilemap.map_to_world(tile_pos)
		aisle.product = product
		products_sprite.add_child(aisle)
