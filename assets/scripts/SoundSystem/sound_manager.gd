extends Node

# Assign in Inspector (your .tres database)
@export var database: SoundDatabase
@export var auto_play_background_music := true

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var service: SoundService
var music_enabled := true
var sfx_enabled := true

func _ready():
	# Create audio players in code so this works both as a scene instance
	# and as an autoload / bare node (no child nodes required in the scene).
	print("Music init")
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)

	# Guard: database must be assigned in the Inspector
	if database == null:
		print("SoundManager: database is not assigned yet. Sound playback is disabled until configured.")
		return

	# Setup service
	service = SoundService.new()
	add_child(service)
	service.setup(database, music_player, sfx_player)

	if auto_play_background_music:
		play_music(SoundType.BACKGROUND_MUSIC)


func play(type: int):
	if service == null:
		return
	if type == SoundType.BACKGROUND_MUSIC:
		if not music_enabled:
			return
	else:
		if not sfx_enabled:
			return
	service.play(type)

func play_music(type: int = SoundType.BACKGROUND_MUSIC):
	if type != SoundType.BACKGROUND_MUSIC:
		return
	play(type)

func play_sfx(type: int):
	if type == SoundType.BACKGROUND_MUSIC:
		return
	play(type)

func stop_music():
	if service == null:
		return
	service.stop_music()

func stop_effects():
	if service == null:
		return
	service.stop_effects()


func set_music(is_on: bool):
	music_enabled = is_on
	if is_on:
		play_music(SoundType.BACKGROUND_MUSIC)
	else:
		stop_music()

func set_sfx(is_on: bool):
	sfx_enabled = is_on
	if not is_on:
		stop_effects()
