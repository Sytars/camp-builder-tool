extends Panel
class_name Tabs

@onready var new_object_tab = $"New Object Tab"
@onready var edit_tab = $"Edit Tab"
@onready var num_section_label = $"New Object Tab/New Tent Container/Num Section Label"
@onready var num_section_slider = $"New Object Tab/New Tent Container/Num Section Slider"

@onready var states = [new_object_tab, edit_tab]


func _ready():
	set_state(new_object_tab)
	num_section_slider.value = 4



func set_state(target_state):
	for state in states:
		state.visible = false
	target_state.visible = true



func _on_new_object_pressed():
	set_state(new_object_tab)


func _on_edit_pressed():
	set_state(edit_tab)


func _on_num_section_slider_value_changed(value):
	num_section_label.text = "Section(s) : " + str(roundi(value))
