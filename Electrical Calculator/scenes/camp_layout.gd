extends Control

# Nodes
@onready var panel = $Panel
@onready var ribbon = $Panel/Ribbon
@onready var arrow = $Panel/Ribbon/Collapse_Ribbon/Arrow
@onready var snap_edit = $"Panel/Ribbon/Snapping accuracy/HBoxContainer/snap_edit"
@onready var snap_label = $"Panel/Ribbon/Snapping accuracy/HBoxContainer/snap_label"
@onready var snap_slider = $"Panel/Ribbon/Snapping accuracy/snap_slider"
@onready var collapse_animations = $collapse_animations
@onready var selection_timer = $selection_timer
@onready var new_tent_button = $"Panel/Ribbon/New Tent/new_tent_button"
@onready var tent_selection_ribbon = $"Panel/Ribbon/New Tent/Tent Selection Ribbon"
@onready var tents = $Tents




# Config
@onready var snap_size: float = 64.0
var collapsed = true
var selecting_tent_type = false

# Ready
func _ready():
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

	if collapsed and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var unsnapped_pos = get_click_pos_relative_to_node(event)
		if unsnapped_pos != null:
			print("Unsnapped Position: ", unsnapped_pos)
			var snapped_pos = snap_vector2(unsnapped_pos, snap_size, size)
			print("Snapped Position (for depositing): ", snapped_pos)


# Utility Functions
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
	tent_selection_ribbon.visible = true


func _on_mod_button_pressed():
	tents.new("mod")


func _on_hqss_button_pressed():
	tents.new("hqss")
