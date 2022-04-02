extends Node

onready var in_store_timer = $in_store_timer

var wishlist
var strategy

var in_cart = []
var money = 30

func _ready():
	assert(wishlist != null)
	assert(strategy != null)

func build_wishlist(available_products):
	self.wishlist = []
	var n_wishes = max(randi() % 1 + 1, available_products.size())
	for i in range(n_wishes):
		var choice_index = randi() % available_products.size()
		self.wishlist.append(available_products[choice_index])
		available_products.remove(choice_index)

func set_strategy(strategy_type):
	if strategy_type == Globals.STRATEGY_TYPE.MIND_OF_STEEL:
		self.strategy = MindOfSteelStrategy.new()

func _process(delta):
	pass

func enters_range(var product):
	pass

func is_interested(var product):
	pass
