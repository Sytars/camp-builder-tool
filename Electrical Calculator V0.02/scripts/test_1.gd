extends Node2D
@onready var test = $"."
@onready var margin_container = $".."
@onready var origin_point = $Origin_point
@onready var vp_size = margin_container.get_viewport_rect().size

@onready var vertical_lines := []
@onready var horizontal_lines := []
@onready var debug = false

var default_origin_pos
var original_grid_size = 64
var grid_size
var original_move_speed = 2000.0
var move_speed
var target_pos: Vector2
var moving = false
var is_panning = false
var last_mouse_pos = Vector2.ZERO
var zoom_factor := 1.0
var min_zoom := 0.25
var max_zoom := 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	default_origin_pos = origin_point.position
	grid_size = original_grid_size
	move_speed = original_move_speed
	create_new_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not visible:
		return
	
	if moving:
		var to_target = target_pos - origin_point.position
		var distance = to_target.length()

		var max_step = move_speed * delta
		
		if distance <= max_step:
			# Snap to target and stop
			var move_vector = to_target / delta  # Reverse-engineer "direction * speed"
			move_grid(move_vector.normalized(), distance / move_speed)  # Move exactly to the target
			origin_point.position = target_pos
			moving = false
			move_speed = original_move_speed
		else:
			var direction = to_target.normalized()
			move_grid(direction, delta)
	
	var move_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		move_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		move_direction.y -= 1
	
	move_grid(move_direction, delta)

func _input(event):
	if not visible:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			apply_zoom(1.1, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			apply_zoom(1.0 / 1.1, event.position)
			
	pan(event)
	move_to_mouse_click(event)
	
	
func apply_zoom(factor: float, mouse_pos: Vector2):
	var new_zoom = clamp(zoom_factor * factor, min_zoom, max_zoom)
	var scale_change = new_zoom / zoom_factor
	zoom_factor = new_zoom
	
	grid_size = original_grid_size * zoom_factor
	
	# Pan origin_point to zoom centered on mouse
	var mouse_global = get_global_mouse_position()
	var mouse_before = origin_point.to_local(mouse_global)
	origin_point.scale *= scale_change
	var mouse_after = origin_point.to_local(mouse_global)
	var offset = (mouse_after - mouse_before) * origin_point.scale
	origin_point.position += offset

	# Redraw grid based on new grid size
	clear_grid()
	create_new_grid()


func clear_grid():
	for line in vertical_lines:
		line.queue_free()
	vertical_lines.clear()
	
	for line in horizontal_lines:
		line.queue_free()
	horizontal_lines.clear()



func pan(event):
	# Middle mouse press
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed and is_within_bounds():
			is_panning = true
			last_mouse_pos = event.position
		else:
			is_panning = false
	# Middle mouse drag motion
	elif event is InputEventMouseMotion and is_panning:
		var delta = event.position - last_mouse_pos
		last_mouse_pos = event.position
		# We move the grid in the opposite direction of the drag (standard pan behavior)
		move_grid(delta.normalized(), delta.length() / move_speed)


func move_to_mouse_click(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var target = is_within_bounds()
			if target:
				move_towards_pos(target)

func is_within_bounds():
	var mouse_global_pos = get_global_mouse_position()
	var node_global_pos = get_global_transform().origin
	var mouse_pos_relative_to_node = mouse_global_pos - node_global_pos

	var margin_bounds_size: Vector2
	var offset = 44
	margin_bounds_size.x = margin_container.size.x / 2
	margin_bounds_size.y = margin_container.size.y / 2
	if mouse_pos_relative_to_node.x < -margin_bounds_size.x + offset or mouse_pos_relative_to_node.x > margin_bounds_size.x + offset:
		return false
	if mouse_pos_relative_to_node.y < -margin_bounds_size.y - offset/2 or mouse_pos_relative_to_node.y > margin_bounds_size.y - offset/2:
		return false
	return mouse_pos_relative_to_node

func move_towards_pos(pos: Vector2):
	target_pos = pos
	moving = true


func move_grid(move_direction, delta):
	origin_point.position += move_direction * move_speed * delta
	
	for line in vertical_lines:
		line.position.x += move_direction.x * move_speed * delta
		if line.name.begins_with("v_axis"):
			continue
		var distance_x = default_origin_pos.x - line.position.x
		var wrap_width = (vertical_lines.size() - 2) * grid_size
		if distance_x > wrap_width / 2:
			line.position.x += wrap_width
		elif distance_x < -wrap_width / 2:
			line.position.x -= wrap_width

	for line in horizontal_lines:
		line.position.y += move_direction.y * move_speed * delta
		if line.name.begins_with("h_axis"):
			continue
		var distance_y = default_origin_pos.y - line.position.y
		var wrap_height = (horizontal_lines.size() - 2) * grid_size
		if distance_y > wrap_height / 2:
			line.position.y += wrap_height
		elif distance_y < -wrap_height / 2:
			line.position.y -= wrap_height


# Method to gather data for saving
func _get_save_data() -> Dictionary:
	var data_to_save = {}
	
	# 1. Save the 'values' dictionary
	data_to_save["origin_position"] = {
		"x": origin_point.position.x, 
		"y": origin_point.position.y
	}
	return data_to_save


# Method to apply loaded data
func _apply_load_data(loaded_data: Dictionary):
	if loaded_data.has("origin_position"):
		var pos = loaded_data["origin_position"]
		move_speed = 10000
		move_towards_pos(Vector2(pos["x"], pos["y"]))
		
	

func create_new_grid(axis: bool=true):
	if axis:
		better_segment("h", Vector2(origin_point.position.x - vp_size.x / 2, origin_point.position.y), "_axis", 4.0)
		better_segment("v", Vector2(origin_point.position.x, origin_point.position.y - vp_size.y / 2), "_axis", 4.0)
	
	var number_v_segments = int(ceil(vp_size.x / grid_size)) + 2
	var number_h_segments = int(ceil(vp_size.y / grid_size)) + 2
	
	for i in range(-1, number_h_segments - 1):
		var y = origin_point.position.y - vp_size.y / 2 + i * grid_size + (int(vp_size.y/2) % int(grid_size))
		better_segment("h", Vector2(origin_point.position.x - vp_size.x / 2, y), "")

	for i in range(-1, number_v_segments - 1):
		var x = origin_point.position.x - vp_size.x / 2 + i * grid_size + (int(vp_size.x/2) % int(grid_size))
		better_segment("v", Vector2(x, origin_point.position.y - vp_size.y / 2), "")


func better_segment(axis: String, pos: Vector2, _name: String, width: float=1.0):
	var segment = Line2D.new()
	segment.width = width
	if axis == "v":
		segment.name = ("v" + _name)
		segment.position = pos
		segment.default_color = Color(0.4, 0.4, 1.0, 1.0) # Blue color
		segment.add_point(Vector2(0, 0))
		segment.add_point(Vector2(0, vp_size.y))
		vertical_lines.append(segment)
	elif axis == "h":
		segment.name = ("h" + _name)
		segment.position = pos
		segment.default_color = Color(0.4, 0.4, 1.0, 1.0) # Blue color
		segment.add_point(Vector2(0, 0))
		segment.add_point(Vector2(vp_size.x, 0))
		horizontal_lines.append(segment)
	add_child(segment)
