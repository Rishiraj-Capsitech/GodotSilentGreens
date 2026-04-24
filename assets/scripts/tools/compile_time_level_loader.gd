@tool
class_name CompileTimeLevelLoader
extends EditorScript

var window : Window
var line_edit : LineEdit

func _run() -> void:
	window = Window.new()
	window.title = "Level Data Loader"
	window.min_size = Vector2(400, 250)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_WIDTH, 20)
	window.add_child(vbox)
	
	var label = Label.new()
	label.text = "Enter Level Name to Load (e.g. Level17):"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	line_edit = LineEdit.new()
	line_edit.placeholder_text = "LevelName"
	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(line_edit)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)
	
	var button = Button.new()
	button.text = "Load .tres into Scene"
	button.pressed.connect(_on_load_pressed)
	vbox.add_child(button)
	
	var clear_button = Button.new()
	clear_button.text = "Clear Current Scene"
	clear_button.pressed.connect(_on_clear_pressed)
	vbox.add_child(clear_button)
	
	var info_label = Label.new()
	info_label.text = "\nWARNING: This tool instantiates nodes into the \ncurrently edited scene root.\nMake sure you have a scene open."
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(info_label)
	
	EditorInterface.popup_dialog_centered(window)
	
	window.close_requested.connect(func():
		window.queue_free()
	)

func _on_clear_pressed() -> void:
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		printerr("No scene root found.")
		return
	
	# Create a list of children to free to avoid iterator issues
	var children = root.get_children()
	for child in children:
		child.free()
	print("Scene cleared.")

func _on_load_pressed() -> void:
	var level_name = line_edit.text.strip_edges()
	if level_name == "":
		printerr("Please enter a level name.")
		return
		
	var load_path = "res://assets/LevelData/" + level_name + ".tres"
	if not FileAccess.file_exists(load_path):
		printerr("Level file not found: ", load_path)
		return
		
	var level_data = load(load_path) as LevelData
	if not level_data:
		printerr("Failed to load LevelData from: ", load_path)
		return
		
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		printerr("No scene root found. Please open a scene first.")
		return

	# Load Background
	if level_data.background:
		var bg = Sprite2D.new()
		bg.name = "Background"
		bg.texture = level_data.background
		bg.scale = level_data.bgscale
		bg.global_position = level_data.bgpos
		root.add_child(bg)
		bg.owner = root
		
	# Helper to spawn nodes
	var spawn_node = func(data: SpawnData, custom_name: String = ""):
		if not data or not data.scene: return
		var instance = data.scene.instantiate()
		if custom_name != "":
			instance.name = custom_name
		instance.global_position = data.position
		instance.scale = data.scale
		instance.z_index = data.zIndex
		instance.rotation = data.Rotaion
		root.add_child(instance)
		instance.owner = root
		return instance

	# Spawn Land
	spawn_node.call(level_data.land)
	
	# Spawn Goal
	spawn_node.call(level_data.goal)
	
	# Spawn Ball
	var ball_scene = load("res://assets/scenes/Reuseable/Core/ball.tscn")
	if ball_scene:
		var ball = ball_scene.instantiate()
		ball.name = "Ball"
		ball.global_position = level_data.ball_spawn_position
		ball.scale = level_data.ball_scale
		root.add_child(ball)
		ball.owner = root
	
	# Spawn arrays
	for d in level_data.small_obstacles: spawn_node.call(d)
	for d in level_data.big_obstacles: spawn_node.call(d)
	for d in level_data.clouds: spawn_node.call(d)
	for d in level_data.decorations: spawn_node.call(d)

	print("Successfully loaded level: ", level_name)
	window.queue_free()
