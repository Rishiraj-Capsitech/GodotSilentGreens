extends RigidBody2D

@export var dot_scene: PackedScene
@export var dot_count := 25
@export var spacing := 0.2
@onready var dots_container = $dots
@onready var trail:Line2D = $Line2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var colider: CollisionShape2D = $CollisionShape2D
@onready var DotNode: Node2D = $dots


var timeout = 7
var can_shoot = true
var goal = false
var dots = []
var dragging = false
var base_drag = 200.0
var base_power = 8.0
var power
var max_drag
var drag_start = Vector2.ZERO
var spawn_position
var min_drag := 10.0
var out_of_screen_time := 0.0
var max_out_time := 0.5
var wind_force := Vector2.ZERO


func _ready():
	var sensitivity = clamp(GameManager.sensitivity / 100.0, 0.01, 1.0)
	max_drag = lerp(800.0, 200.0, sensitivity)
	power = (base_drag * base_power) / max_drag
	
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


func _physics_process(_delta):
	if not freeze and not goal:
		apply_central_force(wind_force)


func check_out_of_bounds(delta):
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if camera == null:
		return

	var canvas_transform = viewport.get_canvas_transform()
	var inv = canvas_transform.affine_inverse()

	# Convert screen corners → world
	var top_left = inv * Vector2.ZERO
	var bottom_right = inv * viewport.get_visible_rect().size

	var rect = Rect2(top_left, bottom_right - top_left)

	if rect.has_point(global_position):
		out_of_screen_time = 0.0
	else:
		out_of_screen_time += delta
		if out_of_screen_time >= max_out_time:
			print("out of screen")
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
		simulated_velocity += (gravity_vec) * step
		simulated_velocity *= 0.99
		simulated_pos += simulated_velocity * step

		var query = PhysicsRayQueryParameters2D.create(prev_pos, simulated_pos)
		var result = space_state.intersect_ray(query)

		# 👇 scale factor (adjust 0.5 to control how small the last dot is)
		var t = float(i) / dot_count
		var scale_factor = lerp(1.0, 0.5, t)

		if result:
			dots[i].global_position = result.position
			dots[i].visible = true
			dots[i].scale = Vector2(scale_factor, scale_factor)

			for j in range(i + 1, dot_count):
				dots[j].visible = false
			break
		else:
			dots[i].global_position = simulated_pos
			dots[i].visible = true
			dots[i].scale = Vector2(scale_factor, scale_factor)

#  SHOOT BALL
func shoot():
	if not can_shoot: return
	if GameManager.state != GameManager.GameState.PLAYING:return
	print(GameManager.state)
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
	print("time out")
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
	#get_tree().get_root().get_node("Game/AudioStreamPlayer").play()
	if not goal:
		UiManager._play_oops()
		can_shoot = true
		freeze = true
		freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		trail.clear_points()
		position = spawn_position
		GameManager.lose_life()
		get_tree().get_root().get_node("Game/LevelLoader").build_level()
		
