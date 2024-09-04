extends TabContainer
@onready var blocker = $AdvancedBlocker
@onready var advanced_button = $VBoxContainer/HBoxContainer/Advanced
@onready var create_wallet_button = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/Create
@onready var return_button = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/Return
@onready var entropy_in = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/LineEdit
@onready var mnemonic_out = $MarginContainer2/VBoxContainer/BoxContainer/GridContainer
@onready var bip39_panel = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer2/BIP39
@onready var launch_panel = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer2/Paths
@onready var create_pop_up = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/LaunchPopUp
@onready var popup_window = $PopUp
@onready var popup_vbox = $PopUp/MarginContainer/VBoxContainer
@onready var mnemonic_label = $PopUp/MarginContainer/VBoxContainer/Label
@onready var mnemonic_in = $MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/MnemonicIn
@onready var load_button = $MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/Load
@onready var fast_button = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/Random
@onready var delete_button = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/DeleteButton
@onready var help_button = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/Help


@onready var tabs = get_parent() if get_parent() is TabContainer else null

var current_wallet_data = {}
var displaying_existing_wallet = false

func _ready():
	create_wallet_button.connect("pressed", Callable(self, "_on_create_wallet_button_pressed"))
	return_button.connect("pressed", Callable(self, "_on_return_button_pressed"))
	entropy_in.connect("text_changed", Callable(self, "_on_entropy_in_changed"))
	create_pop_up.connect("pressed", Callable(self, "_on_create_popup_pressed"))
	load_button.connect("pressed", Callable(self, "_on_load_button_pressed"))
	fast_button.connect("pressed", Callable(self, "_on_fast_button_pressed"))
	delete_button.connect("pressed", Callable(self, "_on_delete_wallet_pressed"))
	help_button.connect("pressed", Callable(self, "_on_help_button_pressed"))
	
	if tabs:
		tabs.connect("tab_changed", Callable(self, "_on_tab_changed"))
	setup_bip39_panel()
	setup_launch_panel()
	ensure_starters_directory()
	setup_wallet_button()
	update_delete_button_state()
	
func setup_wallet_button():
	# Try to find the wallet button using different paths
	var wallet_button = get_node_or_null("../Menu/MarginContainer/HBox/Panel/Wallet")
	if not wallet_button:
		wallet_button = get_node_or_null("/root/Main/VBoxContainer/Menu/MarginContainer/HBox/Panel/Wallet")
	if not wallet_button:
		wallet_button = get_node_or_null("../../Menu/MarginContainer/HBox/Panel/Wallet")
	
	if wallet_button:
		wallet_button.connect("pressed", Callable(self, "_on_wallet_button_pressed"))
	else:
		print("Error: Wallet button not found. Please check the scene structure and button name.")


func update_delete_button_state():
	var user_data_dir = OS.get_user_data_dir()
	var wallet_file = user_data_dir.path_join("wallet_starters/wallet_master_seed.txt")
	
	if delete_button:
		delete_button.disabled = not FileAccess.file_exists(wallet_file)
	else:
		print("Warning: delete_button not found. Check the node path.")


func _on_wallet_button_pressed():
	var user_data_dir = OS.get_user_data_dir()
	var wallet_file = user_data_dir.path_join("wallet_starters/wallet_master_seed.txt")
	
	if FileAccess.file_exists(wallet_file):
		load_existing_wallet(wallet_file)
	else:
		reset_wallet_tab()

