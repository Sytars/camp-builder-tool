#scales.gd
extends Node

@onready var pixels_per_meter = 10

func to_m(distance_px: Vector2) -> Vector2:
	return distance_px / pixels_per_meter

func to_px(distance_m: Vector2) -> Vector2:
	return distance_m * pixels_per_meter
