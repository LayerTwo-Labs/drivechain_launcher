class_name ThemeOptions extends HBoxContainer

const theme_directory = "res://resource/theme/"
@onready var options: GridContainer = $Options

func _ready():
	for option: Button in options.get_children():
		option.toggled.connect(_on_option_toggled.bind(option))

func _on_option_toggled(toggled_on: bool, option: Button):
	var application = get_tree().get_first_node_in_group("application")
	application.set("theme", load(theme_directory + option.name.to_lower() + ".theme"))
