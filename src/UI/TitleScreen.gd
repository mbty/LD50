extends Control

onready var credits = $CanvasLayer/Credits
onready var btn = $Node2D/VBoxContainer/CenterContainer2/VBoxContainer/PlayButton
onready var tuto1 = $Tuto1
onready var tuto2 = $Tuto2

func _ready():
	credits.visible = false

func _on_CreditsButton_pressed():
	credits.visible = true

func _on_CloseCreditsButton_pressed():
	credits.visible = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if tuto1.visible:
			tuto1.hide()
			tuto2.show()
		elif tuto2.visible:
			if get_tree().change_scene("res://src/Game/Game.tscn") != OK:
				printerr('error')

func _on_PlayButton_pressed():
	btn.hide()
	tuto1.show()
