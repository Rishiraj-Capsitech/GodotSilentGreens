extends Node


enum GameState {
	HOME,
	PLAYING,
	PAUSED,
	GAME_OVER,
	LEVEL_COMPLETE
}

const SAVE_SLOT := 0

@export var max_lives: int = 3
var state: GameState = GameState.PLAYING
var builder
var lives: int
var current_level: int = 0
var SoundOn := true
var SfxOn := true
var TOTAL_LEVELS=27
var max_unlocked_level=1
var current_language: String = "en"
var showWindWarn = false
var sensitivity := 0.0
var level_attempts_by_level: Dictionary = {}


signal level_restarted(level)

func _ready():
	_load_save_data()
	reset_game()


# ── Save System Integration ──────────────────────────────────────────

func _load_save_data():
	print("GameManager: _load_save_data() called")
	var data = SaveManager.load_game(SAVE_SLOT)
	if data.is_empty():
		print("GameManager: No save found — creating initial save with defaults.")
		data = SaveDataTemplate.create_default_data()
		_apply_loaded_data(data)
		SaveManager.save_game(SAVE_SLOT, data)
		return
	_apply_loaded_data(data)
	print("GameManager: ✓ Save data applied successfully.")


func _apply_loaded_data(data: Dictionary) -> void:
	# Progression
	if "progression" in data:
		var prog = data["progression"]
		if "levels_unlocked" in prog:
			var levels_arr = prog["levels_unlocked"]
			if levels_arr is Array and levels_arr.size() > 0:
				max_unlocked_level = int(levels_arr.max())
				print("GameManager: Loaded max_unlocked_level = ", max_unlocked_level)

	# Player data
	if "player_data" in data:
		var pdata = data["player_data"]
		if "level_attempts_by_level" in pdata and pdata["level_attempts_by_level"] is Dictionary:
			level_attempts_by_level = pdata["level_attempts_by_level"].duplicate(true)
			print("GameManager: Loaded per-level attempts for ", level_attempts_by_level.size(), " levels")
	_sanitize_level_attempts_map()

	# Settings
	if "settings" in data:
		var settings = data["settings"]
		if "language" in settings:
			current_language = settings["language"]
		if "music_enabled" in settings:
			SoundOn = settings["music_enabled"]
		if "sfx_enabled" in settings:
			SfxOn = settings["sfx_enabled"]
		else:
			SfxOn = SoundOn
		if "sensitivity" in settings:
			sensitivity = float(settings["sensitivity"])
		print("GameManager: Loaded settings — lang=", current_language, " music=", SoundOn, " sfx=", SfxOn)

	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1:
		AudioServer.set_bus_mute(master_bus_idx, not SoundOn)


func save_game_data():
	print("GameManager: save_game_data() called")
	_sanitize_level_attempts_map()

	# Build the levels_unlocked array from max_unlocked_level
	var unlocked_arr := []
	for i in range(1, max_unlocked_level + 1):
		unlocked_arr.append(i)

	# levels_cleared = everything before the highest unlocked
	var cleared_arr := []
	if max_unlocked_level > 1:
		for i in range(1, max_unlocked_level):
			cleared_arr.append(i)

	var data := {
		"progression": {
			"levels_unlocked": unlocked_arr,
			"levels_cleared": cleared_arr
		},
		"player_data": {
			"level_attempts_by_level": level_attempts_by_level,
			"game_lives": lives,
			"game_coins": 0
		},
		"settings": {
			"language": current_language,
			"music_enabled": SoundOn,
			"sfx_enabled": SfxOn,
			"sensitivity": sensitivity
		},
		"metadata": {
			"last_played": Time.get_datetime_dict_from_system(),
			"version": "1.0"
		}
	}

	print("GameManager: Saving — max_unlocked=", max_unlocked_level, " lang=", current_language)
	var success = SaveManager.save_game(SAVE_SLOT, data)
	if not success:
		push_error("GameManager: ✗ save_game_data FAILED!")


func _sanitize_level_attempts_map() -> void:
	var cleaned: Dictionary = {}
	for raw_key in level_attempts_by_level.keys():
		var key_str := str(raw_key)
		if key_str.is_valid_int():
			var key_int := int(key_str)
			if key_int >= 1 and key_int <= TOTAL_LEVELS:
				cleaned[key_str] = int(level_attempts_by_level.get(raw_key, 0))
	level_attempts_by_level = cleaned


func _register_level_entry(level_number: int) -> void:
	var safe_level := clampi(level_number, 1, TOTAL_LEVELS)
	var key := str(safe_level)
	if not level_attempts_by_level.has(key):
		level_attempts_by_level[key] = 0


func register_current_level_for_tracking() -> void:
	_register_level_entry(current_level + 1)


# ── Game Logic ───────────────────────────────────────────────────────

func reset_game():
	showWindWarn =false
	lives = max_lives
	state = GameState.PLAYING
	_register_level_entry(current_level + 1)
	UiManager._updateLife(lives)
	emit_signal("level_restarted")
	get_tree().paused = false
	
	
func _start(GAME_PATH):
	_register_level_entry(current_level + 1)
	get_tree().change_scene_to_file(GAME_PATH)


func lose_life(amount := 1):
	if state != GameState.PLAYING:
		return
	lives -= amount
	lives = clamp(lives, 0, max_lives)
	var safe_level := clampi(current_level + 1, 1, TOTAL_LEVELS)
	_register_level_entry(safe_level)
	var level_key := str(safe_level)
	level_attempts_by_level[level_key] = int(level_attempts_by_level.get(level_key, 0)) + 1
	save_game_data()
	UiManager._updateLife(lives)
	if lives <= 0:
		game_over()
	

func gain_life(amount := 1):
	lives += amount
	lives = clamp(lives, 0, max_lives)


func pause_game():
	if state == GameState.PAUSED:
		return
	
	state = GameState.PAUSED
	get_tree().paused = true
	

func resume_game():
	state = GameState.PLAYING
	get_tree().paused = false


func game_over():
	state = GameState.GAME_OVER
	UiManager._gameOver()
	save_game_data()


func complete_level():
	state = GameState.LEVEL_COMPLETE
	current_level += 1
	# Update progression if the player reached a new high
	if current_level + 1 > max_unlocked_level:
		max_unlocked_level = mini(current_level + 1, TOTAL_LEVELS)
	_register_level_entry(current_level + 1)
	print("GameManager: complete_level() — current_level=", current_level, " max_unlocked=", max_unlocked_level)
	save_game_data()
