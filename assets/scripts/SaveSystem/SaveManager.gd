extends Node

# SaveManager.gd
# A modular save system using JSON for Godot 4.
# Handles multiple save slots and provides easy-to-use save/load functions.

const SAVE_DIR = "user://saves/"
const SAVE_FILE_EXTENSION = ".json"

func _ready():
	# Ensure the save directory exists when the manager starts
	verify_save_directory()


## Verifies if the save directory exists, creates it if not.
func verify_save_directory():
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


## Returns the full path for a given slot index.
func get_save_path(slot: int) -> String:
	return SAVE_DIR + "slot_" + str(slot) + SAVE_FILE_EXTENSION


## Saves the provided data dictionary into a specific slot.
func save_game(slot: int, data: Dictionary) -> bool:
	verify_save_directory()
	var path = get_save_path(slot)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: Could not open file for writing at %s. Error: %s" % [path, FileAccess.get_open_error()])
		return false
	
	var json_string = JSON.stringify(data, "\t") # Pretty-print with tabs
	file.store_string(json_string)
	file.close()
	
	print("SaveSystem: Game saved to slot %d" % slot)
	return true


## Loads and returns data from a specific slot. Returns an empty dictionary if loading fails or file doesn't exist.
func load_game(slot: int) -> Dictionary:
	var path = get_save_path(slot)
	
	if not FileAccess.file_exists(path):
		print("SaveSystem: No save file found at %s" % path)
		return {}
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveSystem: Could not open file for reading at %s. Error: %s" % [path, FileAccess.get_open_error()])
		return {}
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("SaveSystem: JSON parse error in %s: %s at line %d" % [path, json.get_error_message(), json.get_error_line()])
		return {}
		
	return json.data


## Deletes the save file for a specific slot.
func delete_save(slot: int) -> bool:
	var path = get_save_path(slot)
	if FileAccess.file_exists(path):
		var error = DirAccess.remove_absolute(path)
		if error == OK:
			print("SaveSystem: Deleted save slot %d" % slot)
			return true
		else:
			push_error("SaveSystem: Failed to delete save slot %d. Error: %d" % [slot, error])
			return false
	return false


## Checks if a save exists in the specified slot.
func has_save(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))


## Returns a list of all available save slot indices.
func get_available_slots() -> Array:
	var slots = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(SAVE_FILE_EXTENSION):
				# Extract slot number from "slot_X.json"
				var slot_str = file_name.replace("slot_", "").replace(SAVE_FILE_EXTENSION, "")
				if slot_str.is_valid_int():
					slots.append(slot_str.to_int())
			file_name = dir.get_next()
	slots.sort()
	return slots


## Deletes the entire saves directory and all save files inside.
## Equivalent to "Clear PlayerPrefs" in Unity.
func clear_all_data() -> void:
	if DirAccess.dir_exists_absolute(SAVE_DIR):
		var dir = DirAccess.open(SAVE_DIR)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					dir.remove(file_name)
				file_name = dir.get_next()
			
			# Finally remove the directory itself
			DirAccess.remove_absolute(SAVE_DIR)
			print("SaveSystem: All save data cleared.")
		else:
			push_error("SaveSystem: Could not open directory to clear data.")
	else:
		print("SaveSystem: No save data to clear.")
