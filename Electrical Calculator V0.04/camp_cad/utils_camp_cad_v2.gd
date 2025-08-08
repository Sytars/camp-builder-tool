extends Control
class_name Utils

# Selection variables
var init_pos

@onready var camp_cad_v_2 = $"../.."
@onready var canvas = $"../../Panel/VBoxContainer/Canvas"
@onready var selector = $"../../Panel/VBoxContainer/Canvas/Selector"
@onready var origin: Control = $"../../Panel/VBoxContainer/Canvas/Origin"
@onready var obj: Obj = $"../Obj"



func _get_save_data() -> Dictionary:
	var data_to_save = {}
	data_to_save["object_data"] = obj.all_objects_data.duplicate(true)
	return data_to_save


func _apply_load_data(loaded_data: Dictionary):
	if loaded_data.has("object_data"):
		var data_to_load = loaded_data["object_data"].duplicate(true)



func is_within_bounds():
	var local_pos = canvas.get_local_mouse_position()
	return Rect2(Vector2.ZERO, canvas.size).has_point(local_pos)


func get_objects_in_selection(selection, object_data) -> Array:
	var obj_in_selection := []
	
	if not selection or not object_data:
		return obj_in_selection

	# compares all objects' Transforms in all_objects_data to selection's Transform
	for category in object_data:
		for obj_type in object_data[category]:
			for item in object_data[category][obj_type]:
				var object_pos = object_data[category][obj_type][item].position
				var object_size = object_data[category][obj_type][item].size
				
				# origin position is added to add panning offset
				if Rect2(selection["position"], selection["size"]).encloses(Rect2(object_pos + origin.position, object_size)):
					if selector.color == Color(0, 0, 1, 0.1):
						obj_in_selection.append(object_data[category][obj_type][item])
						
				if Rect2(object_pos + origin.position, object_size).intersects(Rect2(selection["position"], selection["size"])):
					if selector.color == Color(0, 1, 0, 0.1):
						obj_in_selection.append(object_data[category][obj_type][item])
	
	return obj_in_selection


func update_selector(selector):
	if not init_pos:
		init_pos = canvas.get_local_mouse_position()
		
	var mouse_pos = canvas.get_local_mouse_position()
	
	# Horizontal
	if init_pos.x > mouse_pos.x:
		selector.color = Color(0, 1, 0, 0.1)
		selector.position.x = mouse_pos.x
		selector.size.x = init_pos.x - mouse_pos.x
	else:
		selector.color = Color(0, 0, 1, 0.1)
		selector.position.x = init_pos.x
		selector.size.x = mouse_pos.x - init_pos.x
	# Vertical
	if init_pos.y > mouse_pos.y:
		selector.position.y = mouse_pos.y
		selector.size.y = init_pos.y - mouse_pos.y
	else:
		selector.position.y = init_pos.y
		selector.size.y = mouse_pos.y - init_pos.y

	return {
		"position": selector.position,# - origin.position, # Substracting origin pos because of panning. not panned origin pos = (0, 0)
		"size": selector.size
	}
