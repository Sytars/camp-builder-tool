extends Control

# References
@onready var ohm_law_calc = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/OhmLawCalc"
@onready var pythagore = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Pythagore"
@onready var test_1 = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Test_1"
@onready var camp_electrical_calculator = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Camp Electrical calculator"
@onready var camp_layout = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/camp_layout"
@onready var menus_animation = $menus_animation
@onready var panel = $"MarginContainer/HBoxContainer/Selector Bar/Panel"
@onready var audio_stream_player = $AudioStreamPlayer
@onready var selector_bar = $"MarginContainer/HBoxContainer/Selector Bar"
@onready var settings = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Settings"
@onready var camp_cad = $"MarginContainer/HBoxContainer/Calculator Window/Panel/MarginContainer/Camp Cad"


@onready var calculators = [ohm_law_calc, pythagore, test_1, camp_electrical_calculator, camp_layout, settings, camp_cad]
@onready var collapsed = false


# ------------- To add a new tab and scene  -------------
# 1: Create a new button in calculators menu node
# 2: Add the scene to the calculator window node
# 3: Create reference of new scene in this script above ^
# 4: Add the new variable of the new scene to the calculators list
# 5: Connect the button to set_state


func _ready():
	menus_animation.play("expand")
	SaveLoad.load_data()
	if calculators:
		set_state(calculators[0])
	get_tree().connect("shutdown_requested", Callable(self, "_on_shutdown_requested"))

func _on_shutdown_requested():
	print("Shutdown requested — saving game before quit.")
	SaveLoad.save_data()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("NOTIFICATION_WM_CLOSE_REQUEST triggered")
		SaveLoad.save_data()
		get_tree().quit()

func set_state(state):
	for calc in calculators:
		calc.visible = false
	state.visible = true


func _on_quit_button_pressed():
	SaveLoad.save_data()
	get_tree().quit()


func _on_ohm_law_calc_button_pressed():
	set_state(ohm_law_calc)


func _on_pythagore_button_pressed():
	set_state(pythagore)


func _on_grid_pressed():
	set_state(test_1)


func _on_camp_electrical_load_pressed():
	set_state(camp_electrical_calculator)


func _on_camp_layout_pressed():
	set_state(camp_layout)


func _on_settings_label_pressed():
	set_state(settings)


func _on_camp_cad_pressed():
	set_state(camp_cad)


func _on_left_window_mouse_entered():
	if collapsed and menus_animation.is_playing() == false:
		menus_animation.play("expand")
		
func _on_right_window_mouse_entered():
	if not collapsed and menus_animation.is_playing() == false:
		menus_animation.play("collapse")

func _on_menus_animation_animation_finished(anim_name):
	if anim_name == "expand":
		collapsed = false
	elif anim_name == "collapse":
		collapsed = true
