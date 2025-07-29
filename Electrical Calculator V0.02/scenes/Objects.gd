extends Control
class_name Objects

@onready var num_section_slider = $"../Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/New Object Tab/New Tent Container/Num Section Slider"
@onready var origin = $"../Panel/VBoxContainer/Canvas/Origin"

var object_template = {
	"tent": {
		"hqss": Vector2(60, 24),
		"mod": Vector2(68, 20)
	},
	"some_other_futur_object": {
		
	}
}


func new_object(obj_type: String, obj: String):
	var new_obj = Button.new()
	var obj_data = {}
	var new_obj_pos = Vector2(0, 0)
	var new_obj_size
	var num_sections = num_section_slider.value
	
	if object_template.has(obj_type):
		if object_template[obj_type].has(obj):
			#print("Creating new %s." % obj)
			new_obj_size = object_template[obj_type][obj]
			new_obj_size.y *= num_sections
		else:
			print("No %s in object types template" % obj)
			return null
	else:
		print("no object of type %s in template" % obj_type)
		return null
		
	obj_data["obj"] = new_obj
	obj_data["type"] = obj_type
	obj_data["name"] = obj + "_"
	obj_data["position"] = new_obj_pos
	obj_data["size"] = new_obj_size
	
	return obj_data


func move_object():
	pass
