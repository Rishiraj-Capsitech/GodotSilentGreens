# ============================================================================
# PausePanel.gd  —  Attach to root "PausePanel" in Pause_Panel.tscn
# Provides Home, Restart, Resume, and Settings buttons.
# Runs with PROCESS_MODE_ALWAYS so UI works while tree is paused.
# ============================================================================
extends Control

const MAIN_MENU_PATH   := "res://assets/UI_Scenes/main_menu.tscn"
const SETTINGS_PATH    := "res://assets/UI_Scenes/Settings.tscn"
const HOME_CONFIRM_PATH := "res://assets/UI_Scenes/Home_Confirmation.tscn"

@onready var home_btn     : TextureButton = $Pause_options/HomeButton
@onready var restart_btn  : TextureButton = $Pause_options/RestartButton
@onready var resume_btn   : TextureButton = $Pause_options/ResumeButton
@onready var settings_btn : TextureButton = $CloseButton   # top-right settings icon


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	home_btn.pressed.connect(_on_home)
	restart_btn.pressed.connect(_on_restart)
	resume_btn.pressed.connect(_on_resume)
	settings_btn.pressed.connect(_on_settings)

	_animate_in()


# ── Actions ──────────────────────────────────────────────────────────────────

func _on_home() -> void:
	# Show confirmation dialog instead of going directly
	if not has_node("HomeConfirmation"):
		var panel = load(HOME_CONFIRM_PATH).instantiate()
		add_child(panel)


func _on_restart() -> void:
	_cleanup_hud()
	get_tree().paused = false
	GameManager.reset_run()
	get_tree().reload_current_scene()


## Removes the persistent HUDLayer from the scene root before navigating away.
func _cleanup_hud() -> void:
	var hud_layer = get_tree().root.get_node_or_null("HUDLayer")
	if hud_layer:
		hud_layer.queue_free()


func _on_resume() -> void:
	get_tree().paused = false
	queue_free()


func _on_settings() -> void:
	# Only one settings overlay at a time
	if not has_node("Settings"):
		var settings = load(SETTINGS_PATH).instantiate()
		add_child(settings)


# ── Entrance animation ──────────────────────────────────────────────────────

func _animate_in() -> void:
	modulate.a = 0.0
	pivot_offset = size / 2.0
	scale = Vector2(0.9, 0.9)

	var tween := create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
