extends Node

enum GameMode {
	DESIGN,
	SIMULATION,
}

var game_mode = GameMode.DESIGN
var selected_product = null

func on_product_selected(product):
	self.selected_product = product