func load_existing_wallet(wallet_file):
	var file = FileAccess.open(wallet_file, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json_result = JSON.parse_string(json_string)
		if json_result is Dictionary:
			current_wallet_data = json_result
			display_wallet_info()
		else:
			print("Error: Invalid JSON data in wallet file.")
	else:
		print("Error: Unable to open wallet file.")

func display_wallet_info():
	displaying_existing_wallet = true
	
	var mnemonic = current_wallet_data.get("mnemonic", "")
	if mnemonic:
		var Bitcoin = BitcoinWallet.new()
		var wallet_data = Bitcoin.generate_wallet(mnemonic)
		
		if wallet_data.has("error"):
			print("Error generating wallet from stored mnemonic: ", wallet_data["error"])
			return
		
		# Use the existing display mechanism
		current_wallet_data = wallet_data
		populate_grid(wallet_data["mnemonic"], wallet_data["bip39_bin"], wallet_data["bip39_csum"])
		update_bip39_panel(wallet_data)
		update_launch_panel(wallet_data)
		
		# Set placeholder text for entropy input
		entropy_in.placeholder_text = "Displaying current master wallet information. Start typing to generate new wallet information."
		entropy_in.text = ""
		
		# Disable create popup button
		create_pop_up.disabled = true
	else:
		print("Error: No mnemonic found in stored wallet data.")
		reset_wallet_tab()

func setup_bip39_panel():
	var bip39_info_label = RichTextLabel.new()
	bip39_info_label.name = "BIP39Info"
	bip39_info_label.bbcode_enabled = true
	bip39_info_label.fit_content = true
	bip39_info_label.scroll_active = true
	bip39_info_label.size_flags_horizontal = SIZE_EXPAND_FILL
	bip39_info_label.size_flags_vertical = SIZE_EXPAND_FILL
	bip39_info_label.custom_minimum_size = Vector2(0, 200)
	bip39_panel.add_child(bip39_info_label)

	var headers_text = """[table=2]
[cell][color=white][b][u]BIP39 Hex:[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Bin:



[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Checksum:[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Checksum Hex:[/u][/b][/color][/cell] [cell][/cell]
[/table]"""
	bip39_info_label.text = headers_text

func setup_launch_panel():
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size_flags_vertical = SIZE_EXPAND_FILL
	launch_panel.add_child(vbox)

	var launch_info_label = RichTextLabel.new()
	launch_info_label.name = "LaunchInfo"
	launch_info_label.bbcode_enabled = true
	launch_info_label.fit_content = true
	launch_info_label.scroll_active = true
	launch_info_label.size_flags_horizontal = SIZE_EXPAND_FILL
	launch_info_label.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.add_child(launch_info_label)

	var headers_text = """[table=2]
[cell][color=white][b][u]HD Key Data:
[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]Master Key:
[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]Chain Code:
[/u][/b][/color][/cell] [cell][/cell]
[/table]"""
	launch_info_label.text = headers_text
	
	var existing_spacer = launch_panel.get_node_or_null("Spacer3")
	if existing_spacer:
		launch_panel.remove_child(existing_spacer)
		vbox.add_child(existing_spacer)
		existing_spacer.size_flags_vertical = SIZE_EXPAND_FILL

	var existing_delete = launch_panel.get_node_or_null("DeleteButton")
	if existing_delete:
		launch_panel.remove_child(existing_delete)
		vbox.add_child(existing_delete)
		existing_delete.size_flags_vertical = SIZE_SHRINK_CENTER

func _on_create_wallet_button_pressed():
	reset_wallet_tab()
	current_tab = 1

func _on_return_button_pressed():
	reset_wallet_tab()
	current_tab = 0
	clear_all_output()

func _create_wallet(input: String):
	if input.strip_edges().is_empty():
		clear_all_output()
		return
	var Bitcoin = BitcoinWallet.new()
	var output = Bitcoin.generate_wallet(input)
	if not output.has("error"):
		current_wallet_data = output
		populate_grid(output["mnemonic"], output["bip39_bin"], output["bip39_csum"])
		update_bip39_panel(output)
		update_launch_panel(output)
	else:
		clear_all_output()

func clear_all_output():
	for i in range(1, mnemonic_out.get_child_count()):
		if i != 13 and i != 26:
			var label = mnemonic_out.get_child(i).get_child(0) as Label
			if label:
				label.text = ""

	var bip39_info_label = bip39_panel.get_node("BIP39Info")
	if bip39_info_label:
		var headers_text = """[table=2]
[cell][color=white][b][u]BIP39 Hex:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Bin:



[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Checksum:[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Checksum Hex:[/u][/b][/color][/cell] [cell][/cell]
[/table]"""
		bip39_info_label.text = headers_text

	var launch_info_label = launch_panel.get_node("VBoxContainer/LaunchInfo")
	if launch_info_label:
		var headers_text = """[table=2]
[cell][color=white][b][u]HD Key Data:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]Master Key:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]Chain Code:

[/u][/b][/color][/cell] [cell][/cell]
[/table]"""
		launch_info_label.text = headers_text

	current_wallet_data = {}
	create_pop_up.disabled = false
	displaying_existing_wallet = false
	entropy_in.placeholder_text = ""  # Reset placeholder text

func _on_entropy_in_changed(new_text: String):
	if new_text.is_empty():
		if displaying_existing_wallet:
			# If we were displaying existing wallet info, just clear everything
			clear_all_output()
		else:
			# Normal behavior when clearing input
			clear_all_output()
	else:
		# New input, so we're no longer displaying existing wallet
		displaying_existing_wallet = false
		create_pop_up.disabled = false
		_create_wallet(new_text)

func update_bip39_panel(output: Dictionary):
	var bip39_info_label = bip39_panel.get_node("BIP39Info")
	if bip39_info_label:
		var formatted_bin = ""
		var bin_string = output.get("bip39_bin", "")
		for i in range(0, bin_string.length(), 4):
			formatted_bin += bin_string.substr(i, 4) + " "
		formatted_bin = formatted_bin.strip_edges()

		var checksum = output.get("bip39_csum", "")
		var formatted_checksum = ""
		for i in range(0, checksum.length(), 4):
			formatted_checksum += checksum.substr(i, 4) + " "
		formatted_checksum = formatted_checksum.strip_edges()

		var bip39_hex = output.get("bip39_hex", "")
		var first_half = bip39_hex.substr(0, 32)
		var second_half = bip39_hex.substr(32)

		var info_text = """[table=2]
[cell][color=white][b][u]BIP39 Hex:

[/u][/b][/color][/cell] [cell]{first_half}[color=#808080]{second_half}[/color][/cell]
[cell][color=white][b][u]BIP39 Bin:



[/u][/b][/color][/cell] [cell]{bip39_bin}[/cell]
[cell][color=white][b][u]BIP39 Checksum:[/u][/b][/color][/cell] [cell][color=green]{bip39_csum}[/color][/cell]
[cell][color=white][b][u]BIP39 Checksum Hex:[/u][/b][/color][/cell] [cell][color=green]{bip39_csum_hex}[/color][/cell]
[/table]""".format({
			"first_half": first_half,
			"second_half": second_half,
			"bip39_bin": formatted_bin,
			"bip39_csum": formatted_checksum,
			"bip39_csum_hex": output.get("bip39_csum_hex", "")
		})
		bip39_info_label.text = info_text

func update_launch_panel(output: Dictionary):
	var launch_info_label = launch_panel.get_node("VBoxContainer/LaunchInfo")
	if launch_info_label:
		var info_text = """[table=2]
[cell][color=white][b][u]HD Key Data:

[/u][/b][/color][/cell] [cell]{hd_key_data}[/cell]
[cell][color=white][b][u]Master Key:

[/u][/b][/color][/cell] [cell]{master_key}[/cell]
[cell][color=white][b][u]Chain Code:

[/u][/b][/color][/cell] [cell]{chain_code}[/cell]
[/table]""".format({
			"hd_key_data": output.get("hd_key_data", ""),
			"master_key": output.get("master_key", ""),
			"chain_code": output.get("chain_code", "")
		})
		launch_info_label.text = info_text

func binary_to_integer(binary: String) -> int:
	return ("0b" + binary).bin_to_int()

func populate_grid(mnemonic: String, bip39_bin: String, bip39_csum: String):
	var words = mnemonic.split(" ")
	var bin_chunks = []
	for i in range(0, bip39_bin.length(), 11):
		bin_chunks.append(bip39_bin.substr(i, 11))

	for i in range(12):
		if i < words.size() and i < bin_chunks.size():
			var word_panel = mnemonic_out.get_child(i + 1)
			var bin_panel = mnemonic_out.get_child(i + 14)
			var index_panel = mnemonic_out.get_child(i + 27)

			if word_panel and bin_panel and index_panel:
				var word_label = word_panel.get_child(0) as Label
				var bin_label = bin_panel.get_child(0) as Label
				var index_label = index_panel.get_child(0) as Label

				if word_label and bin_label and index_label:
					word_label.text = words[i]
					if i == 11:
						bin_label.text = bin_chunks[i] + bip39_csum
					else:
						bin_label.text = bin_chunks[i]
					index_label.text = str(binary_to_integer(bin_chunks[i]))
				else:
					print("Labels not found for cell ", i)
			else:
				print("Panel not found for index ", i)
	mnemonic_out.queue_redraw()

func setup_bip39_headers():
	var bip39_info_label = bip39_panel.get_node("BIP39Info")
	if bip39_info_label:
		var headers_text = """[table=2]
[cell][color=white][b][u]BIP39 Hex:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Bin:



[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Checksum:[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Checksum Hex:[/u][/b][/color][/cell] [cell][/cell]
[/table]"""
		bip39_info_label.text = headers_text

func setup_launch_panel_headers():
	var vbox = launch_panel.get_node_or_null("VBoxContainer")
	if not vbox:
		vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		launch_panel.add_child(vbox)

	var launch_info_label = vbox.get_node_or_null("LaunchInfo")
	if not launch_info_label:
		launch_info_label = RichTextLabel.new()
		launch_info_label.name = "LaunchInfo"
		launch_info_label.bbcode_enabled = true
		launch_info_label.fit_content = true
		launch_info_label.scroll_active = true
		launch_info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		launch_info_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.add_child(launch_info_label)
		vbox.move_child(launch_info_label, 0)  # Move to top

	var headers_text = """[table=2]
[cell][color=white][b][u]HD Key Data:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]Master Key:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]Chain Code:

[/u][/b][/color][/cell] [cell][/cell]
"""
	launch_info_label.text = headers_text

func _on_create_popup_pressed():
	if entropy_in.text.is_empty():
		entropy_in.placeholder_text = "You must enter or generate entropy to create wallet"
		return

	if check_existing_wallet():
		show_existing_wallet_popup()
	else:
		show_new_wallet_popup()
	
	update_delete_button_state()

func check_existing_wallet() -> bool:
	var user_data_dir = OS.get_user_data_dir()
	var wallet_file = user_data_dir.path_join("wallet_starters/wallet_master_seed.txt")
	return FileAccess.file_exists(wallet_file)

func show_existing_wallet_popup():
	if popup_window != null:
		popup_window.queue_free()
	
	popup_window = Control.new()
	popup_window.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.5)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.connect("gui_input", Callable(self, "_on_background_gui_input"))
	popup_window.add_child(background)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 250)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -200)
	panel.set_anchor_and_offset(SIDE_TOP, 0.5, -125)
	panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 200)
	panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 125)
	popup_window.add_child(panel)

	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color.WHITE
	stylebox.bg_color = Color(0.15, 0.15, 0.15)
	panel.add_theme_stylebox_override("panel", stylebox)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	main_vbox.add_theme_constant_override("separation", 20)
	panel.add_child(main_vbox)

	var warning_label = Label.new()
	warning_label.text = "WARNING:"
	warning_label.add_theme_color_override("font_color", Color.RED)
	warning_label.add_theme_font_size_override("font_size", 28)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(warning_label)

	var message_label = Label.new()
	message_label.text = "A wallet already exists.\nYou must delete the current wallet\nbefore creating a new one."
	message_label.add_theme_color_override("font_color", Color.RED)
	message_label.add_theme_font_size_override("font_size", 20)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(message_label)

	var button_hbox = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 10)
	button_hbox.size_flags_vertical = Control.SIZE_SHRINK_END
	main_vbox.add_child(button_hbox)

	var button_width = 120
	var button_height = 40

	var delete_button = Button.new()
	delete_button.text = "Delete Wallet"
	delete_button.custom_minimum_size = Vector2(button_width, button_height)
	delete_button.connect("pressed", Callable(self, "_on_delete_wallet_pressed"))
	button_hbox.add_child(delete_button)

	get_tree().root.add_child(popup_window)
	get_tree().root.connect("size_changed", Callable(self, "_center_popup"))
	popup_window.show()

