extends Reference
class_name PriorityQueue

var data = []

func is_empty():
	return data.size() == 0

func pop():
	return (data.pop_front())[0]

func push(item, priority):
	var i = 0
	while i < data.size() && data[i][1] < priority:
		i += 1
	data.insert(i, [item, priority])
