extends Node

var default_res = Vector2(1440, 900)
var resolution: Vector2


func set_resolution(res: Vector2):
	print("Resolution set to ", str(res.x), " by ", str(res.y), ".")
	DisplayServer.window_set_size(res)
	var size = DisplayServer.screen_get_size()
	var new_x = (size.x - res.x) / 2
	var new_y = (size.y - res.y) / 2
	DisplayServer.window_set_position(Vector2(new_x, new_y))
	resolution = res




func _get_save_data() -> Dictionary:
	var data_to_save = {}
	data_to_save["resolution"] = resolution
	return data_to_save


func _apply_load_data(loaded_data: Dictionary):
	if loaded_data.has("resolution"):
		var str_res = loaded_data["resolution"]
		var res_x: String = ""
		var res_y: String = ""
		var is_x = true
		var res: Vector2
		
		for character in str_res:
			if character == "(" or character == ")" or character == " ":
				continue
			if character == ",":
				is_x = false
				continue
			if not character.is_valid_int():
				print("invalid save format for resolution")
				return
			if is_x:
				res_x += character
			else:
				res_y += character
		
		res.x = int(res_x)
		res.y = int(res_y)
		
		if res == Vector2(0, 0):
			res = default_res
			
		set_resolution(res)
