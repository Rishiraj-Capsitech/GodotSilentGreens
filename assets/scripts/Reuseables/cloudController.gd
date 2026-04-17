extends Area2D

@export var explosion :Node2D
@export var sprite:Sprite2D
@export var collider :CollisionPolygon2D
var particles : CPUParticles2D


func _ready() -> void:
	particles = explosion.get_node("CPUParticles2D")
	connect("body_entered", _on_body_entered)


func _on_body_entered(body):
	if body.name in ["ball"]:
		if collider and sprite:
			collider.queue_free()
			sprite.queue_free()
			if particles:
				particles.emitting =true
			await get_tree().create_timer(1.5).timeout

	
		
