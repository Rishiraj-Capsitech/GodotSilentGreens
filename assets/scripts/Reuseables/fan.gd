extends AnimatableBody2D

@export var rotation_speed: float = 90.0  # degrees per second

func _physics_process(delta):
	rotation_degrees += rotation_speed * delta
