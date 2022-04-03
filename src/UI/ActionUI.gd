extends Control

signal begin_simulation

onready var product_list = $VBoxContainer/HBoxContainer/VBoxContainer/Scroller/ProductList
onready var aisle_price = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/AislePrice
onready var product_ui_scene = preload("res://src/UI/ProductUI.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	aisle_price.text = str(Globals.AISLE_COST)

func _on_Products_new_product(product):
	var product_instance = product_ui_scene.instance()
	product_list.add_child(product_instance)
	product_instance.init(product)
	product_instance.connect("product_selected", GameState, "on_product_selected")

func _on_PlayBtn_button_down():
	emit_signal("begin_simulation")
