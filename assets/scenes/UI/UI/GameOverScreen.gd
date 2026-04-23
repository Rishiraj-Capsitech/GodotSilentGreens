extends Control

const MAIN_MENU_PATH    := "res://assets/UI_Scenes/main_menu.tscn"
const HOME_CONFIRM_PATH := "res://assets/UI_Scenes/Home_Confirmation.tscn"

@onready var home_btn    : TextureButton = $Container/HomeButton
@onready var restart_btn : TextureButton = $Container/RestartButton
@onready var skip_btn    : TextureButton = $Container/SkipButton
@onready var back_panel  : TextureRect   = $Back_panel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
 
	skip_btn.disabled = true
 
	back_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	home_btn.pressed.connect(_on_home)
	restart_btn.pressed.connect(_on_restart)

	_animate_in()
 

func _on_home() -> void:
	_cleanup_hud()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_restart() -> void:
	_cleanup_hud()
	get_tree().paused = false
	GameManager.reset_run()
	get_tree().reload_current_scene()
 
func _cleanup_hud() -> void:
	var hud_layer = get_tree().root.get_node_or_null("HUDLayer")
	if hud_layer:
		hud_layer.queue_free()
 

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
