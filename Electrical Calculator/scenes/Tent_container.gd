class_name Tents
extends Control

var tents_data = {
	"hqss": {},
	"mod": {}
}

var placing_tent: bool = false
var current_tent: Control = null
var current_type: String = ""
var snap_size := 10.0
var menu_collapsed = false

var hqss = {
	"name": "HQSS",
	"size": Vector2(100, 90)
}
var mod = {
	"name": "Mod Tent",
	"size": Vector2(110, 70)
}

func set_snap_size(size: float):
	snap_size = size

func set_menu_collapsed(b: bool):
	menu_collapsed = b
	
func new(type: String):
	if placing_tent:
		current_tent.queue_free()

	var tent = Button.new()
	tent.text = type.capitalize()
	tent.size = hqss["size"] if type == "hqss" else mod["size"]
	tent.disabled = true  # prevent click during placement
	tent.name = type + "_" + str(tents_data[type].size())

	add_child(tent)
	current_tent = tent
	current_type = type
	placing_tent = true
	print("Placing new ", type)

func _process(delta):
	if placing_tent and current_tent:
		var pos = get_global_mouse_position()
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

	var pos = current_tent.global_position
	var snap = snap_size
	pos.x = round(pos.x / snap) * snap
	pos.y = round(pos.y / snap) * snap
	current_tent.global_position = pos

	tents_data[current_type][current_tent.name] = {
		"position": pos,
		"size": current_tent.size
	}
	#print("Tent placed:", tents_data[current_type][current_tent.name])
	current_tent.disabled = false
	current_tent = null
	current_type = ""
	placing_tent = false


func cancel_placement():
	if current_tent:
		current_tent.queue_free()
	current_tent = null
	current_type = ""
	placing_tent = false
