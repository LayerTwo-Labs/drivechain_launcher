extends TabContainer
@onready var blocker = $AdvancedBlocker
@onready var advanced_button = $VBoxContainer/HBoxContainer/Advanced
@onready var create_wallet_button = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/Create
@onready var return_button = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/Return
@onready var entropy_in = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/LineEdit
@onready var mnemonic_out = $MarginContainer2/VBoxContainer/BoxContainer/GridContainer
@onready var bip39_panel = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer2/BIP39
@onready var launch_panel = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer2/Paths
@onready var create_pop_up = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer2/Paths/LaunchPopUp
@onready var popup_window = $PopUp
@onready var popup_vbox = $PopUp/MarginContainer/VBoxContainer
@onready var mnemonic_label = $PopUp/MarginContainer/VBoxContainer/Label
@onready var hide_button = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/Hide
@onready var mnemonic_in = $MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/MnemonicIn
@onready var load_button = $MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/Load
@onready var fast_button = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/Random

@onready var tabs = get_parent() if get_parent() is TabContainer else null

var current_wallet_data = {}

func _ready():
	create_wallet_button.connect("pressed", Callable(self, "_on_create_wallet_button_pressed"))
	return_button.connect("pressed", Callable(self, "_on_return_button_pressed"))
	entropy_in.connect("text_changed", Callable(self, "_on_entropy_in_changed"))
	create_pop_up.connect("pressed", Callable(self, "_on_create_popup_pressed"))
	hide_button.connect("toggled", Callable(self, "_on_hide_button_toggled"))
	load_button.connect("pressed", Callable(self, "_on_load_button_pressed"))
	fast_button.connect("pressed", Callable(self, "_on_fast_button_pressed"))
	
	if tabs:
		tabs.connect("tab_changed", Callable(self, "_on_tab_changed"))
	setup_bip39_panel()
	setup_launch_panel()

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
	var existing_button = launch_panel.get_node_or_null("LaunchPopUp")
	if existing_button:
		launch_panel.remove_child(existing_button)
		vbox.add_child(existing_button)

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
		_toggle_output_visibility(true)  # Ensure output is visible
		hide_button.button_pressed = false
	else:
		clear_all_output()

func clear_all_output():
	entropy_in.text = ""
	for i in range(1, mnemonic_out.get_child_count()):
		if i != 13 and i != 26:
			var label = mnemonic_out.get_child(i).get_child(0) as Label
			if label:
				label.text = ""
	
	var bip39_info_label = bip39_panel.get_node("BIP39Info")
	if bip39_info_label:
		var headers_text = """[table=2]
[cell][color=white][b][u]BIP39 Hex:[/u][/b][/color][/cell] [cell][/cell]
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
	
	hide_button.button_pressed = false
	current_wallet_data = {}
	_toggle_output_visibility(true)
		
func _on_entropy_in_changed(new_text: String):
	if new_text.is_empty():
		clear_all_output()
	else:
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
		

		var info_text = """[table=2]
[cell][color=white][b][u]BIP39 Hex:[/u][/b][/color][/cell] [cell]{bip39_hex}[/cell]
[cell][color=white][b][u]BIP39 Bin:



