extends Control

onready var product_sprite = $ProductSprite
onready var aisle_sprite = $AisleSprite
onready var frame = $Frame

export var show_product = false
export var aisle_texture: Texture

func _process(delta):
	product_sprite.hide()
	aisle_sprite.hide()
	if GameState.game_mode == GameState.GameMode.DESIGN and self.show_product:
		if GameState.selected_tool in [GameState.Tool.PRODUCT, GameState.Tool.AISLE]:
			frame.modulate.a = 1
			if GameState.selected_tool == GameState.Tool.PRODUCT:
				product_sprite.texture = GameState.selected_product.get_texture()
				product_sprite.show()
			elif GameState.selected_tool == GameState.Tool.AISLE:
				product_sprite.texture = self.aisle_texture
				aisle_sprite.show()
	else:
		product_sprite.hide()
		frame.modulate.a = 0.3
