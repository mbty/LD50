extends Control

signal next_level
signal restart

onready var next_level_btn = $CenterContainer3/VBoxContainer/NextLevelButton
onready var restart_btn = $CenterContainer3/VBoxContainer/RestartButton
onready var money_label = $CenterContainer3/VBoxContainer/CenterContainer2/HBoxContainer/Money
onready var objective_label = $CenterContainer3/VBoxContainer/CenterContainer2/HBoxContainer/Objective
onready var outcome_label = $CenterContainer3/VBoxContainer/CenterContainer3/Outcome

func display_screen(money, objective):
	self.show()
	money_label.text = str(money) + "$"
	objective_label.text = str(objective) + "$"
	
	if money >= objective:
		next_level_btn.show()
		restart_btn.hide()
		outcome_label.text = "Level complete !"
		outcome_label.modulate = Color(0.0, 1.0, 0.0, 1.0)
	else:
		next_level_btn.hide()
		restart_btn.show()
		outcome_label.text = "Level failed ! Bankrupt !"
		outcome_label.modulate = Color(1.0, 0.0, 0.0, 1.0)


func _on_NextLevelButton_pressed():
	emit_signal("next_level")
	self.hide()

func _on_RestartButton_pressed():
	emit_signal("restart")
	self.hide()