func _on_delete_wallet_pressed():
	show_delete_confirmation_popup()

func show_delete_confirmation_popup():
	if popup_window != null:
		popup_window.queue_free()

	popup_window = Control.new()
	popup_window.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.5)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.connect("gui_input", Callable(self, "_on_background_gui_input"))
	popup_window.add_child(background)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 200)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -200)
	panel.set_anchor_and_offset(SIDE_TOP, 0.5, -100)
	panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 200)
	panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 100)
	popup_window.add_child(panel)

	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color.WHITE
	stylebox.bg_color = Color(0.15, 0.15, 0.15)
	panel.add_theme_stylebox_override("panel", stylebox)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	main_vbox.add_theme_constant_override("separation", 20)
	panel.add_child(main_vbox)

	var warning_label = Label.new()
	warning_label.text = "WARNING:"
	warning_label.add_theme_color_override("font_color", Color.RED)
	warning_label.add_theme_font_size_override("font_size", 28)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(warning_label)

	var message_label = Label.new()
	message_label.text = "Are you sure you want to delete the wallet?\nThis action cannot be undone."
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(message_label)

	var button_hbox = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 20)
	button_hbox.size_flags_vertical = Control.SIZE_SHRINK_END
	main_vbox.add_child(button_hbox)

	var yes_button = Button.new()
	yes_button.text = "Yes, Delete"
	yes_button.custom_minimum_size = Vector2(120, 40)
	yes_button.connect("pressed", Callable(self, "_on_delete_confirmation_yes"))
	button_hbox.add_child(yes_button)

	var no_button = Button.new()
	no_button.text = "No, Cancel"
	no_button.custom_minimum_size = Vector2(120, 40)
	no_button.connect("pressed", Callable(self, "_on_popup_close_pressed"))
	button_hbox.add_child(no_button)

	get_tree().root.add_child(popup_window)
	get_tree().root.connect("size_changed", Callable(self, "_center_popup"))
	popup_window.show()
	
