extends RigidBody2D

@export var dot_scene: PackedScene
@export var dot_count := 25
@export var spacing := 0.2
@export var power := 8.0
@export var max_drag := 200.0
@onready var dots_container = $dots
@onready var trail = $Line2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var colider: CollisionShape2D = $CollisionShape2D
@onready var DotNode: Node2D = $dots


var timeout = 7
var can_shoot = true
var goal = false
var dots = []
var dragging = false
var drag_start = Vector2.ZERO
var spawn_position
var min_drag := 10.0
var out_of_screen_time := 0.0
var max_out_time := 0.5
var wind_force := Vector2.ZERO


func _ready():
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	
	for i in range(dot_count):
		var dot = dot_scene.instantiate()
		dots_container.add_child(dot)
		dots.append(dot)
		dot.visible = false


func _input(event):
	if event is InputEventMouseButton:
		if not can_shoot: return
		
		if event.pressed:
			dragging = true
			drag_start = get_global_mouse_position()
		else:
			if dragging:
				var drag_distance = (drag_start - get_global_mouse_position()).length()
				
				if drag_distance > min_drag:
					shoot()
				
			dragging = false
			hide_dots()


func _process(delta):
	if dragging:
		update_dots()
	check_out_of_bounds(delta)


func _physics_process(delta):
	if not freeze:
		apply_central_force(wind_force)


func check_out_of_bounds(delta):
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return

	var screen_size = get_viewport_rect().size
	var cam_pos = camera.global_position
	var rect = Rect2(
		cam_pos - screen_size * 0.5,
		screen_size
	)
	if rect.has_point(global_position):
		out_of_screen_time = 0.0
	else:
		out_of_screen_time += delta
		if out_of_screen_time >= max_out_time:
			losseLife()
			out_of_screen_time = 0.0


func update_dots():
	var mouse_pos = get_global_mouse_position()
	var drag_vector = drag_start - mouse_pos
	
	if drag_vector.length() > max_drag:
		drag_vector = drag_vector.normalized() * max_drag
	
	var simulated_velocity = drag_vector * power
	var simulated_pos = global_position

	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var gravity_vec = Vector2(0, gravity - 110)

	var base_step = 1 / 60.0
	var step = base_step * (1.0 + spacing * 10)

	var space_state = get_world_2d().direct_space_state

	for i in range(dot_count):
		var prev_pos = simulated_pos

		# physics step
		simulated_velocity += (gravity_vec + wind_force) * step
		simulated_velocity *= 0.99
		simulated_pos += simulated_velocity * step

		var query = PhysicsRayQueryParameters2D.create(prev_pos, simulated_pos)
		var result = space_state.intersect_ray(query)

		if result:
			dots[i].global_position = result.position
			dots[i].visible = true

			for j in range(i + 1, dot_count):
				dots[j].visible = false
			
			break
		else:
			dots[i].global_position = simulated_pos
			dots[i].visible = true


#  SHOOT BALL
func shoot():
	if not can_shoot: return
	can_shoot = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	freeze = false
	
	var mouse_pos = get_global_mouse_position()
	var drag_vector = drag_start - mouse_pos

	if drag_vector.length() > max_drag:
		drag_vector = drag_vector.normalized() * max_drag
	apply_impulse(drag_vector * power)
	await get_tree().create_timer(1).timeout
	detect_low_velovity()
	for i in range(timeout - 1):
		if can_shoot:
			return
		await get_tree().create_timer(1).timeout

	losseLife()
	
	
func adjustball(level_data):
	position = level_data.ball_spawn_position
	spawn_position = level_data.ball_spawn_position
	wind_force = level_data.wind_direction.normalized() * level_data.wind_strength
	
	
func detect_low_velovity():
	while true:
		if linear_velocity.length() < 30:
			losseLife()
			break
		await get_tree().create_timer(0.5).timeout


func hide_dots():
	for dot in dots:
		dot.visible = false


func losseLife():
	if not goal:
		can_shoot = true
		freeze = true
		freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		position = spawn_position
		trail.clear_points()
