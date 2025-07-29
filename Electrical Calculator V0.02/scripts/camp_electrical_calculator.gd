extends Control

@onready var items = []
@onready var v_box_container = $"Col Separator/Left Column/VBoxContainer"


func add_new_item():
	# Define placeholder text for each LineEdit
	var box_names = ["Item name", "KW", "Number of item"]
	var line = []
	# Define the stretch ratios corresponding to the box_names
	var stretch_ratios = [5, 65, 15, 15]
	
	# Create a new hbox container for this line
	var item_container = HBoxContainer.new()
	item_container.name = ("Item_" + str(len(items)))
	line.append(item_container)
	v_box_container.add_child(item_container)
	
	# Create a delete line button inside the new HBoxContainer
	var del_line_button = Button.new()
	del_line_button.name = "Delete_Line_Button"
	del_line_button.text = " X "
	var button_theme = load("res://themes/ButtonsTheme.tres")
	if button_theme != null:
		del_line_button.theme = button_theme
	else:
		print('Could not load theme from "res://themes/ButtonsTheme.tres"')
	del_line_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL # Enable horizontal stretching
	del_line_button.size_flags_stretch_ratio = stretch_ratios[0]
	line.append(del_line_button)
	item_container.add_child(del_line_button)
	
	# Connect the button's 'pressed' signal
	del_line_button.pressed.connect(Callable(self, "_on_delete_line_button_pressed").bind(item_container))
	
	# Create 3 LineEdit nodes inside the new HBoxContainer
	for i in range(box_names.size()):
		var box = LineEdit.new()
		box.name = box_names[i] # Set the node's name (optional, but good for debugging in remote scene tree)
		box.placeholder_text = box_names[i] # Set the placeholder text
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL # Enable horizontal stretching
		box.size_flags_stretch_ratio = stretch_ratios[i+1] # Set the stretch ratio
		line.append(box) # Add the LineEdit to the current line's node array
		item_container.add_child(box) # Add the LineEdit as a child of the HBoxContainer
		box.text_changed.connect(Callable(self, "_on_line_edited").bind(box))
		box.text_submitted.connect(Callable(self, "_on_line_edited").bind(box))
	items.append(line)



func _on_line_edited(line: LineEdit):
	print(line.text)


func _on_delete_line_button_pressed(container_to_delete: HBoxContainer):
	container_to_delete.queue_free()

	for i in range(items.size()):
		if items[i][0] == container_to_delete: # items[i][0] is the HBoxContainer
			items.remove_at(i)
			break

func _on_add_item_button_pressed():
	add_new_item()
