extends Area2D

@export var bounce_multiplier := 1.5   # >1 = higher bounce


func _ready():
	connect("body_entered", _on_body_entered)
	

func _on_body_entered(body):
	if body is RigidBody2D:
		var v = body.linear_velocity
		
		# Reflect upward + boost
		v.y = -abs(v.y) * bounce_multiplier
		
		body.linear_velocity = v
