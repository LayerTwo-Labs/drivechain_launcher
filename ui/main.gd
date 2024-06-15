class_name Main extends VBoxContainer

@onready var tab_container: TabContainer   = $Content/TabContainer
@onready var left_menu: PanelContainer     = $LeftMenu
@onready var settings_tab: ScrollContainer = $Content/TabContainer/Settings


# Called when the node enters the scene tree for the first time.
func _ready():
	left_menu.left_menu_button_pressed.connect(self._on_left_menu_button_pressed)
	settings_tab.hide_settings.connect(self._on_left_menu_button_pressed)
	
	get_tree().root.title += " | " + Appstate.app_config.get_value("", "version")

func _on_left_menu_button_pressed(v: int):
	tab_container.current_tab = v
	if v == 0: left_menu.settings_shown = 0
