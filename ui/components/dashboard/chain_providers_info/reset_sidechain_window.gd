extends ColorRect
#
#@onready var label = $CenterContainer/Panel/MarginContainer/VBoxContainer/Label
#@onready var button = $CenterContainer/Panel/MarginContainer/VBoxContainer/Button
#@onready var label2 = $CenterContainer/Panel/MarginContainer/VBoxContainer/Label2
#@onready var button2 = $CenterContainer/Panel/MarginContainer/VBoxContainer/Button2
#
#var chain_provider: ChainProvider
#
#func setup(_chain_provider: ChainProvider):
	#chain_provider = _chain_provider
	#
	#if label:
		#label.text = "Choose \"Reset and backup " + chain_provider.display_name + "\" to get a fresh install of " + chain_provider.display_name + " and backup your wallet."
		#
	#if button:
		#button.text = "Reset and backup " + chain_provider.display_name 
		#
	#if label2: 
		#label2.text = "Choose \"Reset " + chain_provider.display_name + "\" to get a fresh install of " + chain_provider.display_name + " and delete your wallet."
#
	#
	#
	#if button2:
		#button2.text = "Reset " + chain_provider.display_name
#
#func _ready():
	## Ensure chain_provider is initialized before calling setup
	#setup(chain_provider)
#
#const WALLET_INFO_PATH := "user://wallets_backup/wallet_info.json"
#
#func backup_wallet():
	#print("Starting backup process for provider: ", chain_provider.id, "\n")
	#var backup_dir_path = Appstate.setup_wallets_backup_directory()
	#print("Backup directory path: ", backup_dir_path, "\n")
#
	#var provider = chain_provider  # Correctly assign the whole chain_provider object
#
	#var wallet_path: String
	#if chain_provider.id == "ethsail":
		#wallet_path = Appstate.get_ethsail_wallet_path()
	#elif chain_provider.id == "zsail":
		#wallet_path = Appstate.get_zsail_wallet_path()
	#else:
		#var dir_separator = "/" if OS.get_name() != "Windows" else "\\"
		#var base_dir = provider.base_dir.replace("/", dir_separator).replace("\\", dir_separator)
		#var wallet_dir = (provider.wallet_dir_win if OS.get_name() == "Windows" else provider.wallet_dir_linux)
#
		#wallet_dir = wallet_dir.replace("/", dir_separator).replace("\\", dir_separator)
		#if base_dir.ends_with(dir_separator):
			#if wallet_dir.begins_with(dir_separator):
				#wallet_dir = wallet_dir.substr(1)
		#else:
			#if not wallet_dir.begins_with(dir_separator):
				#wallet_dir = dir_separator + wallet_dir
#
		#wallet_path = base_dir + wallet_dir
#
	#print("Constructed wallet path: ", wallet_path, "\n")
#
	## Load existing wallet paths info
	#var wallet_paths_info = load_existing_wallet_paths_info()
#
	## Update the dictionary with the new wallet path
	#wallet_paths_info[chain_provider.id] = wallet_path
#
	#var command: String
	#var arguments: PackedStringArray
	#var target_backup_path = "%s/%s" % [backup_dir_path, chain_provider.id.replace("/", "_")]
	#var dir_separator = "\\" if OS.get_name() == "Windows" else "/"
	#target_backup_path = target_backup_path.replace("/", dir_separator).replace("\\", dir_separator)
#
	#print("Target backup path: ", target_backup_path, "\n")
#
	#var output: Array = []
	#print("Determining command based on OS: ", OS.get_name(), "\n")
	#match OS.get_name():
		#"Windows":
			#command = "xcopy"
			#arguments = PackedStringArray([wallet_path, target_backup_path + "\\", "/I", "/Q", "/Y"])
		#"Linux", "macOS", "FreeBSD":
			#command = "cp"
			#arguments = PackedStringArray(["-r", wallet_path, target_backup_path])
		#_:
			#print("OS not supported for direct folder copy.\n")
			#return
#
	#print("Executing command: ", command, " with arguments: ", arguments, "\n")
	#var result = OS.execute(command, arguments, output, false, false)
	#if result == OK:
		#print("Successfully backed up wallet for '", chain_provider.id, "' to: ", target_backup_path, "\n")
	#else:
		#var output_str = Appstate.array_to_string(output)
		#print("Failed to back up wallet for ", chain_provider.id, "\n")
#
	## Save updated wallet paths info to JSON file
	#save_wallet_paths_info(wallet_paths_info)
	#print("Wallet paths info successfully saved in JSON format.\n")
#
#func load_existing_wallet_paths_info() -> Dictionary:
	#var wallet_paths_info = {}
	#var file = FileAccess.open(WALLET_INFO_PATH, FileAccess.ModeFlags.READ)
	#if file != null:
		#var json_text = file.get_as_text()
		#file.close()
		#var json = JSON.new()
		#var error = json.parse(json_text)
		#if error == OK:
			#wallet_paths_info = json.data
		#else:
			#print("Failed to parse existing wallet paths JSON. Error: ", error)
	#else:
		#print("No existing wallet paths JSON file found. Starting with an empty dictionary.")
	#return wallet_paths_info
