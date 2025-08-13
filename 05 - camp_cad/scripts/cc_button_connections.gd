# cc_button_connections.gd
extends HBoxContainer
@onready var num_section_label: Label = $"new tent panel/New Tent Container/Num Section Label"
@onready var obj: Obj = $"../../../../../../Scripts/Obj"


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


func _on_lex_200_button_pressed() -> void:
	obj.new_object_pressed("distribution box", "lex200")


func _on_lex_800_button_pressed() -> void:
	obj.new_object_pressed("distribution box", "lex800")


func _on_lex_1200_button_pressed() -> void:
	obj.new_object_pressed("distribution box", "lex1200")


func _on_delete_objects_button_pressed() -> void:
	obj.delete_obj()


func _on_move_objects_button_pressed() -> void:
	pass # Replace with function body.
