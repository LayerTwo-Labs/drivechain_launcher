extends TabContainer
@onready var blocker = $AdvancedBlocker
@onready var advanced_button = $VBoxContainer/HBoxContainer/Advanced
@onready var create_wallet_button = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/Create
@onready var return_button = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/Return
@onready var entropy_in = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer/LineEdit
@onready var mnemonic_out = $MarginContainer2/VBoxContainer/BoxContainer/GridContainer
@onready var bip39_panel = $MarginContainer2/VBoxContainer/BoxContainer/HBoxContainer2/BIP39

func _ready():
	create_wallet_button.connect("pressed", Callable(self, "_on_create_wallet_button_pressed"))
	return_button.connect("pressed", Callable(self, "_on_return_button_pressed"))
	entropy_in.connect("text_changed", Callable(self, "_on_entropy_in_changed"))
	
	# Create a RichTextLabel for BIP39 information
	var bip39_info_label = RichTextLabel.new()
	bip39_info_label.name = "BIP39Info"
	bip39_info_label.bbcode_enabled = true
	bip39_info_label.fit_content = false
	bip39_info_label.scroll_active = true
	bip39_info_label.size_flags_horizontal = SIZE_EXPAND_FILL
	bip39_info_label.size_flags_vertical = SIZE_EXPAND_FILL
	bip39_info_label.custom_minimum_size = Vector2(0, 200)  # Adjust this value as needed
	bip39_panel.add_child(bip39_info_label)
	
	setup_bip39_headers()

func setup_bip39_headers():
	var bip39_info_label = bip39_panel.get_node("BIP39Info")
	if bip39_info_label:
		var headers_text = """[table=2]
[cell][color=orange][b][u]BIP39 Hex:[/u][/b][/color][/cell] [cell][/cell]
[cell][color=orange][b][u]BIP39 Bin:




[/u][/b][/color][/cell] [cell][/cell]
[cell][color=orange][b][u]HD Key Data:

[/u][/b][/color][/cell] [cell][/cell]
[cell][color=orange][b][u]BIP39 Checksum:[/u][/b][/color][/cell] [cell][/cell]
[cell][color=orange][b][u]BIP39 Checksum Hex:[/u][/b][/color][/cell] [cell][/cell]
[/table]"""
		bip39_info_label.text = headers_text

func _on_create_wallet_button_pressed():
	current_tab = 1

func _on_return_button_pressed():
	current_tab = 0
func _create_wallet(input: String):
	if input.strip_edges().is_empty():
		clear_all_output()
		return
	var Bitcoin = BitcoinWallet.new()
	var output = Bitcoin.generate_wallet(input)
	if not output.has("error"):
		populate_grid(output["mnemonic"], output["bip39_bin"], output["bip39_csum"])
		update_bip39_panel(output)
	else:
		clear_all_output()

func clear_all_output():
	# Clear grid, but not headers
	for i in range(1, mnemonic_out.get_child_count()):
		if i != 13 and i != 26:  # Skip BIN and INDEX headers
			var label = mnemonic_out.get_child(i).get_child(0) as Label
			if label:
				label.text = ""
	
	# Clear BIP39 info
	var bip39_info_label = bip39_panel.get_node("BIP39Info")
	if bip39_info_label:
		bip39_info_label.text = ""
		
	setup_bip39_headers()

func _on_entropy_in_changed(new_text: String):
	_create_wallet(new_text)


func update_bip39_panel(output: Dictionary):
	var bip39_info_label = bip39_panel.get_node("BIP39Info")
	if bip39_info_label:
		# Format BIP39 binary in groups of four
		var formatted_bin = ""
		var bin_string = output.get("bip39_bin", "")
		for i in range(0, bin_string.length(), 4):
			formatted_bin += bin_string.substr(i, 4) + " "
		formatted_bin = formatted_bin.strip_edges()
		
		# Append checksum to BIP39 binary and color it blue
		var checksum = output.get("bip39_csum", "")
		var formatted_checksum = ""
		for i in range(0, checksum.length(), 4):
			formatted_checksum += checksum.substr(i, 4) + " "
		formatted_checksum = formatted_checksum.strip_edges()
		
		var full_bin = formatted_bin + " [color=green]" + formatted_checksum + "[/color]"

		var info_text = """[table=2]
[cell][color=orange][b][u]BIP39 Hex:[/u][/b][/color][/cell] [cell]{bip39_hex}[/cell]
[cell][color=orange][b][u]BIP39 Bin:[/u][/b][/color][/cell] [cell]{bip39_bin}[/cell]
[cell][color=orange][b][u]HD Key Data:[/u][/b][/color][/cell] [cell]{hd_key_data}[/cell]
[cell][color=orange][b][u]BIP39 Checksum:[/u][/b][/color][/cell] [cell][color=green]{bip39_csum}[/color][/cell]
[cell][color=orange][b][u]BIP39 Checksum Hex:[/u][/b][/color][/cell] [cell][color=green]{bip39_csum_hex}[/color][/cell]
[/table]""".format({
			"bip39_hex": output.get("bip39_hex", ""),
			"bip39_bin": full_bin,
			"hd_key_data": output.get("hd_key_data", ""),
			"bip39_csum": formatted_checksum,
			"bip39_csum_hex": output.get("bip39_csum_hex", "")
		})
		bip39_info_label.text = info_text

func binary_to_integer(binary: String) -> int:
	return ("0b" + binary).bin_to_int()

func populate_grid(mnemonic: String, bip39_bin: String, bip39_csum: String):
	var words = mnemonic.split(" ")
	var bin_chunks = []
	# Split bip39_bin into 11-character chunks
	for i in range(0, bip39_bin.length(), 11):
		bin_chunks.append(bip39_bin.substr(i, 11))
	
	# Populate the grid
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
					if i == 11:  # Last BIN cell
						bin_label.text = bin_chunks[i] + bip39_csum
					else:
						bin_label.text = bin_chunks[i]
					index_label.text = str(binary_to_integer(bin_chunks[i]))
				else:
					print("Labels not found for cell ", i)
			else:
				print("Panel not found for index ", i)
	mnemonic_out.queue_redraw()
