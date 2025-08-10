# objects.gd
extends Control

# Node references for debugging labels
@onready var debug_labels: Control = $debug
@onready var x_label: Label = $debug/x_Label
@onready var y_label: Label = $debug/y_Label
@onready var pos_label: Label = $debug/pos_Label
@export var debug := true

# Scene for the connection point visuals
var connection_point_scene = preload("res://05 - camp_cad/scenes/connection_point.tscn")

# Instance variables to hold object-specific properties
var object_name: String
var total_power_draw: float # to be set by user manually
var sections: int
var elec_inputs: Array
var elec_outputs: Array
var fuel_type: String
var fuel_consumption_rate: float

# UI and layout variables
var name_label: Label
var power_label: Label
var sections_label: Label
var labels: Array
var pos_m: Vector2
var size_m: Vector2
var last_object_size: Vector2
var expand_size := Vector2(200, 200)
var expanded := false
var last_global_pos
var last_local_pos

func _ready() -> void:
	name_label = $"VBoxContainer/Name Label"
	power_label = $"VBoxContainer/Power Label"
	sections_label = $"VBoxContainer/Sections Label"
	labels = [name_label, power_label, sections_label]
	reset_labels()


func _process(_delta: float) -> void:
	if debug:
		size_m = Scales.to_m(size)
		pos_m = Scales.to_m(position)
		x_label.text = Global.format_number(size_m.x)
		y_label.text = Global.format_number(size_m.y)
		pos_label.text = "(" + Global.format_number(pos_m.x) + ", " + Global.format_number(pos_m.y) + ")"


func set_properties(name: String, template_data: Dictionary, num_sections: int):
	self.object_name = name
	self.elec_inputs = template_data.get("elec_inputs", [])
	self.elec_outputs = template_data.get("elec_outputs", [])
	self.fuel_type = template_data.get("fuel_type", "")
	self.fuel_consumption_rate = template_data.get("fuel_consumption_rate", 0.0)
	self.total_power_draw = 0.0
	self.sections = num_sections
	update_labels()
	create_connection_points()


# Dynamically creates Area2D nodes for each connector defined in the template
func create_connection_points():
	var connection_points_container = Node2D.new()
	connection_points_container.name = "ConnectionPoints"
	add_child(connection_points_container)
	
	var total_inputs = 0
	for input in elec_inputs:
		total_inputs += input.quantity
	
	var total_outputs = 0
	for output in elec_outputs:
		total_outputs += output.quantity

	# Create input points on the bottom edge
	var input_x_offset = 0
	var input_spacing = (size.x - 20) / max(1, total_inputs)
	for input in elec_inputs:
		for i in range(input.quantity):
			var new_point = connection_point_scene.instantiate()
			# Position relative to the object's bottom edge, with spacing
			new_point.position = Vector2(10 + input_x_offset, size.y)
			
			# Store connector properties
			new_point.type = "input"
			new_point.connector_name = input.connector
			new_point.phase = input.phase
			new_point.amperage = input.amperage
			new_point.voltage = input.voltage
			
			connection_points_container.add_child(new_point)
			input_x_offset += input_spacing
	
	# Create output points on the top edge
	var output_x_offset = 0
	var output_spacing = (size.x - 20) / max(1, total_outputs)
	for output in elec_outputs:
		for i in range(output.quantity):
			var new_point = connection_point_scene.instantiate()
			# Position relative to the object's top edge, with spacing
			new_point.position = Vector2(10 + output_x_offset, 0)
			
			# Store connector properties
			new_point.type = "output"
			new_point.connector_name = output.connector
			new_point.phase = output.phase
			new_point.amperage = output.amperage
			new_point.voltage = output.voltage
			
			connection_points_container.add_child(new_point)
			output_x_offset += output_spacing


func toggle_label(label: String) -> void:
	match label:
		"name":
			name_label.visible = not name_label.visible
		"power":
			power_label.visible = not power_label.visible
		"sections":
			sections_label.visible = not sections_label.visible


func set_object_name(new_name: String) -> void:
	object_name = new_name
	update_labels()


func set_object_power(new_power: float) -> void:
	total_power_draw = new_power
	update_labels()


func set_num_sections(new_num_sections: int) -> void:
	# Clamping num sections to always be 1, 2, 3, 4
	if new_num_sections > 4:
		new_num_sections = 4
	elif new_num_sections <= 0:
		new_num_sections = 1
	sections = new_num_sections
	update_labels()


func update_labels() -> void:
	for label in labels:
		if label == name_label:
			label.text = object_name
		elif label == power_label:
			label.text = "Power drawn: " + str(total_power_draw) + "w"
		elif label == sections_label:
			if sections > 1:
				label.text = str(sections) + " sections"
			else:
				label.text = str(sections) + " section"


func toggle_expand() -> void:
	if expanded:
		collapse()
	else:
		expand()
	expanded = not expanded


func expand() -> void:
	last_global_pos = global_position
	last_local_pos = position
	update_labels()
	last_object_size = size
	size = expand_size
	top_level = true
	position = last_global_pos


func collapse() -> void:
	reset_labels()
	size = last_object_size
	top_level = false
	position = last_local_pos


func reset_labels() -> void:
	for label in labels:
		label.text = ""


func _on_button_pressed() -> void:
	print(self)
	toggle_expand()
