extends KinematicBody2D

signal add_to_cart
signal buy
signal left

onready var zen_timer = $ZenTimer
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
	self.strategy.gen_path(self.strategy.get_current_focus())

func build_wishlist(available_products):
	self.wishlist = []
	var available_copy = [] + available_products
	var n_wishes = min(randi() % 2 + 1, available_copy.size())
	for _i in range(n_wishes):
		var choice_index = randi() % available_copy.size()
		self.wishlist.append(available_copy[choice_index].type)
		available_copy.remove(choice_index)

func set_strategy(strategy_type):
	if strategy_type == Globals.STRATEGY_TYPE.MIND_OF_STEEL:
		self.strategy = MindOfSteelStrategy.new()
	elif strategy_type == Globals.STRATEGY_TYPE.CHECK_OUT:
		self.strategy = CheckOutStrategy.new()

func get_neighbours():
	var pos = (self.position / 32).floor()
	return [pos, pos + Vector2.DOWN, pos + Vector2.UP, pos + Vector2.LEFT, pos + Vector2.RIGHT]

func _physics_process(_delta):
	for nei in self.get_neighbours():
		if map.product_per_location.has(nei):
			var p = map.product_per_location[nei]
			if p in self.wishlist and not (p in self.in_cart):
				self.add_to_cart(p)
		elif nei in map.checkout_loc_dic and not self.in_cart.empty():
			buy_cart()
		elif nei in map.checkout_loc_dic and self.in_cart.empty():
			print('checkout but empty !')

#func enters_range(var product):
#	pass

#func is_interested(var product):
#	pass

func _on_ZenTimer_timeout():
	$Sprite.modulate = Color(255, 0, 0, 1.0)
	emit_signal("left", self)

func is_angry():
	return zen_timer.time_left == 0

func buy_product(product):
	emit_signal("buy_product", product)

func move():
	var next = self.strategy.path.pop_front()
	if next != null:
		self.position = next

func add_to_cart(product):
	emit_signal("add_to_cart", self, product)

func buy_cart():
	emit_signal("buy", self)

func _on_Client_buy_product():
	pass
