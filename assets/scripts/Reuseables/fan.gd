extends AnimatableBody2D

@export var rotation_speed: float = 90.0  # degrees per second
@export var reverse: bool = false


func _physics_process(delta):
	var dir = -1 if reverse else 1
	rotation_degrees += rotation_speed * dir * delta