[/u][/b][/color][/cell] [cell]{bip39_bin}[/cell]
[cell][color=white][b][u]BIP39 Checksum:[/u][/b][/color][/cell] [cell][color=green]{bip39_csum}[/color][/cell]
[cell][color=white][b][u]BIP39 Checksum Hex:[/u][/b][/color][/cell] [cell][color=green]{bip39_csum_hex}[/color][/cell]
[/table]""".format({
			"bip39_hex": output.get("bip39_hex", ""),
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
[cell][color=white][b][u]BIP39 Hex:[/u][/b][/color][/cell] [cell][/cell]
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
		return
		
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
	panel.add_child(main_vbox)

	var attention_label = Label.new()
	attention_label.text = "**ATTENTION** Write down these 12 words for future wallet recovery and restoration as you will NOT see them again"
	attention_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	attention_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(attention_label)

	var mnemonic_container = PanelContainer.new()
	mnemonic_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(mnemonic_container)

	var mnemonic_label = Label.new()
	mnemonic_label.text = current_wallet_data.get("mnemonic", "")
	mnemonic_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mnemonic_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mnemonic_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mnemonic_container.add_child(mnemonic_label)

	var bottom_container = VBoxContainer.new()
	bottom_container.size_flags_vertical = Control.SIZE_SHRINK_END
	main_vbox.add_child(bottom_container)

	var question_label = Label.new()
	question_label.text = "Do you want to create this wallet?"
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_container.add_child(question_label)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_container.add_child(hbox)

	var yes_button = Button.new()
	yes_button.text = "Yes"
	yes_button.connect("pressed", Callable(self, "_on_popup_yes_pressed"))

	var no_button = Button.new()
	no_button.text = "No"
	no_button.connect("pressed", Callable(self, "_on_popup_close_pressed"))

	var spacer = Control.new()
	spacer.custom_minimum_size.x = 100

	hbox.add_child(no_button)
	hbox.add_child(spacer)
	hbox.add_child(yes_button)
	
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

	var file = FileAccess.open("res://starters/wallet_master_seed.txt", FileAccess.WRITE)
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
	if tabs:
		tabs.current_tab = 1
	print("Wallet and sidechain information saved.")

func _on_popup_close_pressed() -> void:
	if popup_window != null:
		popup_window.queue_free()
		popup_window = null
		get_tree().root.disconnect("size_changed", Callable(self, "_center_popup"))

func _on_hide_button_toggled(button_pressed: bool):
	_toggle_output_visibility(!button_pressed)

func _toggle_output_visibility(is_visible: bool):
	for i in range(1, mnemonic_out.get_child_count()):
		if i != 13 and i != 26:  
			var label = mnemonic_out.get_child(i).get_child(0) as Label
			if label:
				label.visible = is_visible

	var bip39_info_label = bip39_panel.get_node("BIP39Info")
	if bip39_info_label:
		if is_visible:
			# Restore the full content
			update_bip39_panel(current_wallet_data)
		else:
			# Keep only headers visible
			var headers_text = """[table=2]
[cell][color=white][b][u]BIP39 Hex:[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Bin:



[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Checksum:[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]BIP39 Checksum Hex:[/u][/b][/color][/cell] [cell][/cell]
[/table]"""
			bip39_info_label.text = headers_text

	var launch_info_label = launch_panel.get_node("VBoxContainer/LaunchInfo")
	if launch_info_label:
		if is_visible:
			update_launch_panel(current_wallet_data)
		else:
			var headers_text = """[table=2]
[cell][color=white][b][u]HD Key Data:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]Master Key:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=white][b][u]Chain Code:

[/u][/b][/color][/cell] [cell][/cell]
[/table]"""
			launch_info_label.text = headers_text

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
	var file = FileAccess.open("res://starters/wallet_master_seed.txt", FileAccess.WRITE)
	var json_string = JSON.stringify(seed_data)
	file.store_string(json_string)
	file.close()

	# Generate and save sidechain starters
	var sidechain_slots = get_sidechain_info()
	var sidechain_data = wallet.generate_sidechain_starters(result["seed"], result["mnemonic"], sidechain_slots)
	save_sidechain_info(sidechain_data)
	if tabs:
		tabs.current_tab = 1
	print("Wallet and sidechain information saved.")

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
			var filename = "res://starters/sidechain_%s_starter.txt" % slot
			var file = FileAccess.open(filename, FileAccess.WRITE)
			if file:
				file.store_string(JSON.stringify(sidechain_data[key]))
				file.close()
			else:
				print("Failed to save sidechain starter information for slot ", slot)
				
func reset_wallet_tab():
	
	clear_all_output()
	entropy_in.text = ""
	mnemonic_in.text = ""
	current_wallet_data = {}
	hide_button.button_pressed = false
	_toggle_output_visibility(true)
	mnemonic_out.setup_grid()
	current_tab = 0
	
func _on_tab_changed(tab):
	if tab != get_index(): 
		reset_wallet_tab()
