extends Control

@onready var axis_button = $"../Panel/Ribbon/Axis_button"


var color := Color(1, 1, 1, 0.5)
var show_axis := false


func _process(_delta):
	queue_redraw()


func _input(event):
	if Input.is_action_just_pressed("toggle_action_X"):
		toggle_axis()


func _draw():
	if not visible:
		return
	if not show_axis:
		return
		
	var viewport_size = get_viewport_rect().size

	# Vertical line
	draw_line(
		Vector2(get_local_mouse_position().x, 0),
		Vector2(get_local_mouse_position().x, viewport_size.y),
		color, 1.5
	)
	get_local_mouse_position()
	# Horizontal line
	draw_line(
		Vector2(0, get_local_mouse_position().y),
		Vector2(viewport_size.x, get_local_mouse_position().y),
		color, 1.5
	)


func toggle_axis():
	show_axis = not show_axis
	axis_button.text = "Show axis (x)" if not show_axis else "Hide axis (x)"
	
func _on_axis_button_pressed():
	toggle_axis()
