extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_center_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				queue_free()


func _on_button_pressed():
	var error = get_tree().change_scene_to_file("res://ui/components/dashboard/dashboard.tscn")
	if error != OK:
		print("Failed to change scene: ", error)
	Appstate.reset_everything(true)


func _on_button_2_pressed():
	var error = get_tree().change_scene_to_file("res://ui/components/dashboard/dashboard.tscn")
	if error != OK:
		print("Failed to change scene: ", error)
	Appstate.reset_everything(false) # Replace with function body.
