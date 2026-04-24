extends Node


enum GameState {
	HOME,
	PLAYING,
	PAUSED,
	GAME_OVER,
	LEVEL_COMPLETE
}


@export var max_lives: int = 3
var state: GameState = GameState.PLAYING
var builder
var lives: int
var current_level: int = 0
var SoundOn = true
var TOTAL_LEVELS=27
var max_unlocked_level=27
var current_language: String = "en"



signal level_restarted(level)

func _ready():
	reset_game()
	

func reset_game():
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
