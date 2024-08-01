extends TabContainer

func _ready():
	size_flags_horizontal = SIZE_EXPAND_FILL
	var theme = Theme.new()
	var tab_count = get_tab_count()
	var container_width = get_viewport().size.x
	var tab_width = container_width / tab_count
	
	theme.set_constant("tab_minimum_width", "TabContainer", tab_width)
	theme.set_constant("tab_height", "TabContainer", 100)
	theme.set_constant("hseparation", "TabContainer", 0)  # No separation between tabs
	
	# Set alignment to fill
	set_tab_alignment(TabBar.ALIGNMENT_MAX)
	
	theme.set_color("font_selected_color", "TabContainer", Color(1, 1, 1, 1))
	theme.set_color("font_unselected_color", "TabContainer", Color(0.7, 0.7, 0.7, 1))
	theme.set_color("font_hovered_color", "TabContainer", Color(1, 1, 1, 1))
	
	var base_stylebox = StyleBoxFlat.new()
	base_stylebox.set_corner_radius_all(0)  # No rounded corners
	base_stylebox.set_content_margin_all(0)  # No content margin
	
	var selected_stylebox = base_stylebox.duplicate()
	selected_stylebox.set_bg_color(Color(0.2, 0.2, 0.2, 1))
	
	var unselected_stylebox = base_stylebox.duplicate()
	unselected_stylebox.set_bg_color(Color(0.1, 0.1, 0.1, 1))
	
	var hover_stylebox = base_stylebox.duplicate()
	hover_stylebox.set_bg_color(Color(0.15, 0.15, 0.15, 1))
	
	theme.set_stylebox("tab_selected", "TabContainer", selected_stylebox)
	theme.set_stylebox("tab_unselected", "TabContainer", unselected_stylebox)
	theme.set_stylebox("tab_selected_hover", "TabContainer", selected_stylebox)
	theme.set_stylebox("tab_unselected_hover", "TabContainer", hover_stylebox)
	
	# Remove the panel behind the tabs
	var empty_stylebox = StyleBoxEmpty.new()
	theme.set_stylebox("panel", "TabContainer", empty_stylebox)
	
	# Apply the theme to this TabContainer
	self.theme = theme
	
	# Apply global font override
	GlobalFont.apply_font_override(self)
