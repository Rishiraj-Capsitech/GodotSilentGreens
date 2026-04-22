# ============================================================================
# LevelItem.gd  —  Attach to root "LevelItem" in LevelItem.tscn
# Represents a single level button in the main-menu carousel.
# Three visual states:
#   • Completed  — number visible, lock hidden, normal texture
#   • Current    — number visible, lock hidden, highlighted texture
#   • Locked     — number HIDDEN, lock visible, disabled texture
# ============================================================================
extends Control

signal level_selected(level_number: int)

@onready var level_button : TextureButton = $LevelButton
@onready var number_label : Label         = $LevelButton/Number
@onready var lock_icon    : TextureRect   = $LevelButton/Lock

var _level_number  : int = 0
var _selected_tex  : Texture2D


func _ready() -> void:
	_selected_tex = preload("res://assets/UI_art/main level button.png")

	# ── Fix child sizing for carousel display ────────────────────────
	# The .tscn was authored at a very large resolution (font 500,
	# offsets 700+ px).  Re-anchor children so they render correctly
	# inside the ~70×70 item that the HBoxContainer gives us.
	level_button.clip_contents = true

	# Number label → fill the button
	number_label.anchor_left   = 0.0
	number_label.anchor_top    = 0.0
	number_label.anchor_right  = 1.0
	number_label.anchor_bottom = 1.0
	number_label.offset_left   = 0.0
	number_label.offset_top    = 0.0
	number_label.offset_right  = 0.0
	number_label.offset_bottom = 0.0
	number_label.add_theme_font_size_override("font_size", 28)

	# Lock icon → centred 48x48 within the button
	lock_icon.anchor_left   = 0.5
	lock_icon.anchor_top    = 0.5
	lock_icon.anchor_right  = 0.5
	lock_icon.anchor_bottom = 0.5
	lock_icon.offset_left   = -24.0
	lock_icon.offset_top    = -24.0
	lock_icon.offset_right  = 24.0
	lock_icon.offset_bottom = 24.0


## Call right after instantiation to configure this button.
## [param p_level]      1-based level number.
## [param is_unlocked]  true  if level ≤ max_unlocked_level.
## [param is_current]   true  if level == max_unlocked_level.
func setup(p_level: int, is_unlocked: bool, is_current: bool = false) -> void:
	_level_number   = p_level
	number_label.text = str(p_level)

	if is_unlocked:
		level_button.disabled  = false
		number_label.visible   = true
		lock_icon.visible      = false
		# Highlight the latest-unlocked level with the selected texture
		if is_current:
			level_button.texture_normal = _selected_tex
	else:
		# Locked: hide number, show lock, disable button
		level_button.disabled  = true
		number_label.visible   = false
		lock_icon.visible      = true

	# Connect only once (guard against duplicate connections)
	if not level_button.pressed.is_connected(_on_pressed):
		level_button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	level_selected.emit(_level_number)
