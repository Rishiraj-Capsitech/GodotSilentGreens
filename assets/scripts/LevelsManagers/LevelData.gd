extends Resource
class_name LevelData


# Core
@export var land: SpawnData
@export var ball_spawn_position: Vector2
@export var ball_scale:Vector2 =Vector2(1,1)
@export var goal: SpawnData

# Background
@export var background: Texture2D 
@export var bgscale:Vector2 =Vector2.ONE
@export var bgpos:Vector2  

# Gameplay
@export var small_obstacles: Array[SpawnData] = []
@export var big_obstacles: Array[SpawnData] = []

# Visual
@export var clouds: Array[SpawnData] = []
@export var decorations: Array[SpawnData] = []
