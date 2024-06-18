extends HBoxContainer

@onready var screen_mode: ScreenMode = $ScreenMode
@onready var screen_resolution: HBoxContainer = $ScreenResolution

func _ready():
	screen_mode.screen_mode_updated.connect(screen_resolution._on_screen_mode_updated)
