# ============================================================================
# HomeConfirmation.gd  —  Attach to root "HomeConfirmation"
# in Home_Confirmation.tscn.
# Shows a confirmation dialog before returning to the main menu.
# Confirm → go to main menu.   Cancel → close this overlay.
# ============================================================================
extends Control

const MAIN_MENU_PATH := "res://assets/UI_Scenes/main_menu.tscn"

@onready var confirm_btn : TextureButton = $Confirmation_options/ConfirmButton
@onready var cancel_btn  : TextureButton = $Confirmation_options/CancelButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	confirm_btn.pressed.connect(_on_confirm)
	cancel_btn.pressed.connect(_on_cancel)

	_animate_in()


func _on_confirm() -> void:
	_cleanup_hud()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


## Removes the persistent HUDLayer from the scene root before navigating away.
func _cleanup_hud() -> void:
	var hud_layer = get_tree().root.get_node_or_null("HUDLayer")
	if hud_layer:
		hud_layer.queue_free()


func _on_cancel() -> void:
	queue_free()


# ── Entrance animation ──────────────────────────────────────────────────────

func _animate_in() -> void:
	modulate.a = 0.0
	pivot_offset = size / 2.0
	scale = Vector2(0.9, 0.9)

	var tw := create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE, 0.25)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
