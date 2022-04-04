extends Strategy

class_name MindOfSteelStrategy

var target

func init(client):
	.init(client)

func get_current_focus():
	return self.client.map.get_checkout_locations()[0]

func next_move():
	#var next_product_location = Vector2.ZERO
	var next_product_location = self.client.map.get_checkout_locations()[0]
	for p in self.client.wishlist:
		if self.client.in_cart.has(p.type):
			continue
		var next_product_locations = self.client.map.get_product_locations(p.type)
		if (next_product_locations.size() > 0):
			next_product_location = next_product_locations[0]
			break
	return .get_path_direction_to(next_product_location)
