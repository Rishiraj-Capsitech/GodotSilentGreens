extends Resource
class_name SoundData

@export var sound_type: SoundType.Values

@export var is_random: bool = false

@export var clip: AudioStream

@export var clips: Array[AudioStream] = []

@export var loop: bool = false

#for minimum volume adjust 
@export_range(0.0,1.0) var min_volume: float = 1.0

#for maximum volume adjust
@export_range(0.0,1.0) var max_volume: float = 1.0