func _on_delete_confirmation_yes():
	_on_popup_close_pressed()  # Close the confirmation popup
	delete_wallet()
	
func delete_wallet():
	var user_data_dir = OS.get_user_data_dir()
	var wallet_starters_dir = user_data_dir.path_join("wallet_starters")
	var dir = DirAccess.open(wallet_starters_dir)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var file_path = wallet_starters_dir.path_join(file_name)
				var err = dir.remove(file_path)
				if err != OK:
					print("Error deleting file: ", file_path, " Error code: ", err)
			file_name = dir.get_next()
		dir.list_dir_end()
		print("Wallet files deleted successfully.")
	else:
		print("Error: Unable to access wallet directory.")
		return

	# Clear any stored wallet data
	current_wallet_data.clear()

	# Update the wallet button theme
	var wallet_button = $"../../Menu/MarginContainer/HBox/Panel/Wallet"
	update_wallet_button_theme(wallet_button, false)

	# Reset UI elements
	entropy_in.text = ""
	mnemonic_in.text = ""
	clear_all_output()

	# Switch to the initial tab
	if tabs:
		tabs.current_tab = 0

	current_tab = 0

	update_delete_button_state()

	print("Wallet deleted and UI reset.")
	
func _on_help_button_pressed():
	show_help_popup()
	
