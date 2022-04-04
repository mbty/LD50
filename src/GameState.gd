extends Node

enum GameMode {
	DESIGN,
	SIMULATION,
	WAITING,
}

enum Tool {
	AISLE,
	PRODUCT,
}

var game_mode = GameMode.DESIGN
var selected_tool = Tool.AISLE
var selected_product = null
var gui_rects = []

func on_tool_selected(selected):
	self.selected_tool = selected

func on_product_selected(product):
	self.selected_tool = Tool.PRODUCT
	self.selected_product = product

func can_interact():
	return can_interact_at_position(get_viewport().get_mouse_position())

func can_interact_at_position(position):
	for control in gui_rects:
		if control.is_visible_in_tree() and control.get_rect().has_point(position):
			return false
	return true

func add_gui_rect(control):
	gui_rects.append(control)
