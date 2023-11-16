extends ScrollContainer

@onready var app_dir = $VBox/DirectoriesSettings/AppDataDir/Value
@onready var drivechain_dir = $VBox/DirectoriesSettings/DrivechainDataDir/Value
@onready var scale_spin = $VBox/AppSettings/HBox/ScaleSpin


func _ready():
	app_dir.placeholder_text = ProjectSettings.globalize_path(OS.get_user_data_dir())
	drivechain_dir.placeholder_text = ProjectSettings.globalize_path(Appstate.get_drivechain_dir())
	var scale_factor = get_tree().root.get_content_scale_factor()
	scale_spin.value = scale_factor


func _on_reset_button_pressed():
	Appstate.reset_everything()


func _on_app_data_open_pressed():
	open_file(OS.get_user_data_dir())


func _on_drivechain_data_open_pressed():
	open_file(Appstate.get_drivechain_dir())


func open_file(value: String):
	var globalized = ProjectSettings.globalize_path(value)

	# macOS expects file paths to start with file://. Without
	# this, shell_open tries to execute the path as a program.
	if Appstate.get_platform() == Appstate.platform.MAC:
		globalized = "file://" + globalized

	OS.shell_open(globalized)


func _on_scale_spin_value_changed(value):
	Appstate.update_display_scale(value)