func show_help_popup():
	if popup_window != null:
		popup_window.queue_free()

	popup_window = Control.new()
	popup_window.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.5)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.connect("gui_input", Callable(self, "_on_background_gui_input"))
	popup_window.add_child(background)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(500, 400)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -250)
	panel.set_anchor_and_offset(SIDE_TOP, 0.5, -200)
	panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 250)
	panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 200)
	popup_window.add_child(panel)

	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color.WHITE
	stylebox.bg_color = Color(0.15, 0.15, 0.15)
	panel.add_theme_stylebox_override("panel", stylebox)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	main_vbox.add_theme_constant_override("separation", 10)
	panel.add_child(main_vbox)

	var title_label = Label.new()
	title_label.text = "Wallet Help"
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title_label)

	var help_text = """
	• Create Wallet: Use 'Random' or enter entropy, then click 'Create Wallet'
	• Mnemonic: 12-word phrase for wallet recovery - keep it safe!
	• Load Wallet: Enter existing mnemonic and click 'Load'
	• Wallet Info: View BIP39 data and HD key details after creation/loading
	• Sidechains: Automatically generated based on your wallet
	• Security: Never share your mnemonic or private keys
	• Delete Wallet: Removes current wallet data (irreversible)

	Note: This tool is for educational/testing purposes only.
	For real transactions, use secure, well-reviewed wallet software.
	"""

	var help_label = Label.new()
	help_label.text = help_text
	help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(help_label)

	var close_button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(120, 40)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.connect("pressed", Callable(self, "_on_popup_close_pressed"))
	main_vbox.add_child(close_button)

	get_tree().root.add_child(popup_window)
	get_tree().root.connect("size_changed", Callable(self, "_center_popup"))
	popup_window.show()

