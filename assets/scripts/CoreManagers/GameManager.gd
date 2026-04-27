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
var sensitivity = 0


signal level_restarted(level)

func _ready():
	_load_save_data()
	reset_game()


# ── Save System Integration ──────────────────────────────────────────

func _load_save_data():
	var data = SaveManager.load_game(SAVE_SLOT)
	if data.is_empty():
		print("GameManager: No save found, using defaults.")
		return

	# Progression
	if "progression" in data:
		var prog = data["progression"]
		if "levels_unlocked" in prog:
			var levels = prog["levels_unlocked"]
			if levels is Array and levels.size() > 0:
				max_unlocked_level = int(levels.max())

	# Settings
	if "settings" in data:
		var settings = data["settings"]
		if "language" in settings:
			current_language = settings["language"]
		if "music_enabled" in settings:
			SoundOn = settings["music_enabled"]

	print("GameManager: Save loaded. Max unlocked level: ", max_unlocked_level)


func save_game_data():
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
			"level_attempts": 0,
			"game_lives": lives,
			"game_coins": 0
		},
		"settings": {
			"language": current_language,
			"music_enabled": SoundOn,
			"sfx_enabled": SoundOn,
			"sensitivity": 0.0
		},
		"metadata": {
			"last_played": Time.get_datetime_dict_from_system(),
			"version": "1.0"
		}
	}
	SaveManager.save_game(SAVE_SLOT, data)


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
	


func complete_level():
	state = GameState.LEVEL_COMPLETE
	current_level += 1
	# Update progression if the player reached a new high
	if current_level + 1 > max_unlocked_level:
		max_unlocked_level = mini(current_level + 1, TOTAL_LEVELS)
	save_game_data()
