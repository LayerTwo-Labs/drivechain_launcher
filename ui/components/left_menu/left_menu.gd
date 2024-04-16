extends PanelContainer

var          settings_shown    : int  = 0

@onready var dashboard_button  : Node = $MarginContainer/HBox/DashboardButton
@onready var playground_button : Node = $MarginContainer/HBox/PlaygroundButton
@onready var settings_button   : Node = $MarginContainer/HBox/SettingsButton

signal left_menu_button_pressed(v: int)

func _ready() -> void:
	$FastWithdrawWindow.hide()


func _on_left_menu_button_toggled(button_pressed, v):
	
	settings_shown = 1-settings_shown
	
	left_menu_button_pressed.emit(settings_shown)
	

func _on_close_button_pressed():
	var shutter_tween : Tween = create_tween()
	shutter_tween.parallel().tween_property( $MarginContainer, "scale", Vector2(1.0,0.0), 0.5 )
	shutter_tween.parallel().tween_property( self, "size/y", 0.0, 0.5 )


func _on_fast_withdraw_button_pressed() -> void:
	$FastWithdrawWindow.show()


func _on_fast_withdraw_window_close_requested() -> void:
	$FastWithdrawWindow.hide()
