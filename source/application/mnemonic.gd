extends GridContainer

var columns_count = 13
var rows_count = 3

var header_font_path = "res://assets/fonts/Satoshi-Bold.otf"

func _ready():
	columns = columns_count
	setup_grid()
	get_tree().get_root().connect("size_changed", Callable(self, "_on_window_resize"))
	_on_window_resize()  # Initial size setup
	
func setup_grid():
	for child in get_children():
		child.queue_free()
	
	var font = load(header_font_path)
	var small_font = font.duplicate()
	var default_size = 14  # Set this to your desired default font size
	var small_size = int(default_size * 0.7)  # Adjust this factor to get the desired size
	
	# Set up the grid
	for i in range(columns_count * rows_count):
		var panel = Panel.new()
		panel.size_flags_horizontal = SIZE_EXPAND_FILL
		panel.size_flags_vertical = SIZE_EXPAND_FILL
		
		# Create a StyleBoxFlat for the border
		var style_box = StyleBoxFlat.new()
		style_box.set_border_width_all(1)
		style_box.border_color = Color.WHITE
		style_box.bg_color = Color(0.2, 0.2, 0.2, 1)  # Dark gray background
		panel.add_theme_stylebox_override("panel", style_box)
		
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.size_flags_vertical = SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		
		# Ensure label takes up full cell size
		label.anchor_right = 1
		label.anchor_bottom = 1
		label.offset_left = 0
		label.offset_top = 0
		label.offset_right = 0
		label.offset_bottom = 0
		
		# Set the font and font size
		if i > 13 and i < 26:  # BIN row
			label.add_theme_font_override("font", small_font)
			label.add_theme_font_size_override("font_size", small_size)
		else:
			label.add_theme_font_override("font", font)
			label.add_theme_font_size_override("font_size", default_size)
		
		# Set specific text for elements 0, 13, and 26
		if i == 0:
			label.text = "WORD"
		elif i == 13:
			label.text = "BIN"
		elif i == 26:
			label.text = "INDEX"
		else:
			label.text = " "
		
		panel.add_child(label)
		add_child(panel)
	
	columns = columns_count
	add_theme_constant_override("h_separation", 0)
	add_theme_constant_override("v_separation", 0)

func _on_window_resize():
	var parent_size = get_parent().size
	var grid_width = parent_size.x * 0.8  # Increased to 80% of parent width
	
	# Adjust this factor to increase cell height
	var height_factor = 1  # Decreased for shorter cells
	
	var cell_width = grid_width / columns_count
	var cell_height = cell_width * height_factor
	var grid_height = cell_height * rows_count
	
	custom_minimum_size = Vector2(grid_width, grid_height)
	size = Vector2(grid_width, grid_height)
	
	for child in get_children():
		child.custom_minimum_size = Vector2(cell_width, cell_height)
	
	# Center the grid in its parent
	position = Vector2((parent_size.x - grid_width) / 2, (parent_size.y - grid_height) / 2)
	
	queue_sort()
