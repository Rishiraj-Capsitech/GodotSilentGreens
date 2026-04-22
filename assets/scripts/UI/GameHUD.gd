# ============================================================================
# GameHUD.gd  —  Attach to root "GameHUD" in Game_HUD.tscn
# Displays level number, coin count, 3 lives, and a pause button.
# Listens to GameManager signals to update lives, coins, and trigger
# overlays for game-over / level-completion.
# ============================================================================
extends Control

const PAUSE_PANEL_PATH := "res://assets/UI_Scenes/Pause_Panel.tscn"
const GAME_OVER_PATH   := "res://assets/UI_Scenes/GameOver.tscn"
const COMPLETION_PATH  := "res://assets/UI_Scenes/Completion_Message.tscn"

@onready var pause_btn    : TextureButton = $PauseButton
@onready var coins_label  : Label         = $CoinGroup/CoinsCount
@onready var level_label  : Label         = $Level/LevelCount
@onready var _life_done_1 : TextureRect   = $Life_Bar/life1/Done
@onready var _life_done_2 : TextureRect   = $Life_Bar/life2/Done2
@onready var _life_done_3 : TextureRect   = $Life_Bar/life3/Done3

var _life_icons : Array[TextureRect] = []


func _ready() -> void:
	# Must process even when tree is paused (overlay children run during pause)
	process_mode = Node.PROCESS_MODE_ALWAYS

	_life_icons = [_life_done_1, _life_done_2, _life_done_3]

	# ── Initial display ───────────────────────────────────────────────
	level_label.text = str(GameManager.current_level)
	coins_label.text = str(GameManager.coins)
	_update_lives_display(GameManager.lives)

	# ── Signal connections ────────────────────────────────────────────
	GameManager.life_lost.connect(_on_life_lost)
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.all_levels_completed.connect(_on_all_completed)
	pause_btn.pressed.connect(_on_pause)


# ── Lives ────────────────────────────────────────────────────────────────────

func _on_life_lost(remaining: int) -> void:
	_update_lives_display(remaining)


## Hides "Done" children right-to-left as lives are lost.
##   3 lives → all visible
##   2 lives → Done3 hidden
##   1 life  → Done3 + Done2 hidden
##   0 lives → all hidden
func _update_lives_display(remaining: int) -> void:
	for i in range(_life_icons.size()):
		_life_icons[i].visible = (i < remaining)


# ── Coins ────────────────────────────────────────────────────────────────────

func _on_coins_changed(new_count: int) -> void:
	coins_label.text = str(new_count)


# ── Level Completed ──────────────────────────────────────────────────────────

func _on_level_completed(_completed_level: int) -> void:
	# Refresh HUD for the new level
	level_label.text = str(GameManager.current_level)
	coins_label.text = str(GameManager.coins)
	_update_lives_display(GameManager.lives)


# ── Pause ────────────────────────────────────────────────────────────────────

func _on_pause() -> void:
	get_tree().paused = true
	var panel = load(PAUSE_PANEL_PATH).instantiate()
	add_child(panel)


# ── Game Over ────────────────────────────────────────────────────────────────

func _on_game_over() -> void:
	_update_lives_display(0)
	get_tree().paused = true
	var panel = load(GAME_OVER_PATH).instantiate()
	add_child(panel)


# ── All Levels Completed ────────────────────────────────────────────────────

func _on_all_completed() -> void:
	get_tree().paused = true
	var panel = load(COMPLETION_PATH).instantiate()
	add_child(panel)


# ── Cleanup ──────────────────────────────────────────────────────────────────

func _exit_tree() -> void:
	if GameManager.life_lost.is_connected(_on_life_lost):
		GameManager.life_lost.disconnect(_on_life_lost)
	if GameManager.coins_changed.is_connected(_on_coins_changed):
		GameManager.coins_changed.disconnect(_on_coins_changed)
	if GameManager.game_over.is_connected(_on_game_over):
		GameManager.game_over.disconnect(_on_game_over)
	if GameManager.level_completed.is_connected(_on_level_completed):
		GameManager.level_completed.disconnect(_on_level_completed)
	if GameManager.all_levels_completed.is_connected(_on_all_completed):
		GameManager.all_levels_completed.disconnect(_on_all_completed)
