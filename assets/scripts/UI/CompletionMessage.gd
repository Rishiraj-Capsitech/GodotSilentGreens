# ============================================================================
# CompletionMessage.gd  —  Attach to root "CompletionMessage"
#                           in Completion_Message.tscn
# Shown after the player completes all 30 levels.
# Contains a single Home button that returns to the main menu.
# ============================================================================
extends Control

const MAIN_MENU_PATH := "res://assets/UI_Scenes/main_menu.tscn"

@onready var home_btn : TextureButton = $Options/HomeButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	home_btn.pressed.connect(_on_home)
	_animate_in()


func _on_home() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


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
