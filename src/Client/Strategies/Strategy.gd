extends Reference

class_name Strategy

var client
var nav

var product_location_dict = {}

func init(client):
	self.client = client
	nav = client.get_parent().get_parent()

func next_move():
	assert(self.client != null)

func is_accessible(target_node):
	return not nav.get_simple_path(self.client.position, target_node.position, true).empty()
