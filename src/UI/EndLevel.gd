extends Control

signal next_level
signal restart

onready var next_level_btn = $Center/VBoxContainer/NextLevelButton
onready var restart_btn = $Center/VBoxContainer/RestartButton
onready var money_label = $Center/VBoxContainer/CenterContainer2/HBoxContainer/Money
onready var objective_label = $Center/VBoxContainer/CenterContainer2/HBoxContainer/Objective
onready var outcome_label = $Center/VBoxContainer/CenterContainer3/Outcome
onready var level_index_label = $Center/VBoxContainer/CenterContainer/HBoxContainer/LevelIndex
onready var level_count_label = $Center/VBoxContainer/CenterContainer/HBoxContainer/LevelCount

func display_screen(money, objective, level_index, level_count):
	self.show()
	money_label.text = "$" + str(money)
	objective_label.text = "$" + str(objective)
	level_index_label.text = str(level_index + 1)
	level_count_label.text = str(level_count)
	
	if money < objective:
		next_level_btn.hide()
		restart_btn.show()
		outcome_label.text = "Level failed ! Bankrupt !"
		outcome_label.modulate = Color(1.0, 0.0, 0.0, 1.0)
	elif level_index >= level_count - 1:
		next_level_btn.hide()
		restart_btn.show()
		outcome_label.text = "Congratulations ! You won the game !"
		outcome_label.modulate = Color(0.0, 1.0, 0.0, 1.0)
	else:
		next_level_btn.show()
		restart_btn.hide()
		outcome_label.text = "Level complete !"
		outcome_label.modulate = Color(0.0, 1.0, 0.0, 1.0)


func _on_NextLevelButton_pressed():
	emit_signal("next_level")
	self.hide()

func _on_RestartButton_pressed():
	emit_signal("restart")
	self.hide()
