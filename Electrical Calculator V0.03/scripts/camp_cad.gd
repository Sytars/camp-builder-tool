extends Control


@onready var object_data = {
	"tent": {}
}
@onready var canvas = $Panel/VBoxContainer/Canvas 
@onready var origin = $Panel/VBoxContainer/Canvas/Origin
@onready var objects_instantiator = $object_instantiator
@onready var selector = $Panel/VBoxContainer/Canvas/Selector
@onready var Tabs = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel"
@onready var new_object_tab = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/New Object Tab"
@onready var edit_tab = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/Edit Tab"
@onready var objects = $Objects
@onready var utils = $Panel/VBoxContainer/Canvas/utils


# Panning variables
var is_panning := false
var last_mouse_pos := Vector2()

# New Object variables
var placing_object := false
var current_object: Dictionary
@onready var snap_size := 64
var last_type: String
var last_obj: String


# Selection variables
var dragging := false
var init_pos
var last_selection
var obj_in_selection := []
@onready var selection := []

var axis



func _input(event):
	if not visible:
		return

	if Input.is_action_just_pressed("toggle_action_X"):
		axis = utils.toggle_axis()
		
	
	if placing_object:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			confirm_placement()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_placement()
		return

	pan(event)
	# Selection input #TRANSFERED
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if dragging and not event.pressed:
				init_pos = null
				selector.position = -selector.position
				selector.size = Vector2(0, 0)
				get_objects_in_selection()
				if obj_in_selection:
					print("Objects: ", obj_in_selection)
			dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		if not init_pos:
			init_pos = canvas.get_local_mouse_position()
		update_selector()


func _process(_delta):
	if not visible:
		return
	
	
	
	if placing_object and is_within_bounds(): #current_object["obj"].position
		var pos = canvas.get_local_mouse_position() - origin.position
		pos.x = round(pos.x / snap_size) * snap_size
		pos.y = round(pos.y / snap_size) * snap_size
		current_object["obj"].position = pos
	
	if axis:
		var pos = canvas.get_local_mouse_position() - origin.position
		pos.x = round(pos.x / snap_size) * snap_size
		pos.y = round(pos.y / snap_size) * snap_size
		utils.update_axis(pos)


func is_within_bounds() -> bool:
	var local_pos = canvas.get_local_mouse_position()
	return Rect2(Vector2.ZERO, canvas.size).has_point(local_pos)

 
func get_objects_in_selection():
	obj_in_selection = []
	if not last_selection:
		return
	if object_data:
		for object_type in object_data:
			for obj in object_data[object_type]:
				var object_pos = object_data[object_type][obj]["position"]
				var object_size = object_data[object_type][obj]["size"]
				var object_name = object_data[object_type][obj]["name"]
				if Rect2(last_selection["position"], last_selection["size"]).encloses(Rect2(object_pos, object_size)):
					if selector.color == Color(0, 0, 1, 0.1):
						obj_in_selection.append(obj)
				if Rect2(object_pos, object_size).intersects(Rect2(last_selection["position"], last_selection["size"])):
					if selector.color == Color(0, 1, 0, 0.1):
						obj_in_selection.append(obj)



func update_selector():
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

	last_selection = {
		"position": selector.position - origin.position, # Substracting origin pos because of panning. not panned origin pos = (0, 0)
		"size": selector.size
	}


func pan(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				if is_within_bounds():
					is_panning = true
					last_mouse_pos = event.position
			else:
				is_panning = false
	elif event is InputEventMouseMotion:
		if is_panning:
			var mouse_delta = event.position - last_mouse_pos
			origin.position += mouse_delta
			last_mouse_pos = event.position
			#print(control.position)


func new_object(type, obj):
	var new = objects_instantiator.new_object(type, obj)
	new["name"] += str(len(object_data[type]))
	new["obj"].position = new["position"]
	new["obj"].size = new["size"]
	origin.add_child(new["obj"])
	placing_object = true
	current_object = new


func cancel_placement():
	current_object["obj"].queue_free()
	placing_object = false


func confirm_placement():
	if not placing_object:
		return
	placing_object = false
	object_data[current_object["type"]][current_object["name"]] = current_object
	object_data[current_object["type"]][current_object["name"]]["position"] = current_object["obj"].position
	current_object = {}
	#print(object_data)
	new_object(last_type, last_obj)


func _on_mod_tent_button_pressed():
	last_type = "tent"
	last_obj = "mod"
	new_object(last_type, last_obj)


func _on_hqss_button_pressed():
	last_type = "tent"
	last_obj = "hqss"
	new_object(last_type, last_obj)


func _on_delete_objects_button_pressed():
	for obj in selection:
		obj["obj"].queue_free()
	
		print("before: ", object_data)
		for cat in object_data:
			if object_data[cat].has(obj):
				object_data[cat].erase(obj)
		print("after: ", object_data)
	selection = []
