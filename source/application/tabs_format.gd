extends TabContainer

func _ready():
	var theme = Theme.new()
	
	# Set the tab bar background color to black
	var tabbar_style = StyleBoxFlat.new()
	tabbar_style.bg_color = Color.BLACK
	tabbar_style.expand_margin_top = 5  # Adjust this value as needed
	tabbar_style.expand_margin_bottom = 5  # Adjust this value as needed
	theme.set_stylebox("tabbar_background", "TabContainer", tabbar_style)
	
	# Remove side margins to ensure the background extends fully
	theme.set_constant("side_margin", "TabContainer", 0)
	
	# Ensure the panel (content area) remains unchanged
	var panel_style = get_theme_stylebox("panel")
	if panel_style:
		theme.set_stylebox("panel", "TabContainer", panel_style)
	
	self.theme = theme
	
	# Ensure the TabContainer fills its parent
	anchor_right = 1
	anchor_bottom = 1
	offset_right = 0
	offset_bottom = 0
