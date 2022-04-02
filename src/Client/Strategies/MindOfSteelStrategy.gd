extends Strategy

class_name MindOfSteelStrategy

var target

func init(client):
	.init(client)
	target = self.client.wishlist[0]

func next_move():
	.next_move()
	
