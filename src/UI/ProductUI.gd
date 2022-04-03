extends Control

var product
signal product_selected

onready var product_texture = $ProductTexture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	self.pressed = (
		GameState.selected_tool == GameState.Tool.PRODUCT and
		GameState.selected_product == product
	)

func init(product):
	self.product = product
	product_texture.texture = product.get_texture()
	self.hint_tooltip = product.get_name()

func _on_ProductUI_pressed():
	emit_signal("product_selected", product)
