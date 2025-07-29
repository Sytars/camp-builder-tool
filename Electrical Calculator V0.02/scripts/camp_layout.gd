extends Control

# Nodes
@onready var panel = $Panel
@onready var ribbon = $Panel/Ribbon
@onready var arrow = $Panel/Ribbon/Collapse_Ribbon/Arrow
@onready var snap_edit = $"Panel/Ribbon/Snapping accuracy/HBoxContainer/snap_edit"
@onready var snap_label = $"Panel/Ribbon/Snapping accuracy/snap_label"
@onready var snap_slider = $"Panel/Ribbon/Snapping accuracy/HBoxContainer/snap_slider"
@onready var collapse_animations = $collapse_animations
@onready var selection_timer = $selection_timer
@onready var new_tent_button = $"Panel/Ribbon/New Tent/new_tent_button"
@onready var tent_selection_ribbon = $"Panel/Ribbon/New Tent/Tent Selection Ribbon"
@onready var tents = $Tents
@onready var num_sections_label = $"Panel/Ribbon/New Tent/Tent Selection Ribbon/num_sections_label"
@onready var num_sections_slider = $"Panel/Ribbon/New Tent/Tent Selection Ribbon/num_sections_slider"
@onready var tents_data = null
@onready var selector = $Selector
var dragging := false
var init_pos
var last_selection
var tents_in_selection := []


# Config
@onready var snap_size: float = 64.0
var collapsed = true
var selecting_tent_type = false

# Ready
func _ready():
	num_sections_slider.value = 4
	ribbon.visible = false
	tent_selection_ribbon.visible = false
	snap_label.text = "Snap precision: "
	print("ready snap size: ", snap_size)
	snap_slider.value = snap_size
	snap_edit.text = str(snap_size)
	panel.size.x = 50
	tents.set_snap_size(snap_size)


# Input Handling
func _input(event):
	if not visible:
		return

	if Input.is_action_just_pressed("enter"):
		snap_edit.release_focus()
		if snap_edit.text.is_valid_float():
			snap_size = float(snap_edit.text)
			snap_slider.value = snap_size
		if tents_data:
			print("Tents data: ", tents_data)

	if collapsed and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var unsnapped_pos = get_click_pos_relative_to_node(event)
		if unsnapped_pos != null:
			#print("Unsnapped Position: ", unsnapped_pos)
			var snapped_pos = snap_vector2(unsnapped_pos, snap_size, size)
			#print("Snapped Position (for depositing): ", snapped_pos)
	
 	# Selection input
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if dragging and not event.pressed:
				init_pos = null
				selector.position = -selector.position
				selector.size = Vector2(0, 0)
				get_objects_in_selection()
				print("Objects: ", tents_in_selection)
			dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		if not init_pos:
			init_pos = get_local_mouse_position()
		update_selector()
		


# Utility Functions

func get_objects_in_selection():
	tents_in_selection = []
	if not last_selection:
		return
	if tents_data:
		for tent_type in tents_data:
			for tent in tents_data[tent_type]:
				var tent_pos = tents_data[tent_type][tent]["position"]
				var tent_size = tents_data[tent_type][tent]["size"]
				print("tent pos: ", tent_pos)
				print("tent size: ", tent_size)
				print("selection pos: ", last_selection["position"])
				print("selection size: ", last_selection["size"])
				tent_pos.x -= tent_size.x * 2
				tent_pos.y -= tent_size.y / 2
				if Rect2(last_selection["position"], last_selection["size"]).encloses(Rect2(tent_pos, tent_size)):
					tents_in_selection.append(tent)
				if Rect2(tent_pos, tent_size).intersects(Rect2(last_selection["position"], last_selection["size"])):
					pass#tents_in_selection.append(tent)




func update_selector():
	var mouse_pos := get_local_mouse_position()
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
		"position": selector.position,
		"size": selector.size
	}


func get_click_pos_relative_to_node(event: InputEventMouseButton):
	var mouse_global = get_global_mouse_position()
	var node_origin = get_global_transform().origin
	var relative = mouse_global - node_origin
	if relative.x < 0 or relative.y < 0 or relative.x > size.x or relative.y > size.y:
		return null
	return relative


func snap_vector2(pos: Vector2, snap: float, bounds: Vector2) -> Vector2:
	if snap <= 0:
		return pos

	var snapped_x = clamp(round(pos.x / snap) * snap, 0.0, bounds.x - fmod(bounds.x, snap))
	var snapped_y = clamp(round(pos.y / snap) * snap, 0.0, bounds.y - fmod(bounds.y, snap))
	return Vector2(snapped_x, snapped_y)


func reset_new_tent_ribbon():
	new_tent_button.text = "New Tent"
	new_tent_button.visible = true
	tent_selection_ribbon.visible = false
	
	
# Collapse Handling
func switch_collapse():
	collapsed = !collapsed
	tents.set_menu_collapsed(collapsed)
	collapse_animations.play("expand" if not collapsed else "collapse")



func _on_collapse_animations_animation_finished(anim_name):
	if anim_name == "expand":
		collapsed = false
	elif anim_name == "collapse":
		collapsed = true
		reset_new_tent_ribbon()
	tents.set_menu_collapsed(collapsed)

func _on_panel_mouse_entered():
	if collapsed:
		collapse_animations.play("expand")


func _on_mouse_entered():
	if not collapsed:
		collapse_animations.play("collapse")


# Save Load Handling
func _get_save_data() -> Dictionary:
	var data_to_save = {}
	# Saving snap precision
	data_to_save["snap_precision"] = {
		"snap_value": snap_size
	}
	return data_to_save


func _apply_load_data(loaded_data: Dictionary):
	if loaded_data.has("snap_precision"):
		snap_size = loaded_data["snap_precision"]["snap_value"]
		tents.set_snap_size(snap_size)
		snap_slider.value = snap_size
		snap_edit.text = str(snap_size)



func _on_h_slider_value_changed(value):
	snap_edit.text = str(value)
	snap_size = float(value)
	tents.set_snap_size(snap_size)


func _on_snap_edit_focus_entered():
	selection_timer.start()


func _on_selection_timer_timeout():
	snap_edit.select()
	selection_timer.stop()


func _on_new_tent_button_pressed():
	if tent_selection_ribbon.visible == false:
		tent_selection_ribbon.visible = true
		new_tent_button.text = "Cancel"
	elif tent_selection_ribbon.visible == true:
		tent_selection_ribbon.visible = false
		new_tent_button.text = "New Tent"
		tents.cancel_placement()


func _on_mod_button_pressed():
	tents.new_tent("mod", num_sections_slider.value)


func _on_hqss_button_pressed():
	tents.new_tent("hqss", num_sections_slider.value)


func _on_num_sections_slider_value_changed(value):
	num_sections_label.text = "Sections: " + str(value)


func _on_tents_send_tents_data(data):
	tents_data = data