func show_new_wallet_popup():
	if popup_window != null:
		_center_popup()
		popup_window.show()
		return

	popup_window = Control.new()
	popup_window.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.5)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.connect("gui_input", Callable(self, "_on_background_gui_input"))
	popup_window.add_child(background)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 300)  # Adjust size as needed
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -200)
	panel.set_anchor_and_offset(SIDE_TOP, 0.5, -150)
	panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, 200)
	panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, 150)
	popup_window.add_child(panel)

	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color.WHITE
	stylebox.bg_color = Color(0.15, 0.15, 0.15)
	panel.add_theme_stylebox_override("panel", stylebox)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	main_vbox.add_theme_constant_override("separation", 20)
	panel.add_child(main_vbox)

	var attention_label = Label.new()
	attention_label.text = "**ATTENTION** Write down these 12 words for future wallet recovery and restoration as you will NOT see them again"
	attention_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	attention_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attention_label.add_theme_color_override("font_color", Color.RED)
	main_vbox.add_child(attention_label)

	var mnemonic_container = PanelContainer.new()
	mnemonic_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(mnemonic_container)

	var mnemonic_label = Label.new()
	mnemonic_label.text = current_wallet_data.get("mnemonic", "")
	mnemonic_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mnemonic_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mnemonic_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mnemonic_label.add_theme_font_size_override("font_size", 16)
	mnemonic_container.add_child(mnemonic_label)

	var bottom_container = VBoxContainer.new()
	bottom_container.size_flags_vertical = Control.SIZE_SHRINK_END
	main_vbox.add_child(bottom_container)

	var question_label = Label.new()
	question_label.text = "Do you want to create this wallet?"
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_container.add_child(question_label)

	var button_hbox = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 20)
	button_hbox.size_flags_vertical = Control.SIZE_SHRINK_END
	bottom_container.add_child(button_hbox)

	var yes_button = Button.new()
	yes_button.text = "Yes, Create"
	yes_button.custom_minimum_size = Vector2(120, 40)
	yes_button.connect("pressed", Callable(self, "_on_popup_yes_pressed"))
	button_hbox.add_child(yes_button)

	var no_button = Button.new()
	no_button.text = "No, Cancel"
	no_button.custom_minimum_size = Vector2(120, 40)
	no_button.connect("pressed", Callable(self, "_on_popup_close_pressed"))
	button_hbox.add_child(no_button)

	get_tree().root.add_child(popup_window)
	get_tree().root.connect("size_changed", Callable(self, "_center_popup"))
	popup_window.show()

func _center_popup() -> void:
	if popup_window != null:
		var panel = popup_window.get_node("Panel")
		if panel != null:
			var viewport_size = get_viewport().size
			panel.set_anchor_and_offset(SIDE_LEFT, 0.5, -panel.custom_minimum_size.x / 2)
			panel.set_anchor_and_offset(SIDE_TOP, 0.5, -panel.custom_minimum_size.y / 2)
			panel.set_anchor_and_offset(SIDE_RIGHT, 0.5, panel.custom_minimum_size.x / 2)
			panel.set_anchor_and_offset(SIDE_BOTTOM, 0.5, panel.custom_minimum_size.y / 2)

