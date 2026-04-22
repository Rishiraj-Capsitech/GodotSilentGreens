extends Area2D

@export var explosion :Node2D
@export var sprite:Sprite2D
@export var collider :CollisionPolygon2D
var particles : CPUParticles2D
@export var speed := 100
@export var direction := 1
var start_pos := Vector2.ZERO
@export var distance := 200

func _ready() -> void:
	start_pos = global_position
	particles = explosion.get_node("CPUParticles2D")
	connect("body_entered", _on_body_entered)


func _physics_process(delta):
	global_position.x += speed * direction * delta

	if global_position.x > start_pos.x + distance:
		direction = -1
	elif global_position.x < start_pos.x - distance:
		direction = 1

func _on_body_entered(body):
	if body.name in ["ball"]:
		if collider and sprite:
			if body is CharacterBody2D:
				body.velocity *= 0.2

			elif body is RigidBody2D:
				body.linear_velocity *= 0.25
			collider.queue_free()
			sprite.queue_free()
			if particles:
				particles.emitting =true
			await get_tree().create_timer(1.5).timeout
			queue_free()	

	
		
