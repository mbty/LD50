extends Node

enum GameMode {
	DESIGN,
	SIMULATION,
}

enum Tool {
	AISLE,
	PRODUCT,
	NONE,
}

var game_mode = GameMode.DESIGN
var selected_tool = Tool.NONE
var selected_product = null

func on_tool_selected(selected):
	if selected != Tool.PRODUCT:
		self.selected_product = null
	self.selected_tool = selected

func on_product_selected(product):
	if product == null:
		self.selected_tool = Tool.NONE
	else:
		self.selected_tool = Tool.PRODUCT
	self.selected_product = product
