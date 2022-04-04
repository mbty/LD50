extends Node

const INTRO = "intro"
const LOOP = "loop"
const END = "end"

const MENU = "musicMenu"

const MUSIC_ATTENUATION_STOP = -20

onready var currentMusic = null
onready var menuMusic = [null, $bossax, null]
onready var simuMusic = [$DSOTM_start, $DSOTM, $DSOTM_end]

onready var currentIntroMusic = menuMusic[0]
onready var currentLoopMusic = menuMusic[1]
onready var currentEndMusic = menuMusic[2]
onready var nextIntroMusic = simuMusic[0]
onready var nextLoopMusic = simuMusic[1]
onready var nextEndMusic = simuMusic[2]

onready var currentMusicType = LOOP
onready var currentMusicName = Globals.BOSSAX
onready var nextMusicName = Globals.DSOTM
onready var musicToAttenuate = null
onready var musicAttenuationStart = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	currentMusic = currentLoopMusic
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
	if (nextIntroMusic):
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
	
func cutCurrentMusic():
	if (currentMusicName == Globals.DSOTM || currentMusicName == Globals.BOSSAX):
		currentMusic.disconnect("finished", self, "_on_CurrentMusic_finished")
		musicToAttenuate = currentMusic
		musicAttenuationStart = currentMusic.get_volume_db()
		$TweenMusicChange.interpolate_method(
			musicToAttenuate,
			"set_volume_db",
			musicAttenuationStart,
			MUSIC_ATTENUATION_STOP,
			Globals.TRANSITION,
			Tween.TRANS_LINEAR,
			Tween.EASE_OUT
			)
		$TweenMusicChange.start()
	
func changeMusic(next):
	currentMusic.disconnect("finished", self, "_on_CurrentMusic_finished")
	currentMusic = next
	currentMusic.play()
	currentMusic.connect("finished", self, "_on_CurrentMusic_finished")
	
func _on_TweenMusicChange_tween_all_completed():
	currentMusic.stop()
	musicToAttenuate.set_volume_db(musicAttenuationStart)
	changeMusicToNext()

func chargeNextMusic(name):
	if (name == Globals.DSOTM):
		nextIntroMusic = simuMusic[0]
		nextLoopMusic = simuMusic[1]
		nextEndMusic = simuMusic[2]
	elif (name == Globals.BOSSAX):
		nextIntroMusic = menuMusic[0]
		nextLoopMusic = menuMusic[1]
		nextEndMusic = menuMusic[2]
	nextMusicName = name
