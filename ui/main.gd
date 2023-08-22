extends CanvasLayer

@onready var tab_container = $HBox/Content/TabContainer
@onready var left_menu = $HBox/LeftMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	set_initial_scale()
	left_menu.left_menu_button_pressed.connect(self._on_left_menu_button_pressed)
	
	
func set_initial_scale():
	var dpi = DisplayServer.screen_get_dpi()
	var scale_factor: float = clampf(floorf(dpi * 0.01), 1, 2)
	var screen_size = DisplayServer.screen_get_size(0)
	var new_screen_size = Vector2i(screen_size.x / 2, screen_size.y / 2)
	DisplayServer.window_set_size(new_screen_size)
	get_tree().root.set_content_scale_factor(scale_factor)
	
	
func _on_left_menu_button_pressed(v: int):
	tab_container.current_tab = v
