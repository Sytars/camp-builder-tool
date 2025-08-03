extends Control

@onready var answer_label = $HBoxContainer/MarginContainer/MarginContainer/AnswerLabel
@onready var line_edits := {
	"a": $HBoxContainer/VBoxContainer/InputBoxes/A/LineEdit,
	"b": $HBoxContainer/VBoxContainer/InputBoxes/B/LineEdit,
	"c": $HBoxContainer/VBoxContainer/InputBoxes/C/LineEdit
}
var values = {
	"a": 0.0,
	"b": 0.0,
	"c": 0.0
}
var targets := []


func _ready():
	calculate()


func _process(delta):
	if not visible:
		return
		
	if Input.is_action_pressed("reset"):
		reset_values()
	elif Input.is_action_pressed("enter"):
		calculate()



# Method to gather data for saving
func _get_save_data() -> Dictionary:
	var data_to_save = {}
	
	# 1. Save the 'values' dictionary
	data_to_save["values"] = values.duplicate(true) # Use duplicate(true) for deep copy
	
	# 2. Save the text content of all LineEdits
	var line_edit_texts = {}
	for key in line_edits:
		line_edit_texts[key] = line_edits[key].text
	data_to_save["line_edit_texts"] = line_edit_texts
	
	# 3. Save the text content of the answer_label
	data_to_save["answer_label_text"] = answer_label.text
	
	return data_to_save


# Method to apply loaded data
func _apply_load_data(loaded_data: Dictionary):
	
	# 1. Restore the 'values' dictionary
	if loaded_data.has("values"):
		values = loaded_data["values"].duplicate(true) # Ensure it's a deep copy
	
	# 2. Restore the text content of all LineEdits
	if loaded_data.has("line_edit_texts"):
		var line_edit_texts = loaded_data["line_edit_texts"]
		for key in line_edit_texts:
			if line_edits.has(key) and is_instance_valid(line_edits[key]):
				line_edits[key].text = line_edit_texts[key]
	
	# 3. Restore the text content of the answer_label
	if loaded_data.has("answer_label_text"):
		answer_label.text = loaded_data["answer_label_text"]
	
	update_label()


# Finds missing values using Ohm's Law
func calculate():
	targets = get_values_to_find()
	
	# Cancels if less than 2 entries
	if len(targets) > 1:
		answer_label.text = "Input at least 2 elements"
		return
	
	# Cancels if not all inputs are floats
	var inv = valid_inputs()
	if inv:
		answer_label.text = str(inv) + " have invalid inputs"
		return
	
	#print(targets)
	for target in targets:
		calculate_value(target)
	
	update_label()


func update_label():
	var answer = ""
	for value in values:
		answer += value + ": " + format_number(values[value]) + "\n"
	answer_label.text = answer

# For development, to allow simulating inputs directly in values
func set_default_values():
	for value in values:
		line_edits[value].text = str(values[value])

# Removes trailling 0s after decimal point, rounds to 2 decimal points
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


func calculate_value(target_val):
	var have = valid_values()
	if "a" in have and "b" in have:
		values["c"] = sqrt(values["a"]**2 + values["b"]**2)
	elif "a" in have and "c" in have:
		values["b"] = sqrt(values["c"]**2 - values["a"]**2)
	elif "c" in have and "b" in have:
		values["a"] = sqrt(values["c"]**2 - values["b"]**2)



func valid_values():
	var have := []
	for value in values:
		if float(values[value]) > 0:
			have.append(value)
	return have

# returns what needs to be calculated and assigns known values to values
func get_values_to_find():
	var finding = []
	
	for line in line_edits:
		if line_edits[line].text == "" or line_edits[line].text == str(0):
			finding.append(line)
		else:
			# Assign the text to its spot in values
			values[line] = float(line_edits[line].text)
	return finding

# Returns all input not containing a valid float
func valid_inputs():
	var invalid = []
	for value in line_edits:
		var val = line_edits[value].text
		if val.is_valid_float() or val == "":
			continue
		else:
			invalid.append(value)
	return invalid

# Sets all line edits text to nothing
func reset_values():
	for key in line_edits.keys():
		line_edits[key].text = ""
	for val in values:
		values[val] = 0
	answer_label.text = ""


func _on_calculate_missing_button_pressed():
	calculate()
