extends Control

@onready var close_btn          : TextureButton = $CloseButton
@onready var sound_btn          : TextureButton = $SoundButton
@onready var sound_off_icon     : TextureRect   = $SoundButton/Off
@onready var english_btn        : TextureButton = $EnglishButton
@onready var portuguese_btn     : TextureButton = $PortugueseButton
@onready var spanish_btn        : TextureButton = $SpanishButton
@onready var sensitivity_slider : HSlider       = $Senstivity_Slider

var _lang_selected : Texture2D
var _lang_normal   : Texture2D


func _ready() -> void:
 
	process_mode = Node.PROCESS_MODE_ALWAYS

	_lang_selected = preload("res://assets/sprites/UI_art/language selected.png")
	_lang_normal   = preload("res://assets/sprites/UI_art/language not selected.png")
 
	_update_sound_ui()
	_update_language_ui()

	sensitivity_slider.min_value = 0.1
	sensitivity_slider.max_value = 2.0
	sensitivity_slider.step      = 0.01
	sensitivity_slider.value     = GameManager.sensitivity
 
	close_btn.pressed.connect(_on_close)
	sound_btn.pressed.connect(_on_sound_toggle)
	english_btn.pressed.connect(func(): _set_language("en"))
	portuguese_btn.pressed.connect(func(): _set_language("pt"))
	spanish_btn.pressed.connect(func(): _set_language("es"))
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

	if has_node("/root/LocalizationManager"):
		LocalizationManager.locale_changed.connect(func(_l): _update_language_ui())

	_animate_in()
 

func _on_sound_toggle() -> void:
	GameManager.sound_on = not GameManager.sound_on
	AudioServer.set_bus_mute(
		AudioServer.get_bus_index("Master"),
		not GameManager.sound_on
	)
	_update_sound_ui()
	GameManager.save_progress()


func _update_sound_ui() -> void:
	sound_off_icon.visible = not GameManager.sound_on
 

func _set_language(lang: String) -> void:
	GameManager.current_language = lang
	LocalizationManager.set_locale(lang)
	# _update_language_ui is called via signal connection
 
	GameManager.save_progress()


func _update_language_ui() -> void:
	english_btn.texture_normal    = _lang_selected if GameManager.current_language == "en" else _lang_normal
	portuguese_btn.texture_normal = _lang_selected if GameManager.current_language == "pt" else _lang_normal
	spanish_btn.texture_normal    = _lang_selected if GameManager.current_language == "es" else _lang_normal
 

func _on_sensitivity_changed(value: float) -> void:
	GameManager.sensitivity = value
	GameManager.save_progress()
 

func _on_close() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
 

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
