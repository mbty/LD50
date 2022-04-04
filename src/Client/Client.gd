extends KinematicBody2D

signal add_to_cart
signal buy
signal left

const MODULATE_WHITE = Color("ffffff")
const MODULATE_RED = Color("f73831")

onready var zen_timer = $ZenTimer
onready var nav = get_parent().get_parent()
onready var map = nav.get_parent()
onready var game = map.get_parent().get_parent()
onready var tick_timer = game.get_node("TickTimer")
onready var products = game.get_node("Products")
onready var sprite = $AnimatedSprite

const FRAMES_VARIANTS = [
	preload("res://assets/sprites/client1.tres"),
	preload("res://assets/sprites/client2.tres"),
	preload("res://assets/sprites/client3.tres"),
]

var animated_modulate = MODULATE_WHITE

var wishlist
var strategy

var in_cart = {}
var money = 30

enum CharacterDirection { UP, RIGHT, DOWN, LEFT }
enum CharacterAnimationState { IDLE, WALK }

var direction = CharacterDirection.RIGHT setget set_direction
var animation_state = CharacterAnimationState.WALK setget set_animation_state

func set_direction(value):
	direction = value
	update_animation()

func set_animation_state(value):
	animation_state = value
	update_animation()

func update_animation():
	var animation = ["idle", "walk"][self.animation_state] + "_" + ["up", "right", "down", "left"][self.direction]
	self.sprite.animation = animation

func _ready():
	var shift = Vector2(randi()%9 - 5, randi()%9 - 5)
	sprite.position += shift
	sprite.z_index = 1000 + position[1] + sprite.position[1]
	assert(wishlist != null)
	assert(strategy != null)
	self.strategy.init(self)
	sprite.frames = FRAMES_VARIANTS[randi() % FRAMES_VARIANTS.size()]
	update_animation()
	$Emoji.z_index = sprite.z_index + 1

func _process(_delta):
	self.modulate = animated_modulate

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
	var pos = (self.position / 32).floor() + Vector2(0, 0)
	return [pos + Vector2.DOWN, pos + Vector2.UP, pos + Vector2.LEFT, pos + Vector2.RIGHT]

var angry_timer = 0
func _on_ZenTimer_timeout():
	angry_timer += 1
	if angry_timer == 1:
		$Sounds/AngrySounds.play_sound()
		$Tween.interpolate_property(
			self, "animated_modulate", animated_modulate, MODULATE_RED,
			zen_timer.wait_time*(2.0/3.0), Tween.TRANS_LINEAR,Tween.EASE_IN_OUT
		)
		$Tween.start()
	elif angry_timer == 2:
		$Sounds/FuraxSounds.play_sound()
		emit_signal("left", self)

func is_angry():
	return zen_timer.time_left == 0

func buy_product(product):
	$Sounds/GrabSounds.play_sound()
	zen_timer.time_left += 5
	emit_signal("buy_product", product)

func get_player_speed():
	return tick_timer.wait_time

func update():
	# If can buy, buy and don't move
	var bought = false
	var can_checkout = false
	for nei in self.get_neighbours():
		if map.product_per_location.has(nei):
			var p = map.product_per_location[nei]
			if p in wishlist and not (p in in_cart):
				wishlist.erase(p)
				add_to_cart(p)
				buy_animation(p, nei)
				bought = true
				break
			elif not (p in self.in_cart):
				if randf() < products.get_child(p).frequency:
					self.add_to_cart(p)
					buy_animation(p, nei)
					bought = true
					break
		elif nei in map.checkout_loc_dic:
			can_checkout = true
	# Otherwise, move
	if !bought:
		if can_checkout and wishlist.size() == 0:
			buy_cart()
		$Sounds/WalkSounds.play_sound()
		var next = strategy.get_next_move()
		if next == null:
			next = self.position
			animation_state = CharacterAnimationState.IDLE
		if next != null:
			$Tween.interpolate_property(
				self, "position", self.position, next, get_player_speed(), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
			)
			$Tween.start()
			if next.x > self.position.x:
				self.direction = CharacterDirection.RIGHT
			elif next.x < self.position.x:
				self.direction = CharacterDirection.LEFT
			
			if next.y > self.position.y:
				self.direction = CharacterDirection.DOWN
				sprite.z_index += 16
				$Emoji.z_index += 16
			elif next.y < self.position.y:
				self.direction = CharacterDirection.UP
				sprite.z_index -= 16
				$Emoji.z_index -= 16
			
			if next.x == self.position.x && next.y == self.position.y:
				self.animation_state = CharacterAnimationState.IDLE
			else:
				self.animation_state = CharacterAnimationState.WALK
		else:
			self.strategy.gen_path(self.strategy.get_next_focus())
			self.animation_state = CharacterAnimationState.IDLE

func add_to_cart(product):
	emit_signal("add_to_cart", self, product)

func buy_cart():
	emit_signal("buy", self)

func _on_Client_buy_product():
	pass

func buy_animation(product, from):
	$Emoji.position = from
	$Emoji.visible = true
	$Emoji.texture = products.get_child(product).get_texture()
	$Tween.interpolate_property(
		$Emoji, "position", from, $AnimatedSprite.position + Vector2(8, 5), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)

func checkout_animation():
	pass
