# button_connections_camp_cad_v2.gd
extends HBoxContainer
@onready var obj = $"../../../../../../Scripts/Obj"
@onready var num_section_label: Label = $"new tent panel/New Tent Container/Num Section Label"


func _on_mod_tent_button_pressed():
	obj.new_object_pressed("tent", "mod")


func _on_hqss_button_pressed():
	obj.new_object_pressed("tent", "hqss")


func _on_30kw_button_pressed():
	obj.new_object_pressed("generator", "30kw")


func _on_kw_button_pressed():
	obj.new_object_pressed("generator", "60kw")


func _on_num_section_slider_value_changed(value):
	obj.num_sections = value
	num_section_label.text = "Section(s) : " + str(int(value))
