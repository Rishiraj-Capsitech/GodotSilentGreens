extends Node2D

@export var dot_scene: PackedScene
@export var max_dots := 25
@export var spacing := 0.08
@export var gravity := 980.0

var dots := []

func _ready():

	print("Trajetory Ready")

	for i in range(max_dots):

		var dot = dot_scene.instantiate()
		dot.visible = false

		add_child(dot)

		dots.append(dot)


func show_trajectory(start_pos: Vector2, velocity: Vector2):

	for i in range(dots.size()):

		var t = i * spacing

		var pos = start_pos + velocity * t
		pos.y += 0.5 * gravity * t * t

		dots[i].global_position = pos
		dots[i].visible = true

		# Gradual fade (brightness decreasing)
		var alpha = 1.0 - (float(i) / dots.size())

		# Prevent fully invisible dots
		if alpha < 0.2:
			alpha = 0.2

		dots[i].modulate.a = alpha
		var base_scale = 0.025
		var scale_factor = base_scale * (1.0 - (float(i) / dots.size()) * 0.7)
		dots[i].scale = Vector2(scale_factor, scale_factor)





func hide_trajectory():

	for dot in dots:
		dot.visible = false
