extends Strategy

class_name MindOfSteelStrategy

var target

func init(client):
	.init(client)

func get_next_focus():
	while self.client.wishlist.size() != 0:
		var locations = self.client.map.get_product_locations(self.client.wishlist[0])
		if locations.size() != 0:
			return locations[0]
	return self.client.map.get_checkout_locations()[0]
