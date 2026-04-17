@tool
class_name GameSceneDataExtractor
extends EditorScript

var window : Window
var line_edit : LineEdit

func _run() -> void:
	window = Window.new()
	window.title = "Level Data Extractor"
	window.min_size = Vector2(400, 200)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_WIDTH, 20)
	window.add_child(vbox)
	
	var label = Label.new()
	label.text = "Enter Level Name (e.g. Level17):"
	vbox.add_child(label)
	
	line_edit = LineEdit.new()
	line_edit.placeholder_text = "LevelName"
	vbox.add_child(line_edit)
	
	var button = Button.new()
	button.text = "Extract and Save .tres"
	button.pressed.connect(_on_extract_pressed)
	vbox.add_child(button)
	
	EditorInterface.popup_dialog_centered(window)
	
	window.close_requested.connect(func():
		window.queue_free()
	)

func _on_extract_pressed() -> void:
	var level_name = line_edit.text.strip_edges()
	if level_name == "":
		printerr("Please enter a level name.")
		return
	
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		printerr("No scene root found.")
		return
		
	var level_data = LevelData.new()
	
	for child in root.get_children():
		# Handle Background
		if child.name == "Background" and child is Sprite2D:
			level_data.background = child.texture
			level_data.bgscale = child.scale
			level_data.bgpos = child.global_position
			continue
			
		var scene_path = child.scene_file_path
		if scene_path == "":
			continue
			
		var spawn_data = SpawnData.new()
		spawn_data.scene = load(scene_path)
		spawn_data.position = child.global_position
		spawn_data.scale = child.scale
		spawn_data.zIndex = child.z_index
		
		if "ball.tscn" in scene_path:
			level_data.ball_spawn_position = child.global_position
			level_data.ball_scale = child.scale
		elif "flag.tscn" in scene_path:
			level_data.goal = spawn_data
		elif "LevelLands" in scene_path:
			level_data.land = spawn_data
		elif "SmallObstacles" in scene_path:
			level_data.small_obstacles.append(spawn_data)
		elif "BigObstacles" in scene_path:
			level_data.big_obstacles.append(spawn_data)
		elif "Other" in scene_path:
			if "Cloud" in child.name or "cloud" in scene_path:
				level_data.clouds.append(spawn_data)
			else:
				level_data.decorations.append(spawn_data)
				
	var save_path = "res://assets/LevelData/" + level_name + ".tres"
	var err = ResourceSaver.save(level_data, save_path)
	if err == OK:
		print("Successfully saved level data to: ", save_path)
		EditorInterface.get_resource_filesystem().scan()
	else:
		printerr("Failed to save level data. Error code: ", err)
	
	window.queue_free()
