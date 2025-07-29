class_name Tents
extends Control

var tents_data = {
	"hqss": {},
	"mod": {}
}
signal send_tents_data
var placing_tent: bool = false
var current_tent: Control = null
var current_type: String = ""
var last_type: String = ""
var current_num_sections: int = 4
var snap_size := 10.0
var menu_collapsed = false

var hqss = {
	"name": "HQSS",
	"size": Vector2(100, 44)
}
var mod = {
	"name": "Mod Tent",
	"size": Vector2(90, 40)
}

func set_snap_size(size: float):
	snap_size = size

func set_menu_collapsed(b: bool):
	menu_collapsed = b
	
func new_tent(type: String, num_section: int= 4):
	if placing_tent:
		current_tent.queue_free()
	
	var tent = Button.new()
	tent.theme = load("res://themes/Tents.tres")
	tent.text = type.capitalize()
	var tent_size
	if type == "hqss":
		tent_size = hqss["size"]
	elif type == "mod":
		tent_size = mod["size"]
	tent.modulate = Color(1, 1, 1, 0.5)
	tent_size.y *= num_section
	tent.size = tent_size
	tent.disabled = true  # prevent click during placement
	tent.name = type + "_" + str(tents_data[type].size())
	add_child(tent)
	current_tent = tent
	current_type = type
	last_type = type
	current_num_sections = num_section
	placing_tent = true
	print("Placing new ", type)

func _process(_delta):
	if placing_tent and current_tent:
		var pos = get_global_mouse_position() ###
		pos.x = round(pos.x / snap_size) * snap_size
		pos.y = round(pos.y / snap_size) * snap_size
		current_tent.global_position = pos
		
func _input(event):
	if placing_tent and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			confirm()
	if placing_tent and Input.is_action_just_pressed("reset"):
		cancel_placement()

func confirm():
	if not menu_collapsed:
		return
	if not current_tent:
		return
		
	# Prevents placement if overlapping with another tent
	if tents_data:
		for tent_type in tents_data:
			for tent in tents_data[tent_type]:
				var tent_pos = tents_data[tent_type][tent]["position"]
				var tent_size = tents_data[tent_type][tent]["size"]
				if Rect2(tent_pos, tent_size).intersects(Rect2(current_tent.global_position, current_tent["size"])):
					print("Unable to place: %s is in the way" % tent)
					return
			
	current_tent.modulate = Color(1, 1, 1, 1)
	var pos = current_tent.global_position
	var snap = snap_size
	pos.x = round(pos.x / snap) * snap
	pos.y = round(pos.y / snap) * snap
	current_tent.global_position = pos

	tents_data[current_type][current_tent.name] = {
		"position": pos,
		"size": current_tent.size
	}
	current_tent.disabled = false
	current_tent = null
	current_type = ""
	placing_tent = false

	new_tent(last_type, current_num_sections)
	emit_signal("send_tents_data", tents_data)

func cancel_placement():
	if current_tent:
		current_tent.queue_free()
	current_tent = null
	current_type = ""
	placing_tent = false



func move_tent(tent):
	if not tent:
		return
	var pos = get_global_mouse_position()
	pos.x = round(pos.x / snap_size) * snap_size
	pos.y = round(pos.y / snap_size) * snap_size
	tent["position"] = pos
