extends Reference
class_name PriorityQueue

var data = []

func pop():
	data.pop_front()

func push(item):
	var i = 0
	while i < data.size() && data[i].y < item.y:
		i += 1
	data.insert(i, item)
	print(data)
