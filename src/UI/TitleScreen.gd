extends Control

onready var credits = $Credits
onready var credits_button = $Node2D/VBoxContainer/CenterContainer2/VBoxContainer/CreditsButton

func _ready():
	credits.visible = false

func _on_PlayButton_pressed():
	if get_tree().change_scene("res://src/Game/Game.tscn") != OK:
		printerr('error')

func _on_CreditsButton_pressed():
	credits.visible = credits_button.pressed
