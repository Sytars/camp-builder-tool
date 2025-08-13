# connection_point.gd
extends Node2D
signal pressed(point)

var type: String
var connector_name: String
var phase: String
var amperage: int
var voltage: String

func _ready():
	add_to_group("connection_point")

func _on_connector_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	print("test")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("pressed", self)
