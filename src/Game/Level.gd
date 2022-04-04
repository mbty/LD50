extends Node

class_name Level

var days = 5
var start_money = 50
var goal = 500
var map = "Map1"
var level_name = "Level 0"

var current_day = 0

signal end_level

func _init(level_name_, days_, start_money_, goal_, map_):
	level_name = level_name_
	days = days_
	start_money = start_money_
	goal = goal_
	map = map_

func next_day():
	current_day += 1
	if days == current_day:
		self.emit_signal('end_level')

func get_map():
	# TODO send real node
	return map
