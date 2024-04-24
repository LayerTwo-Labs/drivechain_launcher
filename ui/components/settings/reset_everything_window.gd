extends ColorRect

func _on_reset_everything_window_close_requested() -> void:
	var reset_window = get_node("res://ui/components/settings/reset_menu/reset_everything_window.tscn")
	reset_window.hide()  # This hides the window but keeps it in the scene tree
	# OR
	reset_window.queue_free()  # This removes the window from the scene tree and frees it
	print("Reset window closed")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
