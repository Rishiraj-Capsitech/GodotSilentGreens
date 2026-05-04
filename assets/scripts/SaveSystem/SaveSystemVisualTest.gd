extends Control

# SaveSystemVisualTest.gd
# This script creates a simple UI to test saving and loading visually.
# 
# TO USE:
# 1. Create a new scene with a 'Control' or 'CanvasLayer' node.
# 2. Attach this script to it.
# 3. Run the scene (F6).

var label: Label
var button: Button
var game_data: Dictionary
const TEST_SLOT = 0

func _ready():
	setup_ui()
	load_game_data()

func setup_ui():
	# Create a background color
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Create a VBoxContainer to center items
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# Create the Label
	label = Label.new()
	label.text = "Value: 0"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	# Create the Button
	button = Button.new()
	button.text = "Increase Value & Save"
	button.custom_minimum_size = Vector2(200, 50)
	button.pressed.connect(_on_button_pressed)
	vbox.add_child(button)
	
	# Add a helper label
	var help = Label.new()
	help.text = "\n(Restart the game to see if the value persists)"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(help)

func load_game_data():
	# Load from slot 0
	game_data = SaveManager.load_game(TEST_SLOT)
	
	# If no save exists, use default
	if game_data.is_empty():
		print("VisualTest: No save found, using defaults.")
		game_data = SaveDataTemplate.create_default_data()
	else:
		print("VisualTest: Save loaded successfully.")
	
	update_ui()

func update_ui():
	label.text = "Value: " + str(game_data.progression.test_value)

func _on_button_pressed():
	# 1. Increase the value
	game_data.progression.test_value += 1
	
	# 2. Update the UI
	update_ui()
	
	# 3. Save the data
	var success = SaveManager.save_game(TEST_SLOT, game_data)
	if success:
		print("VisualTest: Saved new value: ", game_data.progression.test_value)
	else:
		printerr("VisualTest: Save failed!")
