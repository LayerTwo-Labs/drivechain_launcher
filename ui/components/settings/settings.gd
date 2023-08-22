extends ScrollContainer

@onready var app_dir = $VBox/AppDataDir/Value
@onready var sidechains_dir = $VBox/SidechainsDataDir/Value
@onready var drivechain_dir = $VBox/DrivechainDataDir/Value

# Called when the node enters the scene tree for the first time.
func _ready():
	app_dir.placeholder_text = ProjectSettings.globalize_path(OS.get_user_data_dir())
	sidechains_dir.placeholder_text = ProjectSettings.globalize_path(OS.get_user_data_dir() + "/sidechains")
	drivechain_dir.placeholder_text = ProjectSettings.globalize_path(Appstate.get_home() + "/.drivechain")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_reset_button_pressed():
	Appstate.reset_everything()
