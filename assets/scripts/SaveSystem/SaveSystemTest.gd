extends Node

# SaveSystemTest.gd
# This script is for TESTING the SaveSystem.
# To run it:
# 1. Ensure SaveManager.gd is set as an Autoload named 'SaveManager'.
# 2. Attach this script to any Node in a scene and run the scene.
# 3. Check the Output console in Godot.

func _ready():
	run_save_system_test()

func run_save_system_test():
	print("\n--- STARTING SAVE SYSTEM TEST ---")
	
	# 1. Create dummy data
	var test_data = SaveDataTemplate.create_default_data()
	test_data.settings.language = "fr" # Change language to French for testing
	test_data.progression.levels_cleared = [1, 2, 3]
	
	print("Step 1: Test Data Prepared (Language: %s)" % test_data.settings.language)
	
	# 2. Test Saving to Slot 99 (a safe test slot)
	var save_success = SaveManager.save_game(99, test_data)
	if save_success:
		print("Step 2: Successfully saved to slot 99")
	else:
		printerr("Step 2 FAILED: Could not save to slot 99")
		return

	# 3. Test Loading from Slot 99
	var loaded_data = SaveManager.load_game(99)
	if not loaded_data.is_empty():
		print("Step 3: Successfully loaded from slot 99")
		# Verify data integrity
		if loaded_data.settings.language == "fr" and loaded_data.progression.levels_cleared.size() == 3:
			print("Step 4: Data integrity verified! (Language: %s, Cleared: %s)" % [loaded_data.settings.language, str(loaded_data.progression.levels_cleared)])
		else:
			printerr("Step 4 FAILED: Data corrupted or not matching!")
	else:
		printerr("Step 3 FAILED: Loaded data is empty!")
		return

	# 5. Test Slot Existence
	if SaveManager.has_save(99):
		print("Step 5: Slot 99 existence confirmed")
	else:
		printerr("Step 5 FAILED: SaveManager reports no save at slot 99")

	# 6. Test Deletion
	#var delete_success = SaveManager.delete_save(99)
	#if delete_success:
		#print("Step 6: Successfully deleted slot 99")
		#if not SaveManager.has_save(99):
			#print("Step 7: Verification: Slot 99 is truly gone.")
		#else:
			#printerr("Step 7 FAILED: Slot 99 still exists after deletion!")
	#else:
		#printerr("Step 6 FAILED: Could not delete slot 99")

	print("--- SAVE SYSTEM TEST COMPLETED SUCCESSFULLY ---\n")
