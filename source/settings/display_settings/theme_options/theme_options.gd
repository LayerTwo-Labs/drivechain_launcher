class_name ThemeOptions extends HBoxContainer

const theme_directory = "res://resource/theme/"
const unchecked_icon = preload("res://assets/icons/CheckButton/CheckButton_Unchecked.svg")
const checked_icon = preload("res://assets/icons/CheckButton/CheckButton_Checked.svg")

@onready var options: GridContainer = $Options
var active_option: Button

func _ready():
	for option: Button in options.get_children():
		if option.name.to_lower() == "blue":
			_disable_blue_option(option)
		else:
			option.toggled.connect(_on_option_toggled.bind(option))
			option.icon = unchecked_icon
			if option.button_pressed:
				active_option = option
				option.icon = checked_icon

func _disable_blue_option(option: Button):
	option.disabled = true
	option.modulate = Color(1, 1, 1, 0.5)  # This greys out the button
	option.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	option.tooltip_text = "Blue theme is not currently supported"

func _on_option_toggled(toggled_on: bool, option: Button):
	if option.name.to_lower() != "blue":
		var application = get_tree().get_first_node_in_group("application")
		application.set("theme", load(theme_directory + option.name.to_lower() + ".theme"))
		active_option.icon = unchecked_icon
		active_option = option
		active_option.icon = checked_icon
