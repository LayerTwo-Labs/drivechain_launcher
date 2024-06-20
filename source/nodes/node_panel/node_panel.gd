class_name NodePanel extends MarginContainer

@export var heading: String = "NodePanel"
@export var description: String = "Description"
@export var disabled: bool = false
@export_range(0.0, 1.0) var disabled_color_value = 0.85

@onready var download_button: Button = $Container/Header/Download
@onready var heading_label: Label = $Container/Header/Heading
@onready var description_label: Label = $Container/Description

func _ready():
	heading_label.text = heading
	description_label.text = description
	download_button.pressed.connect(_on_download_button_pressed)
	if disabled:
		download_button.hide()
		heading_label.self_modulate.v = disabled_color_value
		description_label.self_modulate.v = disabled_color_value

func _on_download_button_pressed():
	var animation_player: AnimationPlayer = download_button.get_node("AnimationPlayer")
	if animation_player.current_animation == "download":
		animation_player.play("downloading")
		await get_tree().create_timer(5).timeout
		animation_player.play("run")
	elif animation_player.current_animation == "run":
		animation_player.play("running")
	elif animation_player.current_animation == "running":
		animation_player.play("run")
