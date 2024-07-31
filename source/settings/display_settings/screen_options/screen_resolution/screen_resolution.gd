extends HBoxContainer

@onready var resolution_list_button: OptionButton = $List

func _ready():
	resolution_list_button.item_selected.connect(_on_resolution_selected)
	populate_resolution_list()
	set_default_resolution()

func populate_resolution_list():
	resolution_list_button.clear()
	var fullscreen_resolution = get_fullscreen_resolution_text()
	resolution_list_button.add_item(fullscreen_resolution)
	
	var resolutions = ["1920 x 1080", "1600 x 900", "1366 x 768", "1280 x 720", "1024 x 576"]
	for res in resolutions:
		resolution_list_button.add_item(res)

func set_default_resolution():
	var default_resolution = "1920 x 1080"
	var index = resolution_list_button.get_item_index(1)  # 1920x1080 is the second item (index 1)
	
	apply_resolution(index)
	resolution_list_button.select(index)

func _on_resolution_selected(index: int):
	var resolution = apply_resolution(index)
	reposition_window_to_screen_center(resolution)

func apply_resolution(index):
	if index == 0:  # Full screen option
		return apply_fullscreen_resolution()
	else:
		var resolution_text = resolution_list_button.get_item_text(index).split(" x ")
		var resolution = Vector2i(int(resolution_text[0]), int(resolution_text[1]))
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolution)
		return resolution

func apply_fullscreen_resolution():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	return DisplayServer.screen_get_size()

func get_fullscreen_resolution_text():
	var screen_size = DisplayServer.screen_get_size()
	return str(screen_size.x) + " x " + str(screen_size.y) + " (Fullscreen)"

func reposition_window_to_screen_center(resolution):
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		var window_position = DisplayServer.screen_get_size() / 2 - resolution / 2
		DisplayServer.window_set_position(window_position)

func refresh_window():
	var current_mode = DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	await get_tree().process_frame
	DisplayServer.window_set_mode(current_mode)

func _on_screen_mode_updated(fullscreen: bool):
	resolution_list_button.disabled = fullscreen
