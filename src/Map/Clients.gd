extends Node

signal no_more_clients

var n = 0

func add_child_client(client):
	add_child(client)
	n += 1
	client.connect("tree_exited", self, "client_left")

func client_left():
	n -= 1
	if n == 0:
		emit_signal("no_more_clients")
