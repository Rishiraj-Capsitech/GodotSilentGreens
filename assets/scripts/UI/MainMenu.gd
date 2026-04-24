 
extends Control

const LEVEL_ITEM_PATH := "res://assets/scenes/UI/UI_Scenes/LevelItem.tscn"
#const SETTINGS_PATH   := "res://assets/UI_Scenes/Settings.tscn"
#const GAME_PATH       := "res://assets/scenes/Main/game.tscn"
 
const ITEM_SIZE       := 75.0        
const ITEM_SPACING    := 30.0      
const HIGHLIGHT_SCALE := 1.15        
const SCALE_LERP      := 12.0        
const SCROLL_DURATION := 0.3       
const INERTIA_DECAY   := 5.0        
const DRAG_THRESHOLD  := 6.0       

@onready var settings_btn : TextureButton   = $SettingsButton
@onready var arrow_left   : TextureButton   = $HBoxContainer/Arrowleft
@onready var arrow_right  : TextureButton   = $HBoxContainer/Arrowright
@onready var scroll_cont  : ScrollContainer = $HBoxContainer/ScrollContainer
@onready var level_row    : HBoxContainer   = $HBoxContainer/ScrollContainer/LevelRow

var _level_item_scene : PackedScene
var _items            : Array[Control] = []
var _scroll_tween     : Tween

# Drag state
var _dragging         := false
var _drag_started     := false   
var _drag_origin_x    := 0.0       
var _drag_velocity    := 0.0
var _last_delta_time  := 0.016


func _ready() -> void:
	_level_item_scene = load(LEVEL_ITEM_PATH)
 
	for style_name in ["scroll", "grabber", "grabber_highlight", "grabber_pressed"]:
		scroll_cont.get_h_scroll_bar().add_theme_stylebox_override(
			style_name, StyleBoxEmpty.new()
		)
		
	level_row.add_theme_constant_override("separation", int(ITEM_SPACING))

	settings_btn.pressed.connect(_on_settings)
	arrow_left.pressed.connect(_on_arrow_left)
	arrow_right.pressed.connect(_on_arrow_right)
	
	await _spawn_levels()
	await get_tree().process_frame 

	var idx = clampi(GameManager.max_unlocked_level - 1, 0, _items.size() - 1)
	_snap_scroll_to(idx)


func _process(delta: float) -> void:
	_last_delta_time = delta
	_update_carousel_scales(delta)
 
	if not _dragging and (_scroll_tween == null or not _scroll_tween.is_valid()):
		if absf(_drag_velocity) > 1.0:
			scroll_cont.scroll_horizontal += int(_drag_velocity * delta)
			_drag_velocity = lerpf(_drag_velocity, 0.0, INERTIA_DECAY * delta)
		else:
			_drag_velocity = 0.0
 

func _input(event: InputEvent) -> void:
 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var scroll_rect = scroll_cont.get_global_rect()
		if event.pressed:
			if scroll_rect.has_point(event.global_position):
				_dragging = true
				_drag_started = false
				_drag_origin_x = event.global_position.x
				_drag_velocity = 0.0
 
				if _scroll_tween and _scroll_tween.is_valid():
					_scroll_tween.kill()
		else:
			_dragging = false
			_drag_started = false

	elif event is InputEventMouseMotion and _dragging:
		var moved = absf(event.global_position.x - _drag_origin_x)
		if moved > DRAG_THRESHOLD:
			_drag_started = true

		if _drag_started:
			scroll_cont.scroll_horizontal -= int(event.relative.x)
			if _last_delta_time > 0.001:
				_drag_velocity = -event.relative.x / _last_delta_time
 

