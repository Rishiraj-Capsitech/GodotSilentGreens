# SaveDataTemplate.gd
# This is an example of how you can structure your save data.
# You can use this to create a dictionary that the SaveManager can save.

class_name SaveDataTemplate

static func create_default_data() -> Dictionary:
	return {
		"progression": {
			"levels_unlocked": [1],
			"levels_cleared": [],
			"tutorial_played": false
		},
		"player_data": {
			"level_attempts_by_level": {},
			"game_lives": 3,
			"game_coins": 0
		},
		"settings": {
			"language": "en",
			"music_enabled": true,
			"sfx_enabled": true,
			"sensitivity": 0.0
		},
		"metadata": {
			"last_played": Time.get_datetime_dict_from_system(),
			"version": "1.0"
		}
	}

## Helper to convert a Vector3 to a dictionary (since JSON doesn't support Vector3 natively)
static func vector3_to_dict(vec: Vector3) -> Dictionary:
	return {"x": vec.x, "y": vec.y, "z": vec.z}

## Helper to convert a dictionary back to a Vector3
static func dict_to_vector3(dict: Dictionary) -> Vector3:
	return Vector3(dict.get("x", 0), dict.get("y", 0), dict.get("z", 0))
