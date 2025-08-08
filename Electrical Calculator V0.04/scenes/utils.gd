extends Control

@onready var canvas = $".."
@onready var origin = $"../Origin"

var color := Color(1, 1, 1, 0.5)
var show_axis := false
var axis_position

func _process(_delta):
	queue_redraw()


func _draw():
	if not show_axis:
		return
		
	var viewport_size = get_viewport_rect().size
	# Vertical line
	draw_line(
		Vector2(axis_position.x, 0),
		Vector2(axis_position.x, canvas.size.y),
		color, 1.5
	)

	# Horizontal line
	draw_line(
		Vector2(0, axis_position.y),
		Vector2(canvas.size.x, axis_position.y),
		color, 1.5
	)





func update_axis(pos: Vector2):
	axis_position = pos


func toggle_axis():
	show_axis = not show_axis
	if show_axis:
		print("Showing axis")
	else:
		print("Hiding axis")
	return show_axis
		
	
