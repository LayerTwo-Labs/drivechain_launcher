class_name DownloadButton extends Button

const DOWNLOAD_ICON = preload("res://assets/images/download-cloud-line.svg")
const RUN_ICON = preload("res://assets/images/play-symbolic.svg")
const STOP_ICON = preload("res://assets/images/stop-symbolic.svg")

enum STATE { NOT_DOWNLOADED, DOWNLOADING, NOT_RUNNING, RUNNING }
var current_state = STATE.NOT_DOWNLOADED
var progress_tween: Tween
var should_shimmer: bool = false

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var icon_box: TextureRect = $MarginContainer/HBoxContainer/IconBox
@onready var background_color: Panel = $BackgroundColor
@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	pressed.connect(_on_pressed)
	timer.timeout.connect(_on_timer_timeout)

func start_shimmer():
	should_shimmer = true
	animation_player.play("shimmer")

func stop_shimmer():
	should_shimmer = false
	animation_player.stop()

func _on_pressed():
	if current_state == STATE.NOT_DOWNLOADED:
		current_state = STATE.DOWNLOADING
		label.text = "DOWNLOADING"
		disabled = true
		background_color.hide()
		progress_bar.show()
		progress_tween = create_tween()
		progress_tween.tween_property(progress_bar, "value", 100, timer.wait_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		timer.start()
		if should_shimmer:
			stop_shimmer()
	elif current_state == STATE.NOT_RUNNING:
		current_state = STATE.RUNNING
		label.text = "RUNNING"
		icon_box.texture = STOP_ICON
		background_color.self_modulate = Color.FOREST_GREEN
	elif current_state == STATE.RUNNING:
		current_state = STATE.NOT_RUNNING
		label.text = "RUN"
		icon_box.texture = RUN_ICON
		background_color.self_modulate = Color.DODGER_BLUE

func _on_timer_timeout():
	if current_state == STATE.DOWNLOADING:
		disabled = false
		current_state = STATE.NOT_RUNNING
		label.text = "RUN"
		icon_box.texture = RUN_ICON
		background_color.self_modulate = Color.DODGER_BLUE
		background_color.show()
		progress_bar.hide()
