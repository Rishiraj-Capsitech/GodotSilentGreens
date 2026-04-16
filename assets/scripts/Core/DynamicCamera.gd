extends Camera2D

@export var target_width := 1920.0
@export var target_height := 1080.0 # your base design height

func _ready():
	update_camera()
	get_viewport().size_changed.connect(update_camera)

func update_camera():
	var screen_size = get_viewport_rect().size

	var zoom_value = screen_size.x / target_width
	zoom = Vector2(zoom_value, zoom_value)

	var visible_height = screen_size.y / zoom_value
	
	var extra_height = visible_height - target_height

	offset.y = -extra_height / 2
