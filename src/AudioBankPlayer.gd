extends AudioStreamPlayer

export(Array, AudioStream) var sounds

export var loop: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(sounds)):
		sounds[i] = sounds[i]
		sounds[i].set_loop(loop)

func play_sound():
	if GameState.game_mode != GameState.GameMode.DESIGN:
		stream = sounds[randi()%len(sounds)]
		.play()

func play_exclusive():
	if !self.playing && GameState.game_mode != GameState.GameMode.DESIGN:
		play_sound()
