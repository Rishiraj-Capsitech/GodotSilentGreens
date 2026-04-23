extends Node
 
signal life_lost(remaining: int)
signal coins_changed(new_count: int)
signal level_completed(level: int)
signal all_levels_completed
signal game_over
 
const SAVE_PATH := "user://save.cfg"
const TOTAL_LEVELS := 30
 
var current_level: int = 1       
var max_unlocked_level: int = 1   
var lives: int = 3                  
var coins: int = 0                  
 
var sound_on: bool = true
var current_language: String = "en"  
var sensitivity: float = 1.0      
 

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_progress()
 
 
func lose_life() -> void:
	if lives <= 0:
		return                   
	lives -= 1
	if lives <= 0:
		game_over.emit()
	else:
		life_lost.emit(lives)
 
func add_coin(amount: int = 1) -> void:
	coins += amount
	coins_changed.emit(coins)
 
func complete_level() -> void:
	var completed := current_level
	if current_level >= max_unlocked_level:
		max_unlocked_level = mini(current_level + 1, TOTAL_LEVELS + 1)
	save_progress()

	current_level += 1
	reset_run()

	if current_level > TOTAL_LEVELS:
		all_levels_completed.emit()
	else:
		level_completed.emit(completed)
 
func reset_run() -> void:
	lives = 3
	coins = 0
 

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "max_unlocked_level", max_unlocked_level)
	config.set_value("settings", "sound_on",   sound_on)
	config.set_value("settings", "language",    current_language)
	config.set_value("settings", "sensitivity", sensitivity)
	config.save(SAVE_PATH)


func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		max_unlocked_level = config.get_value("progress", "max_unlocked_level", 1)
		sound_on           = config.get_value("settings", "sound_on",   true)
		current_language   = config.get_value("settings", "language",    "en")
		sensitivity        = config.get_value("settings", "sensitivity", 1.0)
 
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not sound_on)
	
	if has_node("/root/LocalizationManager"):
		LocalizationManager.set_locale(current_language)
