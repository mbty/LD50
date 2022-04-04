extends KinematicBody2D

signal buy_product

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
	var move = self.strategy.next_move()
	move_and_slide(move * _delta)

	for nei in self.get_neighbours():
		if map.product_per_location.has(nei):
			var p = map.product_per_location[nei]
			if p in self.wishlist and not (p in self.in_cart):
				self.buy_product(p)

func enters_range(var product):
	pass

func is_interested(var product):
	pass

func _on_ZenTimer_timeout():
	$Sprite.modulate = Color(255, 0, 0, 1.0)

func is_angry():
	return $ZenTimer.time_left == 0

func buy_product(product):
	emit_signal("buy_product", product)
