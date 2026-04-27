extends Node2D


@export var levels: Array[LevelData] = []
@onready var background = $"../Background"
@export var ball_scene: PackedScene
@export var wind_particle_scene: PackedScene


var ball: Node2D
var last_level_data
@onready var WindWarning =$"../WindCanvas"


func _ready():
	add_to_group("LevelLoader")
	build_level()
	UiManager._setup_ui()
	GameManager.state=GameManager.GameState.PLAYING
	GameManager.level_restarted.connect(_on_level_restarted)


func spawn(data: SpawnData):
	if data == null or data.scene == null:
		return

	var obj = data.scene.instantiate()
	obj.position = data.position
	obj.scale = data.scale
	obj.z_index = data.zIndex
	obj.rotation=data.Rotaion
	
	call_deferred("add_child", obj)





func build_level():
	if levels.is_empty():
		return
	UiManager.set_level(GameManager.current_level+1)
	var level_data: LevelData = levels[GameManager.current_level]
	
	
	# Clear old level
	for child in get_children():
		
		if is_instance_valid(ball):
			ball.queue_free()
			
		if  child != background:
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

	if level_data.wind_strength > 0:
		if wind_particle_scene != null:
			var wind_particles = wind_particle_scene.instantiate()
			add_child(wind_particles)
			wind_particles.rotation = level_data.wind_direction.angle()
			# Center it roughly on the screen/level if needed, 
			# but assuming the scene is set up to cover the area.
			wind_particles.position = Vector2(0, 266) # Center of 1920x1080

	spawn(level_data.goal)
	
	spawn(level_data.land)
	
	ball = ball_scene.instantiate()
	get_parent().call_deferred("add_child", ball)
	await get_tree().process_frame

	ball.name = "ball"
	ball.adjustball(level_data)
	ball.timeout =7+level_data.ExtraTimeout
	
	if level_data.wind_strength >0:
		if GameManager.showWindWarn==false:
			GameManager.showWindWarn=true
			ball.can_shoot=false
			WindWarning.show()
			await get_tree().create_timer(3).timeout
			ball.can_shoot=true
			WindWarning.hide()
		
	
	
func _on_level_restarted():
	build_level()


func next_level():
	if is_instance_valid(ball):
		ball.queue_free()
	
	GameManager.complete_level()
	if GameManager.current_level >= levels.size():
		GameManager.current_level = 0
	GameManager.showWindWarn=false
	build_level()


func restart_level():
	build_level()
