extends Node2D


onready var sprite = $Sprite
var product

func _ready():
	assert(product != null)
	$Sprite.texture = product.get_texture()

func init(product):
	self.product = product
