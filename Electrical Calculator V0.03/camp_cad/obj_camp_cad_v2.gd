extends Control
class_name Obj

@onready var objects_container = $"../../Panel/VBoxContainer/Canvas/Origin/Objects Container" # New objects added to this node
@onready var objects_scene = preload("res://scenes/objects.tscn") # A Control node with buttons and text, visually represents an object
@onready var utils = $"../Utils"
@onready var canvas = $"../../Panel/VBoxContainer/Canvas"
@onready var origin = $"../../Panel/VBoxContainer/Canvas/Origin"

var latest_created_object: Control
var placing_object: bool = false
@onready var num_sections: int = 4


var all_objects_data = {}


# Used to assign a default size to new objects
var object_template = {
	"tent": {
		"hqss": Vector2(60, 28),
		"mod": Vector2(68, 24)
	},
	"generator": {
		"30kw": Vector2(30, 20),
		"60kw": Vector2(30, 20)
	}
}


func _ready():
	initialise_objects_containers(object_template)


func _process(_delta):
	if placing_object:
		move_object(latest_created_object)


func _input(event):
	# Object placement inputs
	if placing_object:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			confirm_placement()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_placement()
		return


func initialise_objects_containers(template: Dictionary) -> void:
	all_objects_data.clear()
	_build_recursive(template, objects_container, all_objects_data)


func _build_recursive(template: Dictionary, parent_node: Control, parent_data: Dictionary) -> void:
	for key in template.keys():
		# Create a new visual node
		var node := Control.new()
		node.name = key
		parent_node.add_child(node)

		# Add corresponding dictionary entry
		parent_data[key] = {}

		# Recurse if the value is another dictionary
		if typeof(template[key]) == TYPE_DICTIONARY:
			_build_recursive(template[key], node, parent_data[key])


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
	
	# Giving the new object a size and a name
	new_object.size = get_object_size(category, obj_type)
	
	new_object.name = obj_type + "_" + str(objects_container.get_node(category).get_node(obj_type).get_child_count())
	
	# Adding the new object (scene) to the correct container
	objects_container.get_node(category).get_node(obj_type).add_child(new_object)
	
	latest_created_object = new_object
	placing_object = true
	return true


func move_object(obj):
	if not utils.is_within_bounds():
		return
	var pos = canvas.get_local_mouse_position() - origin.position
	pos.x = round(pos.x / canvas.snap_size) * canvas.snap_size
	pos.y = round(pos.y / canvas.snap_size) * canvas.snap_size
	obj.position = pos


func confirm_placement():
	placing_object = false
	var type = latest_created_object.get_parent().name
	var category = latest_created_object.get_parent().get_parent().name
	all_objects_data[category][type][latest_created_object.name] = latest_created_object
	new_object_pressed(category, type)
	


func cancel_placement():
	latest_created_object.queue_free()
	placing_object = false


func get_object_size(category, obj_type) -> Vector2:
	var obj_size = object_template[category][obj_type]
	if category == "tent":
		obj_size.y *= num_sections
	return obj_size


func has_template(category, obj_type) -> bool:
	if object_template.has(category):
		if object_template[category].has(obj_type):
			return true
		else:
			print("No %s in object types template" % obj_type)
			return false
	else:
		print("no object of type %s in template" % obj_type)
		return false



