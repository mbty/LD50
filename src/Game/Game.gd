extends Node

signal summon_aisle

onready var map = $Map

func _ready():
	randomize()
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("summon_aisle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
