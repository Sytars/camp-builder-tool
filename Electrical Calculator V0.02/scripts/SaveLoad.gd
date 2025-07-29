# SaveLoad.gd
extends Node


const SAVE_FILE_PATH = "user://game_save.json"

# ------------- To add a new scene to handle  -------------
# 1: Create a reference to the scene root node
# 2: Add the reference to scenes list


func save_data():
	var save_data = {}

	var root = get_tree().current_scene
	var ohm_law_calc_node = root.get_node_or_null("MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/OhmLawCalc")
	var pythagorus_node = root.get_node_or_null("MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Pythagore")
	var test_1_node = root.get_node_or_null("MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Test_1")
	var camp_layout = root.get_node_or_null("MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/camp_layout")
	var settings = root.get_node_or_null("MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Settings")

	var scenes = [ohm_law_calc_node, pythagorus_node, test_1_node, camp_layout, settings]
	
	if Global.has_method("_get_save_data"):
		save_data["/root/Global"] = Global._get_save_data()
	
	for scene in scenes:
		if scene:
			if scene.has_method("_get_save_data"):
				var node_path_str = str(scene.get_path()) # Use its full path as the key
				save_data[node_path_str] = scene._get_save_data()
			else:
				print("Warning: Node '%s' at '%s' does not have a '_get_save_data' method." % [scene.name, scene.get_path()])
		else:
			print("Warning: '%s' not found in the scene tree for saving." % [scene.name])
	var json_string = JSON.stringify(save_data, "\t") # "\t" for pretty printing


	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		print("Error: Could not open file for saving: %s" % SAVE_FILE_PATH)


func load_data():

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var parse_result = JSON.parse_string(json_string)
		if parse_result:
			var loaded_data = parse_result
			
			if loaded_data.has("/root/Global") and Global.has_method("_apply_load_data"):
				Global._apply_load_data(loaded_data["/root/Global"])
			
			var root = get_tree().current_scene
			
			for node_path_str in loaded_data:
				var node = root.get_node_or_null(NodePath(node_path_str))
				
				if node:
					if node.has_method("_apply_load_data"):
						node._apply_load_data(loaded_data[node_path_str])
					else:
						print("Warning: Node '%s' does not have an '_apply_load_data' method." % node_path_str)
				else:
					print("Warning: Node at path '%s' not found in current scene tree for loading." % node_path_str)
	else:
		print("Error: Could not open file for loading: %s" % SAVE_FILE_PATH)
		print("No save file found or accessible.")
