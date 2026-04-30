extends Control
class_name PanelTransition

@export var duration: float = 0.4
@export var drop_offset: float = 300.0
@export var bounce_scale: float = 1.05

var _target_pos: Vector2
var _current_tween: Tween

func _ready() -> void:
	 
	process_mode = Node.PROCESS_MODE_ALWAYS
 
	_target_pos = position
 
	visible = false
 
func show_panel() -> void:
	visible = true
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()
		
	_current_tween = create_tween()
 
	modulate.a = 0.0
	pivot_offset = size / 2.0
	scale = Vector2.ONE
	 
	position = _target_pos + Vector2(0, -drop_offset)
 
	_current_tween.parallel().tween_property(self, "modulate:a", 1.0, duration)
 
	_current_tween.parallel().tween_property(self, "position", _target_pos, duration)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)
 
	_current_tween.chain().tween_property(self, "scale", Vector2.ONE * bounce_scale, 0.0)
	_current_tween.chain().tween_interval(0.05)
	_current_tween.chain().tween_property(self, "scale", Vector2.ONE, 0.0)
 
func hide_panel() -> void:
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()
		
	_current_tween = create_tween()
	
	var out_duration = duration * 0.6
 
	_current_tween.parallel().tween_property(self, "modulate:a", 0.0, out_duration)
	_current_tween.parallel().tween_property(self, "position", _target_pos + Vector2(0, -drop_offset), out_duration)
	_current_tween.finished.connect(func():
		visible = false
	)
