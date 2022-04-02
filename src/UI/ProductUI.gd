extends Control

var product
signal product_selected

onready var product_texture = $ProductTexture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	self.pressed = GameState.selected_product == product

func init(product):
	self.product = product
	product_texture.texture = product.get_texture()
	self.hint_tooltip = product.get_name()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ProductUI_pressed():
	if product == GameState.selected_product:
		emit_signal("product_selected", null)
	else:
		emit_signal("product_selected", product)
