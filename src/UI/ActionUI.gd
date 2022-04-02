extends Control

onready var product_list = $HBoxContainer/VBoxContainer/ProductList
onready var product_ui_scene = preload("res://src/UI/ProductUI.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Products_new_product(product):
	var product_instance = product_ui_scene.instance()	
	product_list.add_child(product_instance)
	product_instance.init(product)
