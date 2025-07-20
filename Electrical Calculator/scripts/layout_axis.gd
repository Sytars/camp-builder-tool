extends Control

var axis_origin := Vector2.ZERO

var color := Color(0.8, 0.8, 0.2, 0.5)  # soft yellow lines

func _ready():
	visible = false

func set_axis_origin(pos: Vector2):
	axis_origin = pos
	queue_redraw()

func show_axis(enable: bool):
	visible = enable
	queue_redraw()

func _draw():
	if not visible:
		return

	var viewport_size = get_viewport_rect().size

	# Vertical line
	draw_line(
		Vector2(axis_origin.x, 0),
		Vector2(axis_origin.x, viewport_size.y),
		color, 1.5
	)

	# Horizontal line
	draw_line(
		Vector2(0, axis_origin.y),
		Vector2(viewport_size.x, axis_origin.y),
		color, 1.5
	)
