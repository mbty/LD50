extends Control

signal product_selected

var product

onready var product_texture = $ProductTexture
onready var product_name = $ProductName

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(product):
	self.product = product
	product_texture.texture = product.get_texture()
	product_name.text = product.get_name()

func _on_ProductUI_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("product_selected", self.product)
