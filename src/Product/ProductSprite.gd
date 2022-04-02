extends Node2D


var product

func _ready():
	assert(product != null)
	self.texture = product.get_texture()

func init(product):
	self.product = product
