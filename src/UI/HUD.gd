extends Control

onready var ammount = $HBoxContainer/Ammount
onready var cost = $HBoxContainer/Cost

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
