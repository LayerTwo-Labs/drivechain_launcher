extends ColorRect

@export var corner_radius: int = 90  # Adjust this value to match your panel's corner radius
@export var overlay_color: Color = Color(1, 1, 1, 0.5)  # Semi-transparent white

func _ready():
	# Create a new StyleBoxFlat for the overlay
	var style = StyleBoxFlat.new()
	
	# Set the corner radius
	style.set_corner_radius_all(1000)
	
	# Set the background color
	style.bg_color = overlay_color
	
	# Apply the style to this ColorRect
	add_theme_stylebox_override("panel", style)
	
	# Ensure the ColorRect fills its parent container
	anchor_right = 1
	anchor_bottom = 1
	offset_right = 0
	offset_bottom = 0

func set_overlay_opacity(opacity: float):
	overlay_color.a = opacity
	var style = get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		style.bg_color = overlay_color
