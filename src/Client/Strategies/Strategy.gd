extends Reference

class_name Strategy

var client
var nav

var product_location_dict = {}
var path_update_counter = 0
var path_update_frames_delay = 20
var path = []
var path_cp = []

func init(new_client):
	client = new_client
	nav = client.get_parent().get_parent()

func find_path():
	return self.client.position

func path_pop():
	return path.pop_front()

func gen_path(target_loc):
	path = client.map.get_path_(self.client.position, target_loc)

# func get_distance_to_node(node):
# 	var vec_target = node.position - position
# 	vec_target.y /= 2;
# 	return vec_target.length_squared()

func next_move():
	assert(self.client != null)

func get_current_focus():
	assert(self.client != null)

func is_accessible(target_node):
	return not nav.get_simple_path(self.client.position, target_node.position, true).empty()