func _on_background_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_popup_close_pressed()

func save_wallet_data():
	if current_wallet_data.is_empty():
		print("Error: No wallet data to save.")
		return

	var seed_data = {
		"seed_hex": current_wallet_data.get("seed", ""),
		"seed_binary": current_wallet_data.get("bip39_bin", ""),
		"mnemonic": current_wallet_data.get("mnemonic", "")
	}

	if seed_data["seed_hex"].is_empty() or seed_data["seed_binary"].is_empty() or seed_data["mnemonic"].is_empty():
		print("Error: Incomplete wallet data. Unable to save.")
		return

	var user_data_dir = OS.get_user_data_dir()
	var wallet_starters_dir = user_data_dir.path_join("wallet_starters")
	if not DirAccess.dir_exists_absolute(wallet_starters_dir):
		var dir = DirAccess.open(user_data_dir)
		if dir.make_dir("wallet_starters") != OK:
			print("Error: Unable to create wallet_starters directory.")
			return

	var file = FileAccess.open(wallet_starters_dir.path_join("wallet_master_seed.txt"), FileAccess.WRITE)
	if file == null:
		print("Error: Unable to open file for writing.")
		return
	var json_string = JSON.stringify(seed_data)
	file.store_string(json_string)
	file.close()
	print("Wallet data saved successfully.")

func _on_popup_yes_pressed():
	if current_wallet_data.is_empty():
		print("Error: No wallet data to save.")
		_on_popup_close_pressed()
		return

	save_wallet_data()

	var Bitcoin = BitcoinWallet.new()
	var sidechain_slots = get_sidechain_info()

	if not current_wallet_data.has("seed") or not current_wallet_data.has("mnemonic"):
		print("Error: Incomplete wallet data. Unable to generate sidechain starters.")
		_on_popup_close_pressed()
		return

	var sidechain_data = Bitcoin.generate_sidechain_starters(current_wallet_data["seed"], current_wallet_data["mnemonic"], sidechain_slots)
	save_sidechain_info(sidechain_data)
	_on_popup_close_pressed()

	var wallet_button = $"../../Menu/MarginContainer/HBox/Panel/Wallet"
	update_wallet_button_theme(wallet_button, true)

	tabs.current_tab = 1

	print("Wallet and sidechain information saved.")
	update_delete_button_state()

