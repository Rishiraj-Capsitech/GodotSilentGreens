extends Camera2D

@export var target_width := 1920.0
@export var target_height := 1080.0
@export var min_height := 900.0  # minimum safe visible height
@onready var hud =$"../HudCanvas/GameHUD"

func _ready():
	update_camera()
	get_viewport().size_changed.connect(update_camera)

func update_camera():
	var screen_size = get_viewport_rect().size


	var zoom_value = screen_size.x / target_width
	
	var visible_height = screen_size.y / zoom_value


	if visible_height < min_height:
		zoom_value = screen_size.y / min_height
		visible_height = min_height

	zoom = Vector2(zoom_value, zoom_value)
	#for child in hud.get_children():
		#child.scale =Vector2(zoom_value, zoom_value)


	var extra_height = visible_height - target_height
	
	if extra_height > 0:
		offset.y = -extra_height / 2
	else:
		offset.y = 0
