class_name ScreenMode extends HBoxContainer

@onready var toggle: CheckButton = $Toggle

signal screen_mode_updated

func _ready():
	toggle.toggled.connect(_on_toggled)

func _on_toggled(toggled_on: bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	screen_mode_updated.emit(toggled_on)
