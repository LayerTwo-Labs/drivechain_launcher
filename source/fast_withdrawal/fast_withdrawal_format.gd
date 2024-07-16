extends MarginContainer

const CUSTOM_FONT_PATH = "res://assets/fonts/Satoshi-Bold.otf"

func _ready():
	apply_custom_font()

func apply_custom_font():
	var custom_font = load(CUSTOM_FONT_PATH)
	if custom_font:
		apply_font_recursive(self, custom_font)

func apply_font_recursive(node: Node, font: Font):
	if node is Label or node is Button or node is LineEdit or node is TextEdit:
		node.add_theme_font_override("font", font)
	for child in node.get_children():
		apply_font_recursive(child, font)
