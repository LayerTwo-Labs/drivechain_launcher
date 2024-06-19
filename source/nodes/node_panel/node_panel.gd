class_name NodePanel extends HBoxContainer

@export var heading: String = "NodePanel"
@export var description: String = "Description"

@onready var download_button: Button = $Download
@onready var heading_label: Label = $Heading
@onready var description_label: Label = $Description

func _ready():
	heading_label.text = heading
	description_label.text = description
	download_button.pressed.connect(_on_download_button_pressed)

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
	print(animation_player.current_animation)
