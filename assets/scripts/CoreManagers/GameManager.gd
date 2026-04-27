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
var SoundOn = true
var TOTAL_LEVELS=27
var max_unlocked_level=1
var current_language: String = "en"
var showWindWarn = false
var sensitivity := 0.0
var level_attempts := 0


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
		save_game_data()
		return

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
		if "level_attempts" in pdata:
			level_attempts = int(pdata["level_attempts"])
			print("GameManager: Loaded level_attempts = ", level_attempts)

	# Settings
	if "settings" in data:
		var settings = data["settings"]
		if "language" in settings:
			current_language = settings["language"]
		if "music_enabled" in settings:
			SoundOn = settings["music_enabled"]
		if "sensitivity" in settings:
			sensitivity = float(settings["sensitivity"])
		print("GameManager: Loaded settings — lang=", current_language, " sound=", SoundOn)

	print("GameManager: ✓ Save data applied successfully.")


func save_game_data():
	print("GameManager: save_game_data() called")

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
			"level_attempts": level_attempts,
			"game_lives": lives,
			"game_coins": 0
		},
		"settings": {
			"language": current_language,
			"music_enabled": SoundOn,
			"sfx_enabled": SoundOn,
			"sensitivity": sensitivity
		},
		"metadata": {
			"last_played": Time.get_datetime_dict_from_system(),
			"version": "1.0"
		}
	}

	print("GameManager: Saving — max_unlocked=", max_unlocked_level, " attempts=", level_attempts, " lang=", current_language)
	var success = SaveManager.save_game(SAVE_SLOT, data)
	if not success:
		push_error("GameManager: ✗ save_game_data FAILED!")


# ── Game Logic ───────────────────────────────────────────────────────

func reset_game():
	showWindWarn =false
	lives = max_lives
	state = GameState.PLAYING
	UiManager._updateLife(lives)
	emit_signal("level_restarted")
	get_tree().paused = false
	
	
func _start(GAME_PATH):
	get_tree().change_scene_to_file(GAME_PATH)


func lose_life(amount := 1):
	if state != GameState.PLAYING:
		return
	lives -= amount
	lives = clamp(lives, 0, max_lives)
	level_attempts += 1
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
	print("GameManager: complete_level() — current_level=", current_level, " max_unlocked=", max_unlocked_level)
	save_game_data()
