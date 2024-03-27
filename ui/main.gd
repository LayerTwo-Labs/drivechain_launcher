extends CanvasLayer

@onready var tab_container = $VBox/Content/TabContainer
@onready var left_menu     = $VBox/LeftMenu
@onready var settings_tab  = $VBox/Content/TabContainer/Settings


# Called when the node enters the scene tree for the first time.
func _ready():
	left_menu.left_menu_button_pressed.connect(self._on_left_menu_button_pressed)
	settings_tab.hide_settings.connect(self._on_left_menu_button_pressed)
	

func _on_left_menu_button_pressed(v: int):
	tab_container.current_tab = v
	if v == 0: left_menu.settings_shown = 0
