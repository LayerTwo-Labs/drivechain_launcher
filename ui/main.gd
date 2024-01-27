extends CanvasLayer

@onready var tab_container = $VBox/Content/TabContainer
@onready var left_menu = $VBox/LeftMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	left_menu.left_menu_button_pressed.connect(self._on_left_menu_button_pressed)
	
	
func _on_left_menu_button_pressed(v: int):
	tab_container.current_tab = v
