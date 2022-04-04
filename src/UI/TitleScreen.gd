extends Control

func _on_PlayButton_pressed():
	if get_tree().change_scene("res://src/Game/Game.tscn") != OK:
		printerr('error')
