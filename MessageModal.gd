extends PopupPanel

@onready var message_label = $VBoxContainer/Label
@onready var close_button = $VBoxContainer/Button

func _ready():
	close_button.text = "OK"
	close_button.connect("pressed", self, "hide")

func show_message(message: String):
	message_label.text = message
	# Popup and center the panel on the screen
	popup_centered()
	# Optionally, adjust the size of the PopupPanel based on its content
	rect_min_size = $VBoxContainer.get_combined_minimum_size() + Vector2(20, 20)  # Add some padding
