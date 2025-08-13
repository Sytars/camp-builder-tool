# cc_canvas.gd
extends Panel

@onready var cc_obj_manager = $"../../../Scripts/Obj"
@onready var utils = $"../../../Scripts/Utils"
@onready var origin = $Origin
@onready var canvas: Panel = $"."

# Console variables
@onready var canvas_console: RichTextLabel = $canvas_console
@onready var canvas_console_timer: Timer = $canvas_console_Timer
var debug_messages: Array = []
const MAX_LINES: int = 5
# Snapping variables
@onready var snap_size = 32
# Selection variables
@onready var selector = $Origin/Selector
@onready var dragging
@onready var last_selection_transform
# Panning variables
@onready var is_panning = false
@onready var last_mouse_pos
# Scaling variables
@onready var max_zoom_scale := 3.0
@onready var min_zoom_scale := 0.2
@onready var zoom_factor := 1.1
@onready var scale_hor_line: Line2D = $visual_scale/scale_hor_line
@onready var scale_label: Label = $visual_scale/scale_label




func _process(_delta: float) -> void:
	update_visual_scale()


func _input(event):
	if not utils.is_within_bounds():
		return
	if cc_obj_manager.placing_object :
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Global.last_selection_content != []:
			set_selected([])
	pan(event)
	scale_canvas(event)
	selection(event)


func set_selected(objects: Array):
	# Clear the selection by looping over any previously selected objects and resetting their state
	for object in Global.last_selection_content:
		var button = object.get_node("Button")
		button.modulate = Global.OBJECT_TEMPLATE[object.category]["color"]
	# Update the global selection content
	Global.last_selection_content = objects
	# Loop over the new selection and update their state (e.g., change color to show selection)
	for object in objects:
		var button = object.get_node("Button")
		button.modulate = Global.OBJECT_TEMPLATE[object.category]["color"].lightened(0.4)


func selection(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if dragging and not event.pressed:
				selector.position = -selector.position
				selector.size = Vector2(0, 0)
				utils.init_pos = null
				var last_selection_content = utils.get_objects_in_selection(last_selection_transform, cc_obj_manager.all_objects_data)
				if last_selection_content:
					set_selected(last_selection_content)
					last_selection_transform = null
			dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		last_selection_transform = utils.update_selector(selector)


func update_visual_scale():
	var line_length_px = scale_hor_line.points[1].x - scale_hor_line.points[0].x
	var line_length_m = line_length_px / Global.pixels_per_meter
	var current_scale = origin.scale.x
	line_length_m /= current_scale
	var result_str = Global.format_number(line_length_m)
	scale_label.text = result_str + "m"


func scale_canvas(event) -> void:
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


func println(text: Variant):
	canvas_console.visible = true
	debug_messages.append(str(text))
	if debug_messages.size() > MAX_LINES:
		debug_messages.pop_front()
	canvas_console.text = "\n".join(debug_messages)
	# ensures the timer gets reset on every new message
	canvas_console_timer.stop()
	# on timer end, hide console
	canvas_console_timer.start()

func _on_canvas_console_timer_timeout() -> void:
	canvas_console.visible = false
