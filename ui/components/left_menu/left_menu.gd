extends PanelContainer

@onready var dashboard_button := $VBox/DashboardButton
@onready var playground_button := $VBox/PlaygroundButton
@onready var settings_button := $VBox/SettingsButton

signal left_menu_button_pressed(v: int)

func _on_left_menu_button_toggled(button_pressed, v):
	match v:
		0:
			if button_pressed:
				#playground_button.set_pressed_no_signal(false)
				settings_button.set_pressed_no_signal(false)
		#1:
		#	if button_pressed:
		#		dashboard_button.set_pressed_no_signal(false)
		#		settings_button.set_pressed_no_signal(false)
		1:
			if button_pressed:
				dashboard_button.set_pressed_no_signal(false)
				#playground_button.set_pressed_no_signal(false)
				
	left_menu_button_pressed.emit(v)
