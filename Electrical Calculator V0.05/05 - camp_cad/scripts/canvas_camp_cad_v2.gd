# canvas_camp_cad_v2.gd
extends Panel

@onready var obj_camp_cad_v2 = $"../../../Scripts/Obj"
@onready var utils = $"../../../Scripts/Utils"
@onready var origin = $Origin
@onready var scales: Control = $"../../../Scripts/scales"
@onready var canvas: Panel = $"."

# Snapping variables
@onready var snap_size = 32
# Selection variables
@onready var selector = $Origin/Selector
@onready var dragging
@onready var last_selection_transform
@onready var last_selection_content: Array
# Panning variables
@onready var is_panning = false
@onready var last_mouse_pos
# Scaling variables
@onready var max_zoom_scale := 3.0
@onready var min_zoom_scale := 0.2
@onready var zoom_factor := 1.1


func _input(event):
	
	selection(event)
	pan(event)
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and origin.scale.x < max_zoom_scale:
			origin.scale *= zoom_factor
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and origin.scale.x > min_zoom_scale:
			origin.scale /= zoom_factor


func pan(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				if utils.is_within_bounds():
					is_panning = true
					last_mouse_pos = event.position
			else:
				is_panning = false
	elif event is InputEventMouseMotion:
		if is_panning:
			var mouse_delta = event.position - last_mouse_pos
			origin.position += mouse_delta
			last_mouse_pos = event.position


func selection(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if dragging and not event.pressed:
				#dragging = false
				selector.position = -selector.position
				selector.size = Vector2(0, 0)
				utils.init_pos = null
				last_selection_content = utils.get_objects_in_selection(last_selection_transform, obj_camp_cad_v2.all_objects_data)
				if last_selection_content:
					# Do stuff with stuff inside selection here
					print("Objects: ", last_selection_content)
					last_selection_transform = null
					last_selection_content.clear()
			
			dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		last_selection_transform = utils.update_selector(selector)
