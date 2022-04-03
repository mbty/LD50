extends Node

const INTRO = "intro"
const LOOP = "loop"
const END = "end"

const MENU = "musicMenu"
const DSOTM = "DSOTM"

const MUSIC_ATTENUATION_STOP = -20

onready var currentIntroMusic = $DSOTM_start
onready var currentLoopMusic = $DSOTM
onready var currentEndMusic = $DSOTM_end
onready var nextIntroMusic = null
onready var nextLoopMusic = null
onready var nextEndMusic = null
onready var currentMusic = null
onready var menuMusic = null

onready var currentMusicType = INTRO
onready var currentMusicName = DSOTM
onready var nextMusicName = null
onready var musicToAttenuate = null
onready var musicAttenuationStart = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	currentMusic = $DSOTM_start
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
