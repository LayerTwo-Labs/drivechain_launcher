extends TabContainer

func _ready():
	var theme = Theme.new()
	set_tab_alignment(TabBar.ALIGNMENT_CENTER)
	var font = load("res://assets/fonts/Heartbit-Bold.otf")
	theme.set_font("font", "TabContainer", font)
	theme.set_font_size("font", "TabBar", 28)
	theme.set_constant("tab_minimum_width", "TabContainer", 200)  # Set minimum tab width
	theme.set_constant("tab_height", "TabContainer", 80)  # Adjust tab height
	theme.set_constant("h_separation", "TabContainer", 4)
	theme.set_constant("outline_size", "TabContainer", 5)
	theme.set_constant("font_size", "TabContainer", 24)
	self.theme = theme
