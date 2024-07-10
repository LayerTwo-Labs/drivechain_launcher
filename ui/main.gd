class_name Main extends VBoxContainer
@onready var tab_container: TabContainer = $Background/Content/TabContainer
@onready var menu: PanelContainer = $Menu
@onready var settings_tab: ScrollContainer = $Background/Content/TabContainer/Settings
enum Tabs {WALLET, NODES, TOOLS, FAST_WITHDRAW, SETTINGS}

func _ready():
	settings_tab.hide_settings.connect(self._on_hide_settings)
	get_tree().root.title += " | " + Appstate.app_config.get_value("", "version")
	for i in range(tab_container.get_tab_count()):
		tab_container.set_tab_hidden(i, false)

func _on_menu_button_pressed(v: int):
	if v == 1:  # Assuming 1 is for settings
		tab_container.current_tab = Tabs.SETTINGS
	else:
		tab_container.current_tab = Tabs.NODES  # Default to Nodes tab
	menu.settings_shown = v

func _on_hide_settings():
	tab_container.current_tab = Tabs.NODES
	menu.settings_shown = 0

func _on_create_wallet_button_pressed() -> void:
	if tab_container.current_tab == Tabs.WALLET:
		tab_container.current_tab = Tabs.NODES
	else:
		tab_container.current_tab = Tabs.WALLET

# Function to switch to a specific tab
func switch_to_tab(tab: int):
	if tab >= 0 and tab < tab_container.get_tab_count():
		tab_container.current_tab = tab
