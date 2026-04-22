# ============================================================================
# GameManager.gd  —  Autoload Singleton
# Manages global game state: levels, lives, coins, settings.
# Register via  Project → Project Settings → Autoload  (or project.godot).
# ============================================================================
extends Node

# ── Signals ──────────────────────────────────────────────────────────────────
signal life_lost(remaining: int)
signal coins_changed(new_count: int)
signal level_completed(level: int)
signal all_levels_completed
signal game_over

# ── Constants ────────────────────────────────────────────────────────────────
const SAVE_PATH := "user://save.cfg"
const TOTAL_LEVELS := 30

# ── Game State ───────────────────────────────────────────────────────────────
var current_level: int = 1          ## 1-based level the player is currently on
var max_unlocked_level: int = 1     ## Highest unlocked level (persisted)
var lives: int = 3                  ## Lives remaining in current level attempt
var coins: int = 0                  ## Coins collected in current level

# ── Settings ─────────────────────────────────────────────────────────────────
var sound_on: bool = true
var current_language: String = "en"  ## "en" / "pt" / "es"
var sensitivity: float = 1.0        ## 0.1 – 2.0  (matches Unity range)


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_progress()


# ── Gameplay API ─────────────────────────────────────────────────────────────

## Called by the ball whenever a life is lost.
func lose_life() -> void:
	if lives <= 0:
		return                      # Already in game-over state
	lives -= 1
	if lives <= 0:
		game_over.emit()
	else:
		life_lost.emit(lives)


## Placeholder – call this from a coin collectible when implemented.
func add_coin(amount: int = 1) -> void:
	coins += amount
	coins_changed.emit(coins)


## Called by Flag when the ball reaches the goal.
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


## Resets lives & coins for a fresh level attempt.
func reset_run() -> void:
	lives = 3
	coins = 0


# ── Persistence ──────────────────────────────────────────────────────────────

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
	# Apply saved audio state
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not sound_on)