#
#func save_wallet_paths_info(wallet_paths_info: Dictionary) -> void:
	#var json_text := JSON.stringify(wallet_paths_info)
	#var file := FileAccess.open(WALLET_INFO_PATH, FileAccess.ModeFlags.WRITE)
	#if file != null:
		#file.store_string(json_text)
		#file.flush()
		#file.close()
	#else:
		#print("Failed to open JSON file for writing: ", WALLET_INFO_PATH)
#
#func array_to_string(array: Array) -> String:
	#var result = ""
	#for line in array:
		#result += line + "\n"
	#return result
#
#func delete_backup():
	#print("Starting deletion process for provider: ", chain_provider.id, "\n")
	#var backup_dir_path = Appstate.setup_wallets_backup_directory()
	#var target_backup_path = "%s/%s" % [backup_dir_path, chain_provider.id.replace("/", "_")]
	#var dir_separator = "\\" if OS.get_name() == "Windows" else "/"
	#target_backup_path = target_backup_path.replace("/", dir_separator).replace("\\", dir_separator)
#
	#print("Target backup path for deletion: ", target_backup_path, "\n")
#
	## Determine the system command based on the OS
	#var command: String
	#var arguments: PackedStringArray
	#var output: Array = []
#
	#match OS.get_name():
		#"Windows":
			#command = "cmd"
			#arguments = PackedStringArray(["/c", "rd", "/s", "/q", target_backup_path])
		#"Linux", "macOS", "FreeBSD":
			#command = "rm"
			#arguments = PackedStringArray(["-rf", target_backup_path])
		#_:
			#print("OS not supported for direct folder deletion.\n")
			#return
#
	#print("Executing deletion command: ", command, " with arguments: ", arguments, "\n")
	#var result = OS.execute(command, arguments, output, false, false)
	#if result == OK:
		#print("Successfully deleted backup for '", chain_provider.id, "' at: ", target_backup_path, "\n")
		## Remove entry from wallet_paths_info
		#var wallet_paths_info = load_existing_wallet_paths_info()
		#wallet_paths_info.erase(chain_provider.id)
		#save_wallet_paths_info(wallet_paths_info)
		#print("Successfully removed '", chain_provider.id, "' from wallet paths info.\n")
	#else:
		#var output_str = array_to_string(output)
		#print("Failed to delete backup for ", chain_provider.id, "\n")
#
#
#
#func _on_button_pressed():	
	#print("button 1 pressd")
	#backup_wallet()
	#purge()
	#
	#
#func _on_button_2_pressed():
	#delete_backup()
	#purge()
	#
#func purge():
	#print("Button 2 pressed. Chain provider is initialized.")
	## Stop the chain and handle clean-up
	#stop_and_cleanup_chain()
	#
	## After ensuring the chain has stopped and cleaned up, purge the directory
	#await get_tree().create_timer(1.0).timeout  # Wait for the chain to fully stop and clean up
	#queue_free()
	#purge_directory()
		## Re-loading and re-setting up configurations and state.
	#print("Loading version configuration...")
	#Appstate.load_version_config()
#
	#print("Loading configuration...")
	#Appstate.load_config()
#
	#print("Saving configuration...")
	#Appstate.save_config()
#
	#Appstate.load_app_config()
#
	#print("Setting up directories...")
	#Appstate.setup_directories()
#
	#print("Setting up configurations...")
	#Appstate.setup_confs()
#
	#print("Setting up chain states...")
	#Appstate.setup_chain_states()
	#
	#Appstate.chain_providers_changed.emit()
	#
	#Appstate.start_chain_states()
#
#
#func stop_and_cleanup_chain():
	#if chain_provider:
		#print("Attempting to stop and clean up the chain for provider: ", chain_provider.id)
		## Directly access the chain state using the chain_provider's id
		#if chain_provider.id in Appstate.chain_states:
			#var chain_state = Appstate.chain_states[chain_provider.id]
			#if chain_state:
				#chain_state.stop_chain()
				#await get_tree().create_timer(1.0).timeout  # Allow time for any background operations to complete
				#if is_instance_valid(chain_state):
					#remove_child(chain_state)  # This will remove the chain state from the scene tree
					#chain_state.cleanup()  # Perform any necessary cleanup operations
#
#
					#print("Chain stopped and node removed for provider:", chain_provider.display_name)
				#else:
					#print("Chain state is no longer valid after stopping.")
			#else:
				#print("Chain state not found in AppState.chain_states for id: ", chain_provider.id)
		#else: 
			#print("Chain provider id not found in AppState.chain_states: ", chain_provider.id)
	#else:
		#print("stop_and_cleanup_chain called but no chain provider available.")
		#
#func purge_directory():
	## Check if chain_provider.id is "ethsail" or "zsail"
	#if chain_provider.id == "ethsail":
		#Appstate.delete_ethereum_directory()
	#elif chain_provider.id == "zsail":
		## Perform a different action for "zsail"
		#Appstate.delete_zcash_directory()  # Assuming there's a corresponding function
#
	#print("Preparing to purge directory for provider: ", chain_provider.display_name)
	#var directory_text = ProjectSettings.globalize_path(chain_provider.base_dir)
	#print(directory_text + " is the directory txt")
	#
	#if OS.get_name() == "Windows":
		#directory_text = directory_text.replace("/", "\\")  # Windows-style separators
	#
	#Appstate.purge(directory_text)
	#print("Directory purged: " + directory_text)
#
#
#
#func _on_center_container_gui_input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#queue_free()
