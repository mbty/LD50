extends Node2D

onready var product_sprite_scene = preload("res://src/Product/ProductSprite.tscn")
onready var nav = $Navigation2D
onready var tilemap = $Navigation2D/TileMap
onready var products = $ProductSprites

func _ready():
	pass # Replace with function body.

func get_tile_under_cursor():
	return tilemap.world_to_map(get_viewport().get_mouse_position() - tilemap.get_global_transform_with_canvas().origin)

func _on_Game_summon_aisle(product):
	var tile_pos = get_tile_under_cursor()
	if tile_pos == null:
		return
	var current_tile = tilemap.get_cell(tile_pos.x, tile_pos.y)
	# Can only drop an aisle/product on a floor tile
	if current_tile == 0:
		tilemap.set_cell(tile_pos.x, tile_pos.y, 1)
		var aisle = product_sprite_scene.instance()
		aisle.position = tilemap.map_to_world(tile_pos)
		aisle.product = product
		products.add_child(aisle)
