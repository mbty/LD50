extends Control

onready var ammount = $HBoxContainer/Ammount

func _ready():
	pass

func update_money(new_ammount):
	ammount.text = str(new_ammount)
