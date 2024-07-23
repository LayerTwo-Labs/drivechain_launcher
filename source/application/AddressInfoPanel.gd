extends Panel

var current_page = 1
var total_pages = 10  # This can be adjusted based on your needs

@onready var prev_button: Button = $HBoxContainer/Prev
@onready var next_button: Button = $HBoxContainer/Next
@onready var page_label: Label = $HBoxContainer/Page

func _ready():
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	update_navigation()

func update_navigation():
	prev_button.disabled = current_page == 1
	next_button.disabled = current_page == total_pages
	page_label.text = "Page %d of %d" % [current_page, total_pages]

func _on_prev_pressed():
	if current_page > 1:
		current_page -= 1
		update_navigation()

func _on_next_pressed():
	if current_page < total_pages:
		current_page += 1
		update_navigation()

# Debug function to test the pagination
func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("Current Page:", current_page)
