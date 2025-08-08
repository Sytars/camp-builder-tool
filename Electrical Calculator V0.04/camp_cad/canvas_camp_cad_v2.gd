extends Panel

@onready var object_container = $"../../../Scripts/Obj"
@onready var utils = $"../../../Scripts/Utils"
@onready var origin = $Origin

# Snapping variables
@onready var snap_size = 32
# Selection variables
@onready var selector = $Selector
@onready var dragging
@onready var last_selection_transform
@onready var last_selection_content: Array
# Panning variables
@onready var is_panning = false
@onready var last_mouse_pos


func _input(event):
	selection(event)
	pan(event)


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
				last_selection_content = utils.get_objects_in_selection(last_selection_transform, object_container.all_objects_data)
				if last_selection_content:
					# Do stuff with stuff inside selection here
					print("Objects: ", last_selection_content)
					last_selection_transform = null
					last_selection_content.clear()
			
			dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		last_selection_transform = utils.update_selector(selector)
