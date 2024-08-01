extends ColorRect

@onready var button1: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/Button
@onready var button2: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/Button2

var cooldown_time = 5.0
var button1_cooldown = 0.0
var button2_cooldown = 0.0

var normal_style: StyleBoxFlat
var cooldown_style: StyleBoxFlat
var button2_normal_style: StyleBoxFlat

func _ready():
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.2, 0.2)  # Dark grey
	
	cooldown_style = StyleBoxFlat.new()
	cooldown_style.bg_color = Color(0.5, 0.5, 0.5)  # Light grey
	
	button2_normal_style = StyleBoxFlat.new()
	button2_normal_style.bg_color = Color(0.8, 0.2, 0.2)  # Softer red
	
	# Increase button size
	var bigger_size = Vector2(200, 50)  # Adjust these values as needed
	
	if button1:
		button1.add_theme_stylebox_override("normal", normal_style.duplicate())
		button1.custom_minimum_size = bigger_size
	if button2:
		button2.add_theme_stylebox_override("normal", button2_normal_style.duplicate())
		button2.custom_minimum_size = bigger_size

	# Add some padding to the styles
	var padding = 10
	for style in [normal_style, cooldown_style, button2_normal_style]:
		style.content_margin_left = padding
		style.content_margin_right = padding
		style.content_margin_top = padding
		style.content_margin_bottom = padding

func _process(delta):
	if button1:
		if button1_cooldown > 0:
			button1_cooldown -= delta
			if button1_cooldown <= 0:
				button1.add_theme_stylebox_override("normal", normal_style.duplicate())
				button1.disabled = false
	
	if button2:
		if button2_cooldown > 0:
			button2_cooldown -= delta
			if button2_cooldown <= 0:
				button2.add_theme_stylebox_override("normal", button2_normal_style.duplicate())
				button2.disabled = false

func _on_center_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				queue_free()

func _on_button_pressed():
	if button1 and button1_cooldown <= 0:
		Appstate.reset_everything(true)
		button1.add_theme_stylebox_override("normal", cooldown_style.duplicate())
		button1.disabled = true
		button1_cooldown = cooldown_time

func _on_button_2_pressed():
	if button2 and button2_cooldown <= 0:
		Appstate.reset_everything(false)
		button2.add_theme_stylebox_override("normal", cooldown_style.duplicate())
		button2.disabled = true
		button2_cooldown = cooldown_time
