extends Control

onready var product_sprite = $ProductSprite

export var show_product = false

func _process(delta):
	if (GameState.selected_product != null) && self.show_product:
		product_sprite.texture = GameState.selected_product.get_texture()
		product_sprite.show()
	else:
		product_sprite.hide()
