extends Control

@onready var new_object_tab: HBoxContainer = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/New Object Tab"
@onready var edit_tab: HBoxContainer = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/Edit Tab"
@onready var tools_tab: HBoxContainer = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/Tools Tab"
@onready var config_tab: HBoxContainer = $"Panel/VBoxContainer/Panel/VBoxContainer/Tabs Content Panel/Config Tab"

@onready var tabs := [new_object_tab, edit_tab, tools_tab, config_tab]

@onready var new_object: Button = $"Panel/VBoxContainer/Panel/VBoxContainer/Top Tabs Panel/Top Tabs/New Object"
@onready var edit: Button = $"Panel/VBoxContainer/Panel/VBoxContainer/Top Tabs Panel/Top Tabs/Edit"
@onready var tools: Button = $"Panel/VBoxContainer/Panel/VBoxContainer/Top Tabs Panel/Top Tabs/Tools"
@onready var config: Button = $"Panel/VBoxContainer/Panel/VBoxContainer/Top Tabs Panel/Top Tabs/Config"

@onready var buttons := [new_object, edit, tools, config]


func _ready() -> void:
	set_state(0)


func set_state(state) -> void:
	for i in range(tabs.size()):
		tabs[i].visible = false
		buttons[i].disabled = false
	tabs[state].visible = true
	buttons[state].disabled = true
	

func _on_new_object_pressed() -> void:
	set_state(0)


func _on_edit_pressed() -> void:
	set_state(1)


func _on_tools_pressed() -> void:
	set_state(2)


func _on_config_pressed() -> void:
	set_state(3)
