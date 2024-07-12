extends Node

var default_font: Font

func _ready():
	# Load your custom font
	default_font = load("res://assets/fonts/Cantarell-Regular.ttf")
	
	# Apply the font to all Control nodes
	apply_font_override(get_tree().root)

func apply_font_override(node: Node):
	if node is Control:
		apply_font_to_control(node)
	
	for child in node.get_children():
		apply_font_override(child)

func apply_font_to_control(control: Control):
	var font_override = FontVariation.new()
	font_override.base_font = default_font
	
	# Apply to different theme types
	for type in ["normal", "bold", "italic", "bold_italic"]:
		control.add_theme_font_override(type, font_override)
		
	# If it's a specific control that needs size adjustment, you can do it here
	if control is Label:
		control.add_theme_font_size_override("font_size", 16)  # Adjust size as needed

func update_font_size(node: Node, size: int):
	if node is Control:
		node.add_theme_font_size_override("font_size", size)
	
	for child in node.get_children():
		update_font_size(child, size)
