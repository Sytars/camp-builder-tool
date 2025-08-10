extends Control
@onready var hor_line: Line2D = $hor_line
@onready var start_edge_line: Line2D = $start_edge_line
@onready var end_edge_line: Line2D = $end_edge_line
@onready var label: Label = $Label
@onready var canvas: Panel = $".."
@onready var origin: Control = $"../Origin"

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	var line_length_px = hor_line.points[1].x - hor_line.points[0].x
	var line_length_m = line_length_px / Scales.pixels_per_meter
	var current_scale = origin.scale.x
	line_length_m /= current_scale
	var result_str = Global.format_number(line_length_m)
	label.text = result_str + "m"
