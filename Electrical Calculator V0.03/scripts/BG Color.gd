extends VBoxContainer

@onready var r_label = $"R Label"
@onready var g_label = $"G Label"
@onready var b_label = $"B Label"
@onready var bg = $Panel/BG

@onready var r_slider = $"R Slider"
@onready var g_slider = $"G Slider"
@onready var b_slider = $"B Slider"

signal bg_color(r, g, b)


func _ready():
	update_label()


func update_label(label="all"):
	if label == "all":
		r_label.text = "Red: " + str(r_slider.value)
		g_label.text = "Green: " + str(g_slider.value)
		b_label.text = "Blue: " + str(b_slider.value)
	elif label == "r":
		r_label.text = "Red: " + str(r_slider.value)
	elif label == "g":
		g_label.text = "Green: " + str(g_slider.value)
	elif label == "b":
		b_label.text = "Blue: " + str(b_slider.value)


func update_color():
	emit_signal("bg_color", r_slider.value, g_slider.value, b_slider.value)


func _on_r_slider_value_changed(value):
	update_label("r")
	update_color()


func _on_g_slider_value_changed(value):
	update_label("g")
	update_color()


func _on_b_slider_value_changed(value):
	update_label("b")
	update_color()
