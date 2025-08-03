extends HBoxContainer
@onready var obj = $"../../../../../../Scripts/Obj"


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
