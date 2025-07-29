extends Control


@onready var resolutions = $Options_OptionsWindow/MarginContainer/Resolutions
@onready var bg_color = $"Options_OptionsWindow/MarginContainer/BG Color"


@onready var states = [resolutions, bg_color]

@onready var r_slider = $"Options_OptionsWindow/MarginContainer/BG Color/R Slider"
@onready var g_slider = $"Options_OptionsWindow/MarginContainer/BG Color/G Slider"
@onready var b_slider = $"Options_OptionsWindow/MarginContainer/BG Color/B Slider"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_state(resolutions)


func set_state(state):
	for s in states:
		s.visible = false
	state.visible = true

func _get_save_data() -> Dictionary:
	var data_to_save = {}
	data_to_save["bg_color"] = {
		"r": r_slider.value,
		"g": g_slider.value,
		"b": b_slider.value
	}
	return data_to_save


func _apply_load_data(loaded_data: Dictionary):
	if loaded_data.has("bg_color"):
		r_slider.value = loaded_data["bg_color"]["r"]
		g_slider.value = loaded_data["bg_color"]["g"]
		b_slider.value = loaded_data["bg_color"]["b"]
		bg_color.update_color()
	

func _on_resolution_pressed():
	set_state(resolutions)


func _on_theme_color_pressed():
	set_state(bg_color)
