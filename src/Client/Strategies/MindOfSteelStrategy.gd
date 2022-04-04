extends Strategy

class_name MindOfSteelStrategy

var target

func init(client):
	.init(client)

func locations_attempt(locations):
	for location in locations:
		var cpath = client.map.get_path_(client.position, location)
		if path == null || cpath.size() < path.size():
			path = cpath

func get_next_path():
	path = null
	while self.client.wishlist.size() != 0:
		locations_attempt(self.client.map.get_product_locations(self.client.wishlist[0]))
		if path == null:
			client.wishlist.pop_front()
		else:
			return
	locations_attempt(self.client.map.get_checkout_locations())

func get_next_move():
	if path == null || path == []:
		get_next_path()
		if path == null:
			return null
	return path.pop_front()
