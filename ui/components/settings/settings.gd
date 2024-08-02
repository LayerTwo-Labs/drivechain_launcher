extends MarginContainer

@onready var app_dir = $Window/Container/DataDirectories/Options/Inputs/ApplicationDataDirectory
@onready var drivechain_dir = $Window/Container/DataDirectories/Options/Inputs/DriveChainDataDirectory
@onready var scale_spin = $VBox/AppSettings/HBox/ScaleSpin
@onready var app_dir_buttton: Button = $Window/Container/DataDirectories/Options/BrowseButtons/ApplicationDataDirectory
@onready var drivechain_dir_button: Button = $Window/Container/DataDirectories/Options/BrowseButtons/DriveChainDataDirectory
@onready var reset_button: Button = $Window/Reset
@onready var reset_everything_scene = preload("res://ui/components/settings/reset_everything_window.tscn")

const CUSTOM_FONT_PATH = "res://assets/fonts/Cantarell-Bold.ttf"

signal hide_settings

var base_size: Vector2 
var reset_popup: Control = null
var default_resolution: Vector2

func _ready():
	var user_data_dir : String = ProjectSettings.globalize_path(OS.get_user_data_dir())
	var user_drivechain_dir : String = ProjectSettings.globalize_path(Appstate.get_drivechain_dir())
	if Appstate.get_platform() == Appstate.platform.WIN:
		app_dir.placeholder_text		= "\\".join(user_data_dir.split("/"))
		drivechain_dir.placeholder_text = "\\".join(user_drivechain_dir.split("/"))
	else:
		app_dir.placeholder_text		= user_data_dir
		drivechain_dir.placeholder_text = user_drivechain_dir
	app_dir_buttton.connect("pressed",Callable(self, "_on_app_data_open_pressed"))
	drivechain_dir_button.connect("pressed",Callable(self, "_on_drivechain_data_open_pressed"))
	reset_button.connect("pressed", Callable(self, "_on_reset_button_pressed"))
	apply_custom_font()
	
	# Set the default resolution based on the operating system
	default_resolution = get_default_resolution()
	# You can use default_resolution elsewhere in your project as needed

func get_default_resolution() -> Vector2:
	match Appstate.get_platform():
		Appstate.platform.MAC:
			return Vector2(1920, 1080)
		Appstate.platform.WIN:
			return Vector2(1024, 576)
		Appstate.platform.LINUX:
			return Vector2(1280, 720)
		_:
			# Default fallback resolution
			return Vector2(1280, 720)

func apply_custom_font():
	var custom_font = load(CUSTOM_FONT_PATH)
	if custom_font:
		apply_font_recursive(self, custom_font)

func apply_font_recursive(node: Node, font: Font):
	if node is Label or node is Button or node is LineEdit or node is TextEdit:
		node.add_theme_font_override("font", font)
	for child in node.get_children():
		apply_font_recursive(child, font)

func _on_reset_button_pressed() -> void:
	if reset_popup != null:
		_center_reset_popup()
		reset_popup.show()
		return
	
	reset_popup = Control.new()
	reset_popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.5) 
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.connect("gui_input", Callable(self, "_on_background_gui_input"))
	reset_popup.add_child(background)
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 200)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -200)
	panel.set_anchor_and_offset(SIDE_TOP, 0.5, -100)
	panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 200)
	panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 100)
	reset_popup.add_child(panel)
	
	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color.WHITE
	stylebox.bg_color = Color(0.15, 0.15, 0.15) 
	panel.add_theme_stylebox_override("panel", stylebox)
	
	var reset_content = reset_everything_scene.instantiate()
	reset_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	panel.add_child(reset_content)
	
	for child in reset_content.get_children():
		if child is Button:
			child.connect("pressed", Callable(self, "_on_reset_popup_close_pressed"))
	
	get_tree().root.add_child(reset_popup)
	
	get_tree().root.connect("size_changed", Callable(self, "_center_reset_popup"))
	
	reset_popup.show()

func _center_reset_popup() -> void:
	if reset_popup != null:
		var panel = reset_popup.get_node("Panel")
		if panel != null:
			var viewport_size = get_viewport().size
			panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -panel.custom_minimum_size.x / 2)
			panel.set_anchor_and_offset(SIDE_TOP, 0.5, -panel.custom_minimum_size.y / 2)
			panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, panel.custom_minimum_size.x / 2)
			panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, panel.custom_minimum_size.y / 2)

func _on_background_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_reset_popup_close_pressed()

func _on_reset_popup_close_pressed() -> void:
	if reset_popup != null:
		reset_popup.queue_free()
		reset_popup = null
		get_tree().root.disconnect("size_changed", Callable(self, "_center_reset_popup"))

func _on_app_data_open_pressed():
	open_file(OS.get_user_data_dir())

func _on_drivechain_data_open_pressed():
	open_file(Appstate.get_drivechain_dir())

func open_file(value: String):
	var globalized = ProjectSettings.globalize_path(value)
	if Appstate.get_platform() == Appstate.platform.MAC:
		globalized = "file://" + globalized
	OS.shell_open(globalized)

func _on_hide_button_pressed():
	hide_settings.emit(0)
