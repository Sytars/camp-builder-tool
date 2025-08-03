extends Control

@onready var name_label = $"VBoxContainer/Name Label"
@onready var power_label = $"VBoxContainer/Power Label"
@onready var sections_label = $"VBoxContainer/Sections Label"

var object_name: String
var power: float
var sections: int


	
func _on_button_pressed():
	print("test")
