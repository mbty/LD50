extends Node2D


var product

func _ready():
	assert(product != null)
	self.texture = product.get_texture()

	var factor = float(Globals.TILE_LENGTH)/float(self.texture.get_width())
	self.scale =  Vector2(factor, factor)

	var half = float(Globals.TILE_LENGTH/2)
	self.position += Vector2(half, half)

func init(product):
	self.product = product
