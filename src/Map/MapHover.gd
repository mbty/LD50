extends Control

onready var product_sprite = $ProductSprite
onready var frame = $Frame

export var show_product = false

func _process(delta):
	if GameState.selected_product != null && self.show_product:
		frame.modulate.a = 1
		product_sprite.texture = GameState.selected_product.get_texture()
		product_sprite.show()
	else:
		product_sprite.hide()
		frame.modulate.a = 0.3
