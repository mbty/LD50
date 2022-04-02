extends Node2D

onready var tilemap = $Navigation2D/TileMap;

func _ready():
	pass # Replace with function body.

func get_tile_under_cursor():
	return tilemap.world_to_map(get_viewport().get_mouse_position() - tilemap.get_global_transform_with_canvas().origin)

func _on_Game_summon_aisle():
	var tile_pos = get_tile_under_cursor()
	if tile_pos == null:
		return
	var current_tile = tilemap.get_cell(tile_pos.x, tile_pos.y)
	if current_tile == 0:
		tilemap.set_cell(tile_pos.x, tile_pos.y, 1)
