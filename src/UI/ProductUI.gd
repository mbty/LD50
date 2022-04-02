extends Control

var product

onready var product_texture = $HBoxContainer/ProductTexture
onready var product_name = $HBoxContainer/ProductName

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(product):
	self.product = product
	product_texture.texture = product.get_texture()
	product_name.text = product.get_name()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