func _spawn_levels() -> void:
	for child in level_row.get_children():
		child.queue_free()
	_items.clear()
	
	await get_tree().process_frame
	var half_w:=scroll_cont.size.x/2.0
	
	var left_pad := Control.new()
	left_pad.custom_minimum_size = Vector2(half_w, ITEM_SIZE)
	level_row.add_child(left_pad)

	for i in range(1, GameManager.TOTAL_LEVELS + 1):
		var item: Control = _level_item_scene.instantiate()
		level_row.add_child(item)

		item.custom_minimum_size = Vector2(ITEM_SIZE, ITEM_SIZE)
		item.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item.size_flags_vertical   = Control.SIZE_SHRINK_CENTER

		var is_unlocked = i <= GameManager.max_unlocked_level
		var is_current  = i == GameManager.max_unlocked_level
		item.setup(i, is_unlocked, is_current)
		item.level_selected.connect(_on_level_selected)
		_items.append(item)
		
	var right_pad := Control.new()
	right_pad.custom_minimum_size = Vector2(half_w, ITEM_SIZE)
	level_row.add_child(right_pad)


func _on_level_selected(level_number: int) -> void:
 
	if _drag_started:
		return

	var idx = level_number - 1
	if idx >= 0 and idx < _items.size():
		_smooth_scroll_to(idx)

	await get_tree().create_timer(SCROLL_DURATION + 0.1).timeout

	GameManager.current_level = level_number
	GameManager.reset_run()
	#get_tree().change_scene_to_file(GAME_PATH)
 

func _update_carousel_scales(delta: float) -> void:
	if _items.is_empty():
		return

	var scroll_center = scroll_cont.scroll_horizontal + scroll_cont.size.x / 2.0

	for item in _items:
 
		var item_center_x = item.position.x + item.size.x / 2.0
		var dist = absf(item_center_x - scroll_center)
 
		var half_zone = ITEM_SIZE + ITEM_SPACING
		var t = clampf(1.0 - dist / half_zone, 0.0, 1.0)
		var target_scale = lerpf(1.0, HIGHLIGHT_SCALE, t)
 
		var current_scale = item.scale.x
		var new_scale = lerpf(current_scale, target_scale, SCALE_LERP * delta)
		item.pivot_offset = item.size / 2.0
		item.scale = Vector2(new_scale, new_scale)
 
		var max_dist = scroll_cont.size.x / 2.0
		var fade_t = clampf(1.0 - (dist / max_dist), 0.0, 1.0)
 
		var target_alpha = clampf(fade_t * 1.5, 0.2, 1.0)
 
		item.modulate.a = lerpf(item.modulate.a, target_alpha, SCALE_LERP * delta)
 
func _item_center_x(index: int) -> float:
	var item = _items[index]
	return item.position.x + item.size.x / 2.0

func _scroll_target_for_item(index: int) -> int:
	var target_x = _item_center_x(index) - scroll_cont.size.x / 2.0
	return clampi(int(target_x), 0, int(_max_scroll()))

func _max_scroll() -> float:
	return maxf(0.0, level_row.size.x - scroll_cont.size.x)

func _snap_scroll_to(index: int) -> void:
	scroll_cont.scroll_horizontal = _scroll_target_for_item(index)

func _smooth_scroll_to(index: int) -> void:
	_tween_scroll(_scroll_target_for_item(index))

func _tween_scroll(target: int) -> void:
	_drag_velocity = 0.0
	if _scroll_tween and _scroll_tween.is_valid():
		_scroll_tween.kill()
	_scroll_tween = create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	_scroll_tween.tween_property(
		scroll_cont, "scroll_horizontal", target, SCROLL_DURATION
	)


func _on_arrow_left() -> void:
	var center = scroll_cont.scroll_horizontal + int(scroll_cont.size.x / 2.0)
	var best_idx = 0
	for i in range(_items.size()):
		if _item_center_x(i) < center - 10:
			best_idx = i
	_smooth_scroll_to(best_idx)


func _on_arrow_right() -> void:
	var center = scroll_cont.scroll_horizontal + int(scroll_cont.size.x / 2.0)
	var best_idx = _items.size() - 1
	for i in range(_items.size() - 1, -1, -1):
		if _item_center_x(i) > center + 10:
			best_idx = i
	_smooth_scroll_to(best_idx)
 

func _on_settings() -> void:
	if not has_node("Settings"):
		pass
		#var settings = load(SETTINGS_PATH).instantiate()
		#add_child(settings)
