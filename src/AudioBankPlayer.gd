extends AudioStreamPlayer

export(Array, AudioStream) var sounds

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(sounds)):
		sounds[i] = sounds[i]
		sounds[i].set_loop(false)

func play_sound():
	stream = sounds[randi()%len(sounds)]
	.play()
