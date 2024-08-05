extends TabContainer

func _ready():
	var theme = Theme.new()
	set_tab_alignment(TabBar.ALIGNMENT_CENTER)
	theme.set_constant("tab_minimum_width", "TabContainer", 200)  # Set minimum tab width
	theme.set_constant("tab_height", "TabContainer", 80)  # Adjust tab height
	theme.set_constant("h_separation", "TabContainer", 6)
	theme.set_constant("outline_size", "TabContainer", 5)
	theme.set_constant("font_size", "TabContainer", 24)
	self.theme = theme
