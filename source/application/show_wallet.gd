extends MarginContainer

@onready var show_button: Button = $ShowWallet
var popup_window: Control = null
var wallet_file_path: String

func _ready():
	wallet_file_path = OS.get_user_data_dir().path_join("wallet_starters/wallet_master_seed.txt")
	show_button.disabled = true
	show_button.connect("pressed", Callable(self, "_on_show_wallet_pressed"))
	
	check_wallet_file()
	get_tree().connect("files_dropped", Callable(self, "_on_files_dropped"))

func _process(delta):
	check_wallet_file()

func check_wallet_file():
	var file_exists = FileAccess.file_exists(wallet_file_path)
	show_button.disabled = !file_exists

func _on_files_dropped(files, screen):
	for file in files:
		if file == wallet_file_path:
			check_wallet_file()
			break

func _on_show_wallet_pressed():
	var file = FileAccess.open(wallet_file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var seed_data = json.get_data()
			if seed_data.has("mnemonic"):
				show_popup(seed_data["mnemonic"])
			else:
				print("Error: Mnemonic not found in wallet file")
		else:
			print("Error parsing JSON: ", json.get_error_message())
	else:
		print("Error opening wallet file")

func show_popup(mnemonic: String):
	if popup_window != null:
		popup_window.queue_free()
	
	popup_window = Panel.new()
	popup_window.set_anchors_preset(Control.PRESET_CENTER)
	popup_window.custom_minimum_size = Vector2(400, 300)
	
	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color.WHITE
	stylebox.bg_color = Color(0.15, 0.15, 0.15, 0.9)  # Slightly transparent
	popup_window.add_theme_stylebox_override("panel", stylebox)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	popup_window.add_child(main_vbox)
	
	var mnemonic_container = PanelContainer.new()
	mnemonic_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(mnemonic_container)
	
	var mnemonic_label = Label.new()
	mnemonic_label.text = mnemonic
	mnemonic_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mnemonic_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mnemonic_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mnemonic_container.add_child(mnemonic_label)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.connect("pressed", Callable(self, "_on_popup_close_pressed"))
	main_vbox.add_child(close_button)
	
	# Create a CanvasLayer to ensure the popup is on top
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Adjust this value as needed
	canvas_layer.add_child(popup_window)
	
	# Add the CanvasLayer to the scene tree
	get_tree().root.add_child(canvas_layer)
	
	# Make the popup modal
	popup_window.mouse_filter = Control.MOUSE_FILTER_STOP
	
	popup_window.show()

func _on_popup_close_pressed():
	if popup_window:
		popup_window.get_parent().queue_free()  # Remove the CanvasLayer
		popup_window = null
