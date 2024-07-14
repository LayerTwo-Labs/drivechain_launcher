class_name NodePanel extends Control

const HEADER_PANEL_STYLE_BOX = preload("res://resource/style_box/nodes/header_panel_style.stylebox")

@export var header: bool = false
@export var heading: String = "NodePanel"
@export var description: String = "Description"
@export var disabled: bool = false
@export_range(0.0, 1.0) var disabled_color_value = 0.85

@onready var download_button: Button = $MarginContainer/Container/Header/Download
@onready var heading_label: Label = $MarginContainer/Container/Header/Heading
@onready var description_label: Label = $MarginContainer/Container/Description
@onready var shimmer_effect: TextureRect = $ShimmerEffect
@onready var panel: Panel = $MarginContainer/Panel

func _ready():
	if header:
		shimmer_effect.show()
		panel.set("theme_override_styles/panel", HEADER_PANEL_STYLE_BOX)
		download_button.start_shimmer()
	heading_label.text = heading
	description_label.text = description
	download_button.pressed.connect(_on_download_button_pressed)
	if disabled:
		download_button.disabled = true
		heading_label.self_modulate.v = disabled_color_value
		description_label.self_modulate.v = disabled_color_value

func _on_download_button_pressed():
	pass
