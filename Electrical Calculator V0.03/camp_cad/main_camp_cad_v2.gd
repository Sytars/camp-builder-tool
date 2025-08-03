extends Control

@onready var new_object_tab = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/New Object Tab"
@onready var edit_tab = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/Edit Tab"

@onready var tabs = [new_object_tab, edit_tab]




func _ready():
	set_state(new_object_tab)



func set_state(state):
	for tab in tabs:
		tab.visible = false
	state.visible = true


func _on_new_object_pressed():
	set_state(new_object_tab)


func _on_edit_pressed():
	set_state(edit_tab)
