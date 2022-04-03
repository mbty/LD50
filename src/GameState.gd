extends Node

enum GameMode {
	DESIGN,
	SIMULATION,
}

enum Tool {
	AISLE,
	PRODUCT,
}

var game_mode = GameMode.DESIGN
var selected_tool = Tool.AISLE
var selected_product = null

func on_tool_selected(selected):
	self.selected_tool = selected

func on_product_selected(product):
	self.selected_tool = Tool.PRODUCT
	self.selected_product = product
