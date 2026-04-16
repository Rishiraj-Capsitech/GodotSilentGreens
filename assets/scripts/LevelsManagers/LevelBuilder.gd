extends Node2D


@export var levels: Array[LevelData] = []
@onready var background = $"../Background"
@export var ball_scene: PackedScene


var ball: Node2D
var current_level: int = 0
var last_level_data


func _ready():
	add_to_group("LevelLoader")
	build_level()


func spawn(data: SpawnData):
	if data == null or data.scene == null:
		return

	var obj = data.scene.instantiate()
	obj.position = data.position
	obj.scale = data.scale
	obj.z_index = data.zIndex
	
	call_deferred("add_child", obj)


func build_level():
	if levels.is_empty():
		return

	var level_data: LevelData = levels[current_level]

	# Clear old level
	for child in get_children():
		if child != ball and child != background:
			child.call_deferred("queue_free")


	if level_data.background != null:
		background.texture = level_data.background
		background.scale = level_data.bgscale
		background.position = level_data.bgpos
	
	if level_data.bgscale != Vector2.ONE:
		background.scale = level_data.bgscale
		
	if level_data.bgpos != Vector2(0, 0):
		background.position = level_data.bgpos
		 

	for data in level_data.small_obstacles:
		spawn(data)


	for i in range(min(3, level_data.big_obstacles.size())):
		spawn(level_data.big_obstacles[i])


	for data in level_data.clouds:
		spawn(data)

	for data in level_data.decorations:
		spawn(data)

	spawn(level_data.goal)
	
	spawn(level_data.land)
	
	ball = ball_scene.instantiate()
	get_parent().call_deferred("add_child", ball)
	await get_tree().process_frame

	ball.name = "ball"
	ball.adjustball(level_data)
	

func next_level():
	if is_instance_valid(ball):
		ball.queue_free()

	current_level += 1
	if current_level >= levels.size():
		current_level = 0

	build_level()


func restart_level():
	build_level()
