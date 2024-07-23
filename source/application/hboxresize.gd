extends HBoxContainer# Assuming this script is attached to your HBoxContainer

func _ready():
	# Create a new StyleBoxFlat
	var style_box = StyleBoxFlat.new()

	# Set the background color (adjust the color as needed)
	style_box.bg_color = Color.BLACK  # Dark gray, fully opaque

	# Apply the StyleBoxFlat to the HBoxContainer
	self.add_theme_stylebox_override("HBoxContainer", style_box)
