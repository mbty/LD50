extends KinematicBody2D

onready var in_store_timer = $in_store_timer
onready var nav = get_parent().get_parent()
onready var map = get_parent().get_parent().get_parent()

var wishlist
var strategy

var in_cart = {}
var money = 30

var speed = 1e4

func _ready():
	assert(wishlist != null)
	assert(strategy != null)
	self.strategy.init(self)


func build_wishlist(available_products):
	self.wishlist = []
	var available_copy = [] + available_products
	var n_wishes = min(randi() % 2 + 1, available_copy.size())
	for i in range(n_wishes):
		var choice_index = randi() % available_copy.size()
		self.wishlist.append(available_copy[choice_index])
		available_copy.remove(choice_index)

func set_strategy(strategy_type):
	if strategy_type == Globals.STRATEGY_TYPE.MIND_OF_STEEL:
		self.strategy = MindOfSteelStrategy.new()
	elif strategy_type == Globals.STRATEGY_TYPE.CHECK_OUT:
		self.strategy = CheckOutStrategy.new()

func _physics_process(_delta):
	var move = self.strategy.next_move()
	move_and_slide(move * _delta)

func enters_range(var product):
	pass

func is_interested(var product):
	pass

func _on_ZenTimer_timeout():
	$Sprite.modulate = Color(255, 0, 0, 1.0)

func is_angry():
	return $ZenTimer.time_left == 0
