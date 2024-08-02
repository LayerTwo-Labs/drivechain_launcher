extends GridContainer

var columns_count = 3
var rows_count = 4

func _ready():
	columns = columns_count
	setup_grid()
	get_tree().get_root().connect("size_changed", Callable(self, "_on_window_resize"))
	_on_window_resize()  # Initial size setup

func setup_grid():
	for child in get_children():
		child.queue_free()
	
	# Set up the grid
	for i in range(rows_count * columns_count):
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.size_flags_vertical = SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.text = "check"  # Empty by default
		add_child(label)
	
	add_theme_constant_override("h_separation", 10)
	add_theme_constant_override("v_separation", 5)

func _on_window_resize():
	var parent_size = get_parent().size
	var grid_width = parent_size.x * 0.95  # 95% of parent width
	var grid_height = parent_size.y * 0.95  # 95% of parent height
	
	custom_minimum_size = Vector2(grid_width, grid_height)
	size = Vector2(grid_width, grid_height)
	
	var cell_width = grid_width / columns_count
	var cell_height = grid_height / rows_count
	
	for child in get_children():
		child.custom_minimum_size = Vector2(cell_width, cell_height)
	
	# Center the grid in its parent
	position = Vector2((parent_size.x - grid_width) / 2, (parent_size.y - grid_height) / 2)
	
	queue_sort()

func update_cell(row, col, text):
	var index = row * columns_count + col
	if index < get_child_count():
		get_child(index).text = text
