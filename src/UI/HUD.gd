extends Control

onready var ammount = $HBoxContainer/Ammount
onready var cost = $HBoxContainer/Cost

onready var goal = $GoalDisplay/Objective
onready var current_day = $DaysDisplay/CurrentDay
onready var total_days = $DaysDisplay/NbDaysTotal

func _ready():
	update_cost(0)

func update_money(new_ammount):
	ammount.text = str(new_ammount)

func update_cost(new_cost):
	cost.show()
	cost.modulate = Color(0.0, 0.0, 0.0, 1.0)
	var sign_str = "+" if new_cost < 0 else "-"
	cost.text = "(" + sign_str + str(abs(new_cost)) + "$)"
	if new_cost == 0:
		cost.hide()
	elif new_cost < 0:
		cost.modulate.g = 1.0
	elif new_cost > 0:
		cost.modulate.r = 1.0
		
func update_current_day(new_value):
	current_day.text = str(new_value + 1)
	
func update_total_days(new_value):
	total_days.text =  '/' + str(new_value)
	
func update_goal(new_value):
	goal.text = str(new_value)
