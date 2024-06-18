extends HBoxContainer


@onready var toggle: CheckButton = $Toggle

func _ready():
	toggle.toggled.connect(_on_toggled)

func _on_toggled(toggled_on: bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
