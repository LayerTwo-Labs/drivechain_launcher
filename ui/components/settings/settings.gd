extends ScrollContainer

@onready var app_dir = $VBox/DirectoriesSettings/AppDataDir/Value
@onready var drivechain_dir = $VBox/DirectoriesSettings/DrivechainDataDir/Value
@onready var scale_spin = $VBox/AppSettings/HBox/ScaleSpin

signal hide_settings

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


func _on_reset_button_pressed():
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to reset everything?"
	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()
	confirmation_dialog.connect("confirmed", Callable(self, "_on_confirmation_confirmed"))


# This method is called when the confirmation dialog is confirmed
func _on_confirmation_confirmed():
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


func _on_hide_button_pressed():
	hide_settings.emit(0)
