extends Control

var resolutions = [
	Vector2i(3840, 2160),
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1536, 864),
	Vector2i(1440, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
]

func _on_res_button_pressed(res: Vector2):
	Global.set_resolution(res)
	


func create_buttons():
	for res in resolutions:
		var res_button = Button.new()
		res_button.text = str(res.x) + " x " + str(res.y)
		res_button.theme = load("res://themes/ButtonsTheme.tres")
		res_button.custom_minimum_size.y = 40
		res_button.pressed.connect(func(): _on_res_button_pressed(res))
		add_child(res_button)

func _on_resolution_pressed():
	if get_child_count() > 0:
		return
	create_buttons()

