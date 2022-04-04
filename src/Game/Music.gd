extends Node

const INTRO = "intro"
const LOOP = "loop"
const END = "end"

const MENU = "musicMenu"
const DSOTM = "DSOTM"
const BOSSA1 = "BOSSA1"

const MUSIC_ATTENUATION_STOP = -20

onready var currentMusic = null
onready var menuMusic = [$bossa1]
onready var simuMusic = [$DSOTM_start, $DSOTM, $DSOTM_end]

onready var currentIntroMusic = null
onready var currentLoopMusic = menuMusic[0]
onready var currentEndMusic = null
onready var nextIntroMusic = simuMusic[0]
onready var nextLoopMusic = simuMusic[1]
onready var nextEndMusic = simuMusic[2]

onready var currentMusicType = LOOP
onready var currentMusicName = BOSSA1
onready var nextMusicName = DSOTM
onready var musicToAttenuate = null
onready var musicAttenuationStart = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	currentMusic = menuMusic[0]
	currentMusic.stream.set_loop(true)
	currentMusic.play()
	currentMusic.connect("finished", self, "_on_CurrentMusic_finished")
	
	
func _on_CurrentMusic_finished():
	match currentMusicType:
		INTRO:
			if (currentLoopMusic != null && currentLoopMusic.stream.has_loop()):
				changeMusic(currentLoopMusic)
				currentMusicType = LOOP
			elif (currentEndMusic != null):
				changeMusic(currentEndMusic)
				currentMusicType = END
			else:
				changeMusicToNext()
		LOOP:
			currentMusic.stream.set_loop(true)
			if (currentEndMusic != null):
				changeMusic(currentEndMusic)
				currentMusicType = END
			else:
				changeMusicToNext()
		END:
			changeMusicToNext()
	
	
func changeMusicToNext():
	musicToAttenuate = null
	if (nextIntroMusic != null):
		changeMusic(nextIntroMusic)
		updateMusicToNext()
		currentMusicType = INTRO
	elif (nextLoopMusic):
		changeMusic(nextLoopMusic)
		updateMusicToNext()
		currentMusicType = LOOP
	elif (nextEndMusic):
		changeMusic(nextEndMusic)
		updateMusicToNext()
		currentMusicType = END
	else:
		nextIntroMusic = currentIntroMusic
		nextLoopMusic = currentLoopMusic
		nextEndMusic = currentEndMusic
		changeMusicToNext()
		
func updateMusicToNext():
	currentMusicName = nextMusicName
	currentIntroMusic = nextIntroMusic
	currentLoopMusic = nextLoopMusic
	currentEndMusic = nextEndMusic
	nextMusicName = null

func menuEnter():
	currentMusic.stream.set_stream_paused(true)
	menuMusic.play()

func menuExit():
	menuMusic.stop()
	currentMusic.stream.set_stream_paused(false)
	
func changeMusic(next):
	currentMusic.disconnect("finished", self, "_on_CurrentMusic_finished")
	currentMusic = next
	currentMusic.play()
	currentMusic.connect("finished", self, "_on_CurrentMusic_finished")
