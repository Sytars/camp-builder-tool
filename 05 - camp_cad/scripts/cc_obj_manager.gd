# cc_obj_manager.gd
extends Control
class_name Obj

@onready var objects_container = $"../../Panel/VBoxContainer/Canvas/Origin/Objects Container" # New objects added to this node
@onready var objects_scene = preload("res://05 - camp_cad/scenes/objects.tscn") # A Control node with buttons and text, visually represents an object
@onready var utils = $"../Utils"
@onready var canvas = $"../../Panel/VBoxContainer/Canvas"
@onready var origin = $"../../Panel/VBoxContainer/Canvas/Origin"


# Connection variables
var is_connecting: bool = false
var start_point: Node2D = null
var connecting_line: Line2D = null
var all_connections: Dictionary = {}

# Object variables
var latest_created_object: Control
var placing_object: bool = false
@onready var num_sections: int = 4

# All objects stored here
var all_objects_data = {}


func _process(_delta):
	if placing_object:
		move_object(latest_created_object)
	
	# Update the end point of the line being drawn  - new - 
	if is_connecting and connecting_line:
		connecting_line.set_point_position(1, get_local_mouse_position() / origin.scale)


func _input(event):
	# Object placement inputs
	if placing_object:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			confirm_placement()
			return
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_placement()
			return
		return


# Initially called from button_connections_camp_cad_v2.gd
func new_object_pressed(category: String, obj_type: String) -> bool:
	# Delete current object if a new object is created
	if placing_object:
		latest_created_object.queue_free()
		placing_object = false
	
	var new_object = objects_scene.instantiate()
	
	# Verifying if size if available from template
	if not has_template(category, obj_type):
		return false
	
	# Giving the new object a size
	new_object.size = get_object_size(new_object, category, obj_type)
	
	# Dynamically creating the node path in the scene tree if it doesn't exist.
	var category_node
	if not objects_container.has_node(category):
		category_node = Control.new()
		category_node.name = category
		objects_container.add_child(category_node)
	else:
		category_node = objects_container.get_node(category)
	
	var obj_type_node
	if not category_node.has_node(obj_type):
		obj_type_node = Control.new()
		obj_type_node.name = obj_type
		category_node.add_child(obj_type_node)
	else:
		obj_type_node = category_node.get_node(obj_type)
	
	# Naming the new object
	# Check if the dictionary path exists, and get the count from there.
	var count = 0
	if all_objects_data.has(category) and all_objects_data[category].has(obj_type):
		count = all_objects_data[category][obj_type].size()
	new_object.name = obj_type + "_" + str(count)
	
	# Adding the new object (scene) to the correct container
	obj_type_node.add_child(new_object)

	# Initializing default values and setting properties from the global template
	var template_data = Global.OBJECT_TEMPLATE[category][obj_type]
	new_object.set_properties(category, obj_type, template_data, num_sections)
	
	# Hiding unwanted labels from object
	if category == "generator":
		new_object.toggle_label("sections")
	elif category == "distribution box":
		new_object.toggle_label("sections")
		new_object.toggle_label("power")
	
	# Setting object color by category
	var button = new_object.get_node("Button") # Or "Control/Button" if nested
	button.modulate = Global.OBJECT_TEMPLATE[category]["color"]
	
	# Connecting the object built-in button
	new_object.connect("object_pressed", Callable(canvas, "set_selected"))

	latest_created_object = new_object
	placing_object = true
	new_object.reset_labels()
	return true

# Get the size of the object from the global template
func get_object_size(new_object, category, obj_type) -> Vector2:
	new_object.size_m = Global.OBJECT_TEMPLATE[category][obj_type]["size"]
	var obj_size = Global.to_px(new_object.size_m)
	if category == "tent":
		obj_size.y *= num_sections
	return obj_size

# Update object position on the canvas
func move_object(obj):
	if not utils.is_within_bounds():
		return
	var pos_px = canvas.get_local_mouse_position() - origin.position
	pos_px.x = round(pos_px.x / canvas.snap_size) * canvas.snap_size
	pos_px.y = round(pos_px.y / canvas.snap_size) * canvas.snap_size
	
	# apply zoom factor to pos
	var current_zoom = origin.scale.x
	pos_px /= current_zoom
	
	obj.position = pos_px
	obj.pos_m = Global.to_m(pos_px)


func confirm_placement():
	placing_object = false
	var type = latest_created_object.get_parent().name
	var category = latest_created_object.get_parent().get_parent().name
	
	# Dynamically create the nested dictionary structure if it doesn't exist
	if not all_objects_data.has(category):
		all_objects_data[category] = {}
	if not all_objects_data[category].has(type):
		all_objects_data[category][type] = {}
	
	# Store the control node
	all_objects_data[category][type][latest_created_object.name] = latest_created_object
	
	# Connect to connection point signals  - new - 
	for connection_point in latest_created_object.get_node("ConnectionPoints").get_children():
		if connection_point.is_in_group("connection_point"):
			#print("Connected signal 'pressed' from: ", connection_point.name, " to Obj script.")
			connection_point.connect("pressed", Callable(self, "_on_connection_point_pressed").bind(connection_point))
	
	canvas.println("New object created with category <" + str(category) + "> and type <" + str(type) + ">")
	# Spawn a new object of the same type for continuous placement
	new_object_pressed(category, type)


func cancel_placement():
	latest_created_object.queue_free()
	placing_object = false


func has_template(category, obj_type) -> bool:
	if Global.OBJECT_TEMPLATE.has(category):
		if Global.OBJECT_TEMPLATE[category].has(obj_type):
			return true
		else:
			print("No %s in object types template" % obj_type)
			return false
	else:
		print("no object of type %s in template" % obj_type)
		return false


func delete_obj():
	for object in Global.last_selection_content:
		var category = object.category
		var obj_type = object.obj_type
		var name = object.name
		if all_objects_data.has(category) and all_objects_data[category].has(obj_type):
			if all_objects_data[category][obj_type].has(name):
				all_objects_data[category][obj_type].erase(name)
		object.queue_free()
	Global.last_selection_content.clear()


func _on_connection_point_pressed(point: Node2D):
	if not is_connecting:
		# Start a new connection
		if point.type == "output":
			is_connecting = true
			start_point = point
			connecting_line = Line2D.new()
			connecting_line.add_point(start_point.global_position / origin.scale)
			connecting_line.add_point(get_local_mouse_position() / origin.scale)
			origin.add_child(connecting_line)
	else:
		# Complete a connection
		if point.type == "input" and start_point != point:
			if validate_connection(start_point, point):
				connecting_line.set_point_position(1, point.global_position / origin.scale)
				
				# Store the connection
				all_connections[start_point] = point
				
				# Reset connection state
				is_connecting = false
				start_point = null
				connecting_line = null
				
				# Trigger calculation function here
				
			else:
				# Invalid connection, clean up the line
				connecting_line.queue_free()
				is_connecting = false
				start_point = null
				connecting_line = null


func validate_connection(start: Node2D, end: Node2D) -> bool:
	# 1. Check for valid connector types
	if start.connector_name != end.connector_name:
		print("Invalid connection: Connector types do not match.")
		return false

	# 2. Check for hierarchical constraints
	# Output from a generator must connect to a distribution box or load
	var start_category = start.get_parent().get_parent().get_parent().name
	var end_category = end.get_parent().get_parent().get_parent().name
	
	if start_category == "generator" and end_category == "generator":
		print("Invalid connection: Cannot connect a generator to another generator.")
		return false
	
	# More rules can be added here (e.g. distribution boxes to loads, etc.)
	
	print("Connection is valid!")
	return true
