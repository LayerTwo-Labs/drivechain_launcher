extends ScrollContainer

@onready var app_dir = $VBox/DirectoriesSettings/AppDataDir/Value
@onready var drivechain_dir = $VBox/DirectoriesSettings/DrivechainDataDir/Value
@onready var scale_spin = $VBox/AppSettings/HBox/ScaleSpin
@onready var reset_everything_scene = preload("res://ui/components/settings/reset_everything_window.tscn")

signal hide_settings

var base_size: Vector2 
var reset_popup: Control = null

func _ready():
	var user_data_dir : String = ProjectSettings.globalize_path(OS.get_user_data_dir())
	var user_drivechain_dir : String = ProjectSettings.globalize_path(Appstate.get_drivechain_dir())
	if Appstate.get_platform() == Appstate.platform.WIN:
		app_dir.placeholder_text        = "\\".join(user_data_dir.split("/"))
		drivechain_dir.placeholder_text = "\\".join(user_drivechain_dir.split("/"))
	else:
		app_dir.placeholder_text        = user_data_dir
		drivechain_dir.placeholder_text = user_drivechain_dir
	var scale_factor = get_tree().root.get_content_scale_factor()
	scale_spin.value = scale_factor
	base_size = get_window().size

func _on_reset_button_pressed() -> void:
	if reset_popup != null:
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
	var viewport_size = Vector2(get_viewport().size)
	panel.position = (viewport_size - panel.custom_minimum_size) / 2
	
	reset_popup.show()

func _on_background_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_reset_popup_close_pressed()

func _on_reset_popup_close_pressed() -> void:
	if reset_popup != null:
		reset_popup.queue_free()
		reset_popup = null
		print("Reset popup closed")

func _on_app_data_open_pressed():
	open_file(OS.get_user_data_dir())

func _on_drivechain_data_open_pressed():
	open_file(Appstate.get_drivechain_dir())

func open_file(value: String):
	var globalized = ProjectSettings.globalize_path(value)
	if Appstate.get_platform() == Appstate.platform.MAC:
		globalized = "file://" + globalized
	OS.shell_open(globalized)
	
func _on_scale_spin_value_changed(value):
	var new_size = base_size * value
	var min_size = Vector2(800, 600)
	var max_size = Vector2(3840, 2160)
	new_size.x = clamp(new_size.x, min_size.x, max_size.x)
	new_size.y = clamp(new_size.y, min_size.y, max_size.y)
	get_window().size = new_size
	Appstate.update_display_scale(value)

func _on_hide_button_pressed():
	hide_settings.emit(0)
