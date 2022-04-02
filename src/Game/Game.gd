extends Node

signal summon_aisle

onready var map = $Map
onready var client_scene = preload("res://src/Client/Client.tscn")

func _ready():
	randomize()
	create_client()

func create_client():
	var client = client_scene.instance()
	client.build_wishlist($Products.get_children())
	client.set_strategy(Globals.STRATEGY_TYPE.MIND_OF_STEEL)
	client.position += Vector2(20.0, 20.0)
	$Clients.add_child(client)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and GameState.selected_product != null:
			emit_signal("summon_aisle", GameState.selected_product)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