func _on_replace_wallet_yes_pressed():
	# Delete old wallet and sidechain files
	var user_data_dir = OS.get_user_data_dir()
	var wallet_starters_dir = user_data_dir.path_join("wallet_starters")
	var dir = DirAccess.open(wallet_starters_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(file_name)
			file_name = dir.get_next()

	# Save new wallet data
	save_wallet_data()

	var Bitcoin = BitcoinWallet.new()
	var sidechain_slots = get_sidechain_info()

	if not current_wallet_data.has("seed") or not current_wallet_data.has("mnemonic"):
		print("Error: Incomplete wallet data. Unable to generate sidechain starters.")
		_on_popup_close_pressed()
		return

	var sidechain_data = Bitcoin.generate_sidechain_starters(current_wallet_data["seed"], current_wallet_data["mnemonic"], sidechain_slots)
	save_sidechain_info(sidechain_data)
	_on_popup_close_pressed()

	var wallet_button = $"../../Menu/MarginContainer/HBox/Panel/Wallet"
	update_wallet_button_theme(wallet_button, true)

	if tabs:
		tabs.current_tab = 1
	print("Wallet and sidechain information replaced and saved.")

func _on_popup_close_pressed() -> void:
	if popup_window != null:
		popup_window.queue_free()
		popup_window = null
		get_tree().root.disconnect("size_changed", Callable(self, "_center_popup"))

func _on_load_button_pressed():
	var wallet = BitcoinWallet.new()
	var mnemonic = mnemonic_in.text.strip_edges().to_lower()
	var words = mnemonic.split(" ")

	if words.size() != 12:
		print("Error: Mnemonic must contain exactly 12 words.")
		return
	for word in words:
		if not wallet.is_valid_bip39_word(word):
			print("Error: '", word, "' is not a valid BIP39 word.")
			return
	print("All words in the mnemonic are valid.")
	var result = wallet.generate_wallet(mnemonic)

	if result.has("error"):
		print("Error generating wallet: ", result["error"])
		return
	print("Wallet generated successfully:")

	# Save master wallet data in the new format
	var seed_data = {
		"mnemonic": result["mnemonic"],
		"seed_binary": result["bip39_bin"],
		"seed_hex": result["seed"]
	}
	var user_data_dir = OS.get_user_data_dir()
	var file = FileAccess.open(user_data_dir.path_join("wallet_starters/wallet_master_seed.txt"), FileAccess.WRITE)
	var json_string = JSON.stringify(seed_data)
	file.store_string(json_string)
	file.close()

	# Generate and save sidechain starters
	var sidechain_slots = get_sidechain_info()
	var sidechain_data = wallet.generate_sidechain_starters(result["seed"], result["mnemonic"], sidechain_slots)
	save_sidechain_info(sidechain_data)
	var wallet_button = $"../../Menu/MarginContainer/HBox/Panel/Wallet"
	update_wallet_button_theme(wallet_button, true)

	if tabs:
		tabs.current_tab = 1
	print("Wallet and sidechain information saved.")
	update_delete_button_state()

func _on_fast_button_pressed():
	entropy_in.text = ""
	var wallet_generator = BitcoinWallet.new()
	var entropy = wallet_generator.fast_create()
	entropy_in.text = entropy
	_on_entropy_in_changed(entropy)

func get_sidechain_info():
	var sidechain_info = []
	var file = FileAccess.open("res://chain_providers.cfg", FileAccess.READ)
	if file:
		var current_section = ""
		while !file.eof_reached():
			var line = file.get_line().strip_edges()
			if line.begins_with("[") and line.ends_with("]"):
				current_section = line.substr(1, line.length() - 2)
			elif line.begins_with("slot=") and current_section != "drivechain":
				var slot = line.split("=")[1].to_int()
				if slot != -1:
					sidechain_info.append(slot)
	return sidechain_info

func save_sidechain_info(sidechain_data):
	for key in sidechain_data.keys():
		if key.begins_with("sidechain_"):
			var slot = key.split("_")[1]
			var user_data_dir = OS.get_user_data_dir()
			var filename = user_data_dir.path_join("wallet_starters/sidechain_%s_starter.txt" % slot)
			var file = FileAccess.open(filename, FileAccess.WRITE)
			if file:
				file.store_string(JSON.stringify(sidechain_data[key]))
				file.close()
			else:
				print("Failed to save sidechain starter information for slot ", slot)
		elif key.begins_with("mainchain"):
			var user_data_dir = OS.get_user_data_dir()
			var filename = user_data_dir.path_join("wallet_starters/mainchain_starter.txt")
			var file = FileAccess.open(filename, FileAccess.WRITE)
			if file:
				file.store_string(JSON.stringify(sidechain_data[key]))
				file.close()
			else:
				print("Failed to save sidechain starter information for mainchain")

func reset_wallet_tab():
	clear_all_output()
	entropy_in.text = ""
	mnemonic_in.text = ""
	current_wallet_data = {}
	mnemonic_out.setup_grid()
	current_tab = 0
	create_pop_up.disabled = false
	displaying_existing_wallet = false

func _on_tab_changed(tab):
	if tab != get_index(): 
		reset_wallet_tab()

func ensure_starters_directory():
	var user_data_dir = OS.get_user_data_dir()
	var starters_dir = user_data_dir.path_join("wallet_starters")
	var dir = DirAccess.open(user_data_dir)
	if not dir.dir_exists("wallet_starters"):
		dir.make_dir("wallet_starters")
		
func update_wallet_button_theme(button: Button, wallet_exists: bool):
	if wallet_exists:
		button.disabled = false
	else:
		button.disabled = true

func _on_wallet_created():
	update_delete_button_state()

func _on_wallet_deleted():
	update_delete_button_state()
