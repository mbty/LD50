extends Strategy

class_name CheckOutStrategy

func next_move():
	var next_product_location = self.client.map.get_checkout_locations()[0]
	return .get_path_direction_to(next_product_location)
	
