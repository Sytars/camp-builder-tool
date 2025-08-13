extends Panel
@onready var bg = $BG


func _on_bg_color_bg_color(r, g, b):
	bg.color = Color(r / 255, g / 255, b / 255)
