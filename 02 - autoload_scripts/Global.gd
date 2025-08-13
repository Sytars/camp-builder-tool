# Global.gd - singleton
extends Node

@onready var pixels_per_meter = 15 # master object scalor
@onready var last_selection_content: Array


const OBJECT_TEMPLATE = {
	"tent": {
		"color": Color(0.15, 0.6, 0.15),
		"hqss": {
			"size": Vector2(6.0, 2.8),
			"elec_inputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 60,
					"quantity": 1
				}
			],
			"elec_outputs": []
		},
		"mod": {
			"size": Vector2(6.8, 2.4),
			"elec_inputs": [
				{
					"connector": "Receptacle",
					"phase": "1PH",
					"voltage": "120",
					"amperage": 15,
					"quantity": 1
				}
			],
			"elec_outputs": []
		}
	},
	"generator": {
		"color": Color(0.45, 0.0, 0.8),
		"30kw": {
			"size": Vector2(3.0, 2.0),
			"elec_inputs": [],
			"elec_outputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 1
				}
			],
			"fuel_type": "diesel",
			"fuel_consumption_rate": 8.5 # L/h at 80% load - example value
		},
		"60kw": {
			"size": Vector2(3.0, 2.0),
			"elec_inputs": [],
			"elec_outputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 1
				}
			],
			"fuel_type": "diesel",
			"fuel_consumption_rate": 15.0 # L/h at 80% load - example value
		}
	},
	"distribution box": {
		"color": Color(0.902, 0.835, 0.722),
		"lex200": {
			"size": Vector2(1.5, 1.2),
			"elec_inputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 100,
					"quantity": 2
				}
			],
			"elec_outputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 60,
					"quantity": 10
				},
				{
					"connector": "Receptacle",
					"phase": "1PH",
					"voltage": "120",
					"amperage": 15,
					"quantity": 1
				}
			]
		},
		"lex800": {
			"size": Vector2(1.5, 1.2),
			"elec_inputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 2
				}
			],
			"elec_outputs": [
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 60,
					"quantity": 10
				},
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 100,
					"quantity": 4
				},
				{
					"connector": "Receptacle",
					"phase": "1PH",
					"voltage": "120",
					"amperage": 15,
					"quantity": 1
				}
			]
		},
		"lex1200": {
			"size": Vector2(1.8, 1.5),
			"elec_inputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 3
				}
			],
			"elec_outputs": [
				{
					"connector": "CamLok",
					"phase": "3PH",
					"voltage": "120",
					"amperage": 400,
					"quantity": 3
				},
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 100,
					"quantity": 2
				},
				{
					"connector": "PinSleeve",
					"phase": "3PH",
					"voltage": "120/208",
					"amperage": 60,
					"quantity": 2
				}
			]
		}
	}
}

const MIN_DISTANCES = {
	"generator": {
		"generator": 5.0,
		"tent": 10.0
	},
	"tent": {
		"tent": 2.0,
		"generator": 10.0
	}
}

const GEN_EFFICIENCY_FACTOR := 0.8 # Generators are most efficient at 80% load
const WORST_CASE_TIME_HOURS := 24.0 # Timeframe for worst-case fuel consumption calculation

# --- Screen & UI Logic ---
var default_res = Vector2(1440, 900)
var resolution: Vector2

func set_resolution(res: Vector2):
	print("Resolution set to ", str(res.x), " by ", str(res.y), ".")
	DisplayServer.window_set_size(res)
	var size = DisplayServer.screen_get_size()
	var new_x = (size.x - res.x) / 2
	var new_y = (size.y - res.y) / 2
	DisplayServer.window_set_position(Vector2(new_x, new_y))
	resolution = res

func _get_save_data() -> Dictionary:
	var data_to_save = {}
	data_to_save["resolution"] = resolution
	return data_to_save

func _apply_load_data(loaded_data: Dictionary):
	if loaded_data.has("resolution"):
		var str_res = loaded_data["resolution"]
		var res_x: String = ""
		var res_y: String = ""
		var is_x = true
		var res: Vector2
		
		for character in str_res:
			if character == "(" or character == ")" or character == " ":
				continue
			if character == ",":
				is_x = false
				continue
			if not character.is_valid_int():
				print("invalid save format for resolution")
				return
			if is_x:
				res_x += character
			else:
				res_y += character
		
		res.x = int(res_x)
		res.y = int(res_y)
		
		if res == Vector2(0, 0):
			res = default_res
			
		set_resolution(res)


func format_number(number: float) -> String:
	# Format to two decimal places
	var formatted_string = "%.2f" % number

	# Remove trailing zeros if they are after the decimal point
	if "." in formatted_string:
		# If the string ends with ".00", remove ".00"
		if formatted_string.ends_with(".00"):
			return formatted_string.replace(".00", "")
		# If the string ends with a '0' that's not part of ".00" (e.g., "12.30"), remove it
		elif formatted_string.ends_with("0"):
			return formatted_string.trim_suffix("0")
	return formatted_string



func to_m(distance_px: Vector2) -> Vector2:
	return distance_px / pixels_per_meter

func to_px(distance_m: Vector2) -> Vector2:
	return distance_m * pixels_per_meter
