extends ColorRect
var chain_provider: ChainProvider

func setup(_chain_provider: ChainProvider):
	chain_provider = _chain_provider
	# Now you can use chain_provider.display_name because it has been assigned a ChainProvider instance.

func _on_center_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				queue_free()

func _ready():
	setup(chain_provider)

func _on_button_pressed():
	if chain_provider:
		print("Button 1 pressed for " + chain_provider.display_name)
	else:
		print("chain_provider is not initialized!")

func _on_button_2_pressed():
	print("Button 2 pressed")
