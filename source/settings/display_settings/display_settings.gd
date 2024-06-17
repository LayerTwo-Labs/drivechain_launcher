class_name DisplaySettings extends VBoxContainer

@onready var fullscreen_toggle: CheckButton = $Options/Inputs/Fullscreen

func _ready():
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)

func _on_fullscreen_toggled(toggled_on: bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
