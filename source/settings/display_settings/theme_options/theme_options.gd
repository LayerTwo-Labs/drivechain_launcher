class_name ThemeOptions extends HBoxContainer

const theme_directory = "res://resource/theme/"
const unchecked_icon = preload("res://assets/icons/CheckButton/CheckButton_UnChecked.png")
const checked_icon = preload("res://assets/icons/CheckButton/CheckButton_Checked.png")

@onready var options: GridContainer = $Options

var active_option: Button

func _ready():
	active_option = options.get_node("Blue")
	for option: Button in options.get_children():
		option.toggled.connect(_on_option_toggled.bind(option))

func _on_option_toggled(toggled_on: bool, option: Button):
	var application = get_tree().get_first_node_in_group("application")
	application.set("theme", load(theme_directory + option.name.to_lower() + ".theme"))
	active_option.icon = unchecked_icon
	active_option = option
	active_option.icon = checked_icon
