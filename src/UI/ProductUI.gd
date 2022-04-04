extends Control

var product
signal product_selected

onready var product_texture = $ProductTexture
onready var enculade_theme = preload("res://assets/design2.tres")

func _process(_delta):
	self.pressed = (
		GameState.selected_tool == GameState.Tool.PRODUCT and
		GameState.selected_product == product
	)

func init(new_product):
	self.product = new_product
	product_texture.texture = product.get_texture()
	self.hint_tooltip = product.get_name()
	if product.is_enculade():
		self.theme = enculade_theme

func _on_ProductUI_pressed():
	emit_signal("product_selected", product)
