extends Area2D

@export var coin_scene: PackedScene
@onready var target_point = $TargetPoint


var target_ball = null
var prev_pos = Vector2.ZERO
var self_velocity = Vector2.ZERO

func _ready():
	connect("body_entered", _on_body_entered)


func _on_body_entered(body):
	if body.name == "ball":
		body.goal = true
		body.set_deferred("collision_layer", 2)
		body.set_deferred("collision_mask", 2)
		body.gravity_scale=0


		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0
		
		body.z_index = -5
		target_ball = body
		_spawn_coin()
		SoundManager.play_sfx(SoundType.GAME_WIN)
		call_deferred("_finish_level")


func _process(delta):
	if target_ball:
		target_ball.trail.visible = false
		self_velocity = (global_position - prev_pos) / delta
		prev_pos = global_position
		
		var target_pos = target_point.global_position
		var dist = target_ball.global_position.distance_to(target_pos)
		var speed = dist * 2.0
		if self_velocity.length() > 10:
			
			
			speed = 200

		target_ball.global_position = target_ball.global_position.move_toward(
			target_pos,
			speed * delta
		)

		# stop when close
		if target_ball.global_position.distance_to(target_pos) < 2:
			target_ball.global_position = target_pos
			target_ball = null

func _spawn_coin():
	if coin_scene == null:
		return

	var coin = coin_scene.instantiate()
	get_tree().current_scene.add_child(coin)

	# Position
	coin.global_position = global_position


	coin.scale = self.global_scale - Vector2(0.2, 0.2)

	var tween = create_tween()

	tween.tween_property(
		coin,
		"global_position",
		coin.global_position + Vector2(0, -80 * self.scale.y), # also scale movement
		0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(coin, "modulate:a", 0.0, 0.4)

	tween.tween_callback(func(): coin.queue_free())

func _finish_level():
	await get_tree().create_timer(2).timeout
	_next_level()


func _next_level():
	var builder = get_tree().get_first_node_in_group("LevelLoader")
	if builder:
		builder.call_deferred("next_level")
