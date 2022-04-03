extends Reference

class_name Strategy

var client
var nav

var product_location_dict = {}
var path_update_counter = 0
var path_update_frames_delay = 20
var path = []

func init(client):
	self.client = client
	nav = client.get_parent().get_parent()

func find_path():
	return self.client.position

func get_path_direction_to(target_loc):
	var position = self.client.position
	if (target_loc - position).length_squared() < pow(40 * 64, 2):
		path_update_counter = path_update_counter + 1
		if (path_update_counter % path_update_frames_delay == 0):
			path = nav.get_simple_path(position, target_loc, false)

		while not path.empty() and position.distance_to(path[0]) < 1:
			path.remove(0)

		if path.empty():
			# We are really close from the target, go directly to it
			return (target_loc - position).normalized() * self.client.speed

		return (path[0] - position).normalized() * self.client.speed

	return Vector2(0, 0)

# func get_distance_to_node(node):
# 	var vec_target = node.position - position
# 	vec_target.y /= 2;
# 	return vec_target.length_squared()

func next_move():
	assert(self.client != null)

func is_accessible(target_node):
	return not nav.get_simple_path(self.client.position, target_node.position, true).empty()
