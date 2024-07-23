extends HBoxContainer

@onready var resolution_list_button: OptionButton = $List

func _ready():
	resolution_list_button.item_selected.connect(_on_resolution_selected)
	set_default_resolution()

func set_default_resolution():
	if resolution_list_button.get_item_count() > 6:  # Ensure there are at least 6 items
		apply_resolution(6)  # Apply the 6th resolution in the list (index 5)
		resolution_list_button.select(6)  # Select the 6th item in the OptionButton

func _on_resolution_selected(index: int):
	var resolution = apply_resolution(index)
	reposition_window_to_screen_center(resolution)

func apply_resolution(index):
	var resolution_text = resolution_list_button.get_item_text(index).split(" x ")
	var resolution = Vector2i.ZERO
	resolution.x = int(resolution_text[0])
	resolution.y = int(resolution_text[1])
	DisplayServer.window_set_size(resolution)
	return resolution

func reposition_window_to_screen_center(resolution):
	var window_position = DisplayServer.screen_get_size() / 2 - resolution / 2
	DisplayServer.window_set_position(window_position)

func refresh_window():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	await get_tree().process_frame
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_screen_mode_updated(fullscreen: bool):
	resolution_list_button.disabled = fullscreen
