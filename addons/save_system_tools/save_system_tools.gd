@tool
extends EditorPlugin

# save_system_tools.gd
# Adds a "Clear Save Data" option to the Godot Editor's Project -> Tools menu.

const SAVE_DIR = "user://saves/"

func _enter_tree():
	# Add a menu item to Project -> Tools
	add_tool_menu_item("Clear All Save Data", _on_clear_save_data_pressed)

func _exit_tree():
	# Clean up the menu item when the plugin is disabled
	remove_tool_menu_item("Clear All Save Data")

func _on_clear_save_data_pressed():
	# Show a confirmation dialog
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Are you sure you want to delete ALL save data? This cannot be undone."
	dialog.title = "Confirm Data Clear"
	dialog.get_ok_button().text = "Yes, Clear Everything"
	
	# Connect the confirmed signal
	dialog.confirmed.connect(_clear_data)
	
	# Add to editor interface and show
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered()

func _clear_data():
	if DirAccess.dir_exists_absolute(SAVE_DIR):
		var dir = DirAccess.open(SAVE_DIR)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					dir.remove(file_name)
				file_name = dir.get_next()
			
			DirAccess.remove_absolute(SAVE_DIR)
			print("SaveSystem: All save data cleared successfully via Editor Tool.")
			EditorInterface.get_resource_filesystem().scan()
		else:
			printerr("SaveSystem Tool: Could not open directory.")
	else:
		print("SaveSystem Tool: No save data found to clear.")
