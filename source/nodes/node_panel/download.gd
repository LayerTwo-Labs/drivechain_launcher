class_name DownloadButton extends Button

signal action_requested(action)

const DOWNLOAD_ICON = preload("res://assets/images/download-cloud-svgrepo.svg")
const RUN_ICON = preload("res://assets/images/play-svgrepo-com.svg")
const STOP_ICON = preload("res://assets/images/stop-circle-svgrepo-com.svg")
const CUSTOM_FONT = preload("res://assets/fonts/Cantarell-Regular.ttf")

enum STATE { NOT_DOWNLOADED, DOWNLOADING, NOT_RUNNING, RUNNING }

var current_state = STATE.NOT_DOWNLOADED

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var icon_box: TextureRect = $MarginContainer/HBoxContainer/IconBox
@onready var background_color: Panel = $BackgroundColor
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready():
	pressed.connect(_on_pressed)
	
	# Set the custom font for the label
	var font_variation = FontVariation.new()
	font_variation.set_base_font(CUSTOM_FONT)
	label.add_theme_font_override("font", font_variation)

func set_state(new_state: STATE):
	current_state = new_state
	match current_state:
		STATE.NOT_DOWNLOADED:
			label.text = "DOWNLOAD"
			icon_box.texture = DOWNLOAD_ICON
			background_color.self_modulate = Color.DARK_ORANGE
			disabled = false
		STATE.DOWNLOADING:
			label.text = "DOWNLOADING"
			disabled = true
			background_color.hide()
			progress_bar.show()
		STATE.NOT_RUNNING:
			label.text = "RUN"
			icon_box.texture = RUN_ICON
			background_color.self_modulate = Color.DODGER_BLUE
			background_color.show()
			progress_bar.hide()
			disabled = false
		STATE.RUNNING:
			label.text = "RUNNING"
			icon_box.texture = STOP_ICON
			background_color.self_modulate = Color.FOREST_GREEN
			disabled = false
			
func update_enabled_state(is_drivechain: bool, drivechain_downloaded: bool):
	disabled = not (is_drivechain or drivechain_downloaded)

func _on_pressed():
	match current_state:
		STATE.NOT_DOWNLOADED:
			emit_signal("action_requested", "download")
		STATE.NOT_RUNNING:
			emit_signal("action_requested", "run")
		STATE.RUNNING:
			emit_signal("action_requested", "stop")
