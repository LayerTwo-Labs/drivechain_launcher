extends TabContainer

func _ready():
	size_flags_horizontal = SIZE_EXPAND_FILL
	
	var theme = Theme.new()
	
	# Calculate tab width based on the number of tabs
	var tab_count = get_tab_count()
	var container_width = get_viewport().size.x
	var tab_width = (container_width - (tab_count + 1) * 10) / tab_count  # 10 is the spacing between tabs
	
	theme.set_constant("tab_minimum_width", "TabContainer", tab_width)
	theme.set_constant("tab_height", "TabContainer", 50)
	theme.set_constant("hseparation", "TabContainer", 10)  # Space between tabs
	
	var font = FontVariation.new()
	font.set_base_font(load("res://ui/themes/kenvector_future.ttf"))
	font.set_variation_embolden(0.5)
	theme.set_font("font", "TabContainer", font)
	theme.set_font_size("font_size", "TabContainer", 22)
	
	# Set alignment to fill
	set_tab_alignment(TabBar.ALIGNMENT_CENTER)
	
	theme.set_color("font_selected_color", "TabContainer", Color(1, 1, 1, 1))
	theme.set_color("font_unselected_color", "TabContainer", Color(0.7, 0.7, 0.7, 1))
	
	var selected_stylebox = StyleBoxFlat.new()
	selected_stylebox.set_bg_color(Color(0.2, 0.2, 0.2, 1))
	selected_stylebox.set_corner_radius_all(4)
	selected_stylebox.set_content_margin_all(10)
	
	var unselected_stylebox = StyleBoxFlat.new()
	unselected_stylebox.set_bg_color(Color(0.1, 0.1, 0.1, 1))
	unselected_stylebox.set_corner_radius_all(4)
	unselected_stylebox.set_content_margin_all(10)
	
	theme.set_stylebox("tab_selected", "TabContainer", selected_stylebox)
	theme.set_stylebox("tab_unselected", "TabContainer", unselected_stylebox)
	
	# Add a background for the entire tab bar
	var tab_bar_background = StyleBoxFlat.new()
	tab_bar_background.set_bg_color(Color(0.15, 0.15, 0.15, 1))
	theme.set_stylebox("tab_bar", "TabContainer", tab_bar_background)
	
	var panel_stylebox = StyleBoxFlat.new()
	panel_stylebox.set_bg_color(Color(0.15, 0.15, 0.15, 1))
	theme.set_stylebox("panel", "TabContainer", panel_stylebox)
	
	# Set side margins to 0 to allow tabs to touch the edges
	theme.set_constant("side_margin", "TabContainer", 0)
	
	self.theme = theme
	
	# Ensure tabs fill the entire width
	set_tabs_rearrange_group(0)
	
	# Connect to the resized signal to adjust tab widths when the window is resized
	get_viewport().size_changed.connect(self._on_viewport_resized)

func _on_viewport_resized():
	var tab_count = get_tab_count()
	var container_width = get_viewport().size.x
	var tab_width = (container_width - (tab_count + 1) * 10) / tab_count
	
	var theme = get_theme()
	theme.set_constant("tab_minimum_width", "TabContainer", tab_width)
	self.theme = theme
