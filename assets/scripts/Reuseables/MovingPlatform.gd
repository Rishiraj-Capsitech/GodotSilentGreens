extends AnimatableBody2D

@export var speed := 100.0
@export var distance := 200.0

var start_pos: Vector2
@export var direction := 1

func _ready():
	start_pos = global_position

func _physics_process(delta):
	var move_amount = speed * direction * delta
	global_position.x += move_amount

	# reverse direction at limits
	if global_position.x > start_pos.x + distance:
		direction = -1
	elif global_position.x < start_pos.x - distance:
		direction = 1
