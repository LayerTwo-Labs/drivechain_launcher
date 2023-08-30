extends ScrollContainer

@onready var app_dir = $VBox/AppDataDir/Value
@onready var sidechains_dir = $VBox/SidechainsDataDir/Value
@onready var drivechain_dir = $VBox/DrivechainDataDir/Value

func _ready():
	app_dir.placeholder_text = ProjectSettings.globalize_path(OS.get_user_data_dir())
	sidechains_dir.placeholder_text = ProjectSettings.globalize_path(OS.get_user_data_dir() + "/sidechains")
	drivechain_dir.placeholder_text = ProjectSettings.globalize_path(Appstate.get_drivechain_dir())
	
	
func _on_reset_button_pressed():
	Appstate.reset_everything()
	
	
func _on_app_data_open_pressed():
	OS.shell_open(ProjectSettings.globalize_path(OS.get_user_data_dir()))
	
	
func _on_sidechain_data_open_pressed():
	OS.shell_open(ProjectSettings.globalize_path(OS.get_user_data_dir() + "/sidechains"))
	
	
func _on_drivechain_data_open_pressed():
	OS.shell_open(ProjectSettings.globalize_path(Appstate.get_drivechain_dir()))
	
	
