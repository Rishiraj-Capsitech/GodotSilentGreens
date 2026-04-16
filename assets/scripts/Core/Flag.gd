extends Area2D


func _ready():
	connect("body_entered", _on_body_entered)
	


func _on_body_entered(body):
	print(body.name)
	print(body)
	if body.name in ["ball" , "@RigidBody2D@33"]:
		print("hit")
		body.goal = true

		var builder = get_tree().get_first_node_in_group("LevelLoader")
		if builder:
			print(builder)
			builder.next_level()
