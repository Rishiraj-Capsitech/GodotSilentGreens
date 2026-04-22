# ============================================================================
# SplashScreen.gd  —  Attach to root "SplashScreen" in Splash_Screen.tscn
# Shows the splash logo for 3 seconds (smooth fade-in → hold → fade-out),
# then transitions to the main menu.
# ============================================================================
extends Control

const MAIN_MENU_PATH := "res://assets/UI_Scenes/main_menu.tscn"
const FADE_IN  := 1.0
const HOLD     := 1.0
const FADE_OUT := 1.0

@onready var logo: TextureRect = $GameWise_Logo


func _ready() -> void:
	logo.modulate.a = 0.0

	# Wait one frame so layout is settled
	await get_tree().process_frame

	var tw := create_tween()
	tw.tween_property(logo, "modulate:a", 1.0, FADE_IN) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(HOLD)
	tw.tween_property(logo, "modulate:a", 0.0, FADE_OUT) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_go_to_main_menu)


func _go_to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
