extends Node
class_name SoundService

var lookup := {}

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer


func setup(database: SoundDatabase, music: AudioStreamPlayer, sfx: AudioStreamPlayer):
	music_player = music
	sfx_player = sfx

	# Build lookup dictionary (SoundType → SoundData)
	for sound in database.sounds:
		if sound == null:
			continue
		if not lookup.has(sound.sound_type):
			lookup[sound.sound_type] = sound


func play(type: int):
	if not lookup.has(type):
		return

	var sound: SoundData = lookup[type]
	var clip: AudioStream = _get_clip(sound)

	if clip == null:
		return


	if type == SoundType.BACKGROUND_MUSIC:
		music_player.stream = clip
		music_player.volume_db = linear_to_db(sound.max_volume)
		# Use set() because .loop lives on the concrete subtype (OggVorbis, MP3, etc.),
		# not on the base AudioStream class — direct access causes a runtime error.
		clip.set("loop", sound.loop)
		music_player.play()

	# SFX (PlayOneShot alternative)
	else:
		var volume = randf_range(sound.min_volume, sound.max_volume)

		# Create temporary player (PlayOneShot behavior)
		var temp_player = AudioStreamPlayer.new()
		add_child(temp_player)

		temp_player.stream = clip
		temp_player.volume_db = linear_to_db(volume)
		temp_player.bus = sfx_player.bus # use same audio bus
		temp_player.play()

		# Auto delete after playing
		temp_player.finished.connect(func():
			temp_player.queue_free()
		)


func _get_clip(sound: SoundData) -> AudioStream:
	if sound.is_random and sound.clips.size() > 0:
		return sound.clips.pick_random()

	return sound.clip


func stop_music():
	if music_player:
		music_player.stop()

func stop_effects():
	# Stops base SFX player (not temp ones)
	if sfx_player:
		sfx_player.stop()
