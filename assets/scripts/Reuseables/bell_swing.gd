extends Node2D

@export_range(0.0, 45.0, 0.1) var max_angle_degrees := 12.0
@export_range(0.1, 10.0, 0.1) var swing_speed := 1.0
@export var phase_offset := 0.0
@export var start_from_current_rotation := true

var _base_rotation := 0.0
var _time := 0.0


func _ready() -> void:
	_base_rotation = rotation if start_from_current_rotation else 0.0
	_time = phase_offset


func _physics_process(delta: float) -> void:
	# Sine motion eases at the ends and reads like a hanging pendulum.
	_time += delta * swing_speed
	var sway_angle := deg_to_rad(max_angle_degrees) * sin(_time)
	rotation = _base_rotation + sway_angle
