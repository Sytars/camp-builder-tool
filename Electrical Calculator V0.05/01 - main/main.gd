extends Control

# References
@onready var camp_cad = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Camp Cad2"
@onready var ohm_law_calc = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/OhmLawCalc"
@onready var settings = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Settings"

@onready var calculators = [camp_cad, ohm_law_calc, settings]

# ------------- To add a new tab and scene  -------------
# 1: Create a new button in calculators menu node
# 2: Add the scene to the calculator window node
# 3: Create reference of new scene in this script above ^
# 4: Add the new variable of the new scene to the calculators list
# 5: Connect the button to set_state


func _ready():
	SaveLoad.load_data()
	if calculators:
		set_state(camp_cad)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("NOTIFICATION_WM_CLOSE_REQUEST triggered")
		SaveLoad.save_data()
		get_tree().quit()

func set_state(state):
	for calc in calculators:
		calc.visible = false
	state.visible = true


func _on_cad_button_pressed() -> void:
	set_state(camp_cad)


func _on_ohm_law_button_pressed() -> void:
	set_state(ohm_law_calc)


func _on_exit_button_pressed() -> void:
	SaveLoad.save_data()
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	set_state(settings)
