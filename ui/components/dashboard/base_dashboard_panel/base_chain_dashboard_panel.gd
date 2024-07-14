extends PanelContainer
class_name BaseChainDashboardPanel

var chain_provider : ChainProvider
var chain_state    : ChainState

var download_req   : HTTPRequest
var progress_timer : Timer

var cooldown_timer : Timer


@export var drivechain_title_font_size : int = 32
@export var drivechain_descr_font_size : int = 16
@export var drivechain_minimum_height  : int = 64
@export var subchain_title_font_size   : int = 24
@export var subchain_descr_font_size   : int = 12
@export var subchain_minimum_height    : int = 10

@onready var title              : Control = $Margin/Footer/Title
@onready var desc               : Control = $Margin/Footer/VBox/Description
@onready var block_height       : Control = $Margin/Footer/BlockHeight
@onready var secondary_desc     : Control = $Margin/Footer/VBox/SecondaryDescription
@onready var left_indicator     : Control = $LeftColor
@onready var background         : Control = $BackgroundPattern
@onready var action_button      : Control = $Margin/Footer/ActionButton
@onready var description        : Control = $Margin/Footer/VBox/Description
#@onready var auto_mine_button  : Control = $Margin/VBox/Footer/Automine # removed due to signet
@onready var refresh_bmm_button : Control = $Margin/Footer/RefreshBMM
@onready var progress_bar       : Control = $Margin/Footer/ProgressBar
@onready var settings_button    : Control = $Margin/Footer/SettingsButton
@onready var delete_node_button : Control = $Margin/Footer/SettingsButton2
@onready var reset_confirm_scene = load("res://ui/components/settings/reset_confirm_scene.tscn")
var available         : bool = true

var enabled_modulate  : Color
var disabled_modulate : Color


func _ready():
	cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.wait_time = 2.0  # Cooldown period in seconds
	cooldown_timer.one_shot = true  # Timer stops after the time expires
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timer_timeout"))
	Appstate.connect("chain_states_changed", self.update_view)
	enabled_modulate  = modulate
	disabled_modulate = modulate.darkened(0.3)

func connect_signals():
	description_button.pressed.connect(description_dialog.popup)

func _on_cooldown_timer_timeout():
	action_button.disabled = false # Re-enable the button
	action_button.modulate = enabled_modulate # Reset button color to normal

	
func setup(_chain_provider: ChainProvider, _chain_state: ChainState):
	self.chain_provider = _chain_provider
	self.chain_state = _chain_state
	if chain_provider.chain_type == ChainProvider.c_type.MAIN:
		left_indicator.visible = true
		background.visible = true
		title.add_theme_font_size_override("font_size", drivechain_title_font_size)
		description.add_theme_font_size_override("font_size", drivechain_descr_font_size)
		custom_minimum_size.y = drivechain_minimum_height
		action_button.is_drivechain = true
	else:
		left_indicator.visible = false
		background.visible = false
		title.add_theme_font_size_override("font_size", subchain_title_font_size)
		description.add_theme_font_size_override("font_size", subchain_descr_font_size)
		custom_minimum_size.y = subchain_minimum_height
		size.y = subchain_minimum_height
		#content.hide()
		
	action_button.check_state()
	title.text = chain_provider.display_name
	desc.text = chain_provider.description
	description_dialog.get_node("Box/Title").text = title.text
	description_dialog.get_node("Box/Description").text = desc.text
	block_height.visible = chain_state.state == ChainState.c_state.RUNNING
	action_button.text = str(int(_chain_provider.binary_zip_size * 0.000001)) + " mb"
	#download_button.tooltip_text = _chain_provider.download_url
	
	update_view()
	connect_signals()

func update_view():

	if chain_state == null:
		show_unsupported_state()
		return
		
	if not chain_provider.available_for_platform():
		show_unsupported_state()
		return
	
	if not chain_provider.is_ready_for_execution():
		show_download_state()
	elif chain_provider.is_ready_for_execution() and chain_state.state != ChainState.c_state.RUNNING:
		action_button.set_state(ActionButton.RUN)
		if chain_provider.id == 'drivechain' or Appstate.drivechain_running():
			show_executable_state()
		else:
			show_waiting_on_drivechain_state()
	else:
		show_running_state()
		
	block_height.visible = chain_state.state == ChainState.c_state.RUNNING
	block_height.text = 'Block height: %d' % chain_state.height
	
func show_waiting_on_drivechain_state():
	action_button.disabled = true
	#auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	secondary_desc.visible = true
	modulate = enabled_modulate
	
	
func show_running_state():
	action_button.set_state(ActionButton.STOP)
	action_button.disabled = false  # Ensure the button is enabled
	action_button.modulate = enabled_modulate  # Reset button color to indicate active state

	if chain_provider.id == 'drivechain':
		refresh_bmm_button.visible = false
		action_button.theme = load("res://ui/components/dashboard/base_dashboard_panel/drivechain_btn_running.tres")
		get_parent().get_parent().get_node("Label").hide()
	else:
		#refresh_bmm_button.visible = true
		refresh_bmm_button.set_pressed_no_signal(chain_state.refreshbmm)

	# Stop any cooldown timer that might be running since the state is now running
	if not cooldown_timer.is_stopped():
		cooldown_timer.stop()

		
		
func show_executable_state():
	settings_button.disabled = false
	action_button.set_state(ActionButton.RUN)
#	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	modulate = enabled_modulate
	if chain_provider.id == 'drivechain':
		get_parent().get_parent().get_node("Label").show()
	
	
func show_download_state():
	settings_button.disabled = false
#	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	action_button.set_state(ActionButton.DOWNLOAD)
	modulate = enabled_modulate
	
	
func show_unsupported_state():
	#settings_button.disabled = true
	#action_button.hide()
##	auto_mine_button.visible = false
	#refresh_bmm_button.visible = false
	#secondary_desc.visible = true
	#secondary_desc.text = "[i]This sidechain is currently not available for this platform -- try Linux instead.[/i]"
	#modulate = disabled_modulate
	pass
	


func clear_backup_directory(target_backup_path: String) -> void:
	print("\nAttempting to clear backup directory at: ", target_backup_path, "\n")

	var command: String
	var arguments: Array = []
	var output: Array = []
	var exit_code: int

	# Determine the command based on the operating system
	if OS.get_name() == "Windows":
		command = "cmd"
		arguments = ["/c", "rd", "/s", "/q", target_backup_path]  # Use rd to remove directory
	else:  # Assuming Unix-like system
		command = "rm"
		arguments = ["-rf", target_backup_path]  # Use rm to remove, -rf for recursive force

	# Execute the command and capture output
	exit_code = OS.execute(command, arguments, output, true)

	# Check the result
	if exit_code == OK:
		print("Successfully cleared the backup directory: ", target_backup_path, "\n")
	else:
		# Assuming 'output' is an array of strings:
		var output_str := ""
		for line in output:
			output_str += line + "\n"
		output_str = output_str.strip_edges(true, false) # Remove trailing newline



func download():
	print("\nStarting download process...\n")
	print("Chain provider ID: ", chain_provider.id, "\n")

# Check for existing wallet backup before download
	var backup_info = check_for_wallet_backup(chain_provider.id)
	if backup_info["exists"]:
		print("Backup exists. Preparing for restoration...\n")

		# The backup path where the wallet backup is currently located
		var backup_path = backup_info["backup_path"]

		# The original intended location where the wallet should be restored
		var target_path = backup_info["original_path"]
		print("Backup path: ", backup_path, "\n")
		print("Restoration target path: ", target_path, "\n")

		# Ensure directory structure for the target path
		ensure_directory_structure(target_path)
		
		print("Final target path being passed: ", target_path)  
		
		# Move file from backup location to the original intended location
		move_file(backup_path, target_path)
		print("Restoration completed.\n")
	else:
		print("No backup found for restoration.\n")

	#Continue with the original download logic regardless of backup restoration
	print("Setting up download requirements...\n")
	setup_download_requirements()
	print("Initiating download process...\n")
	initiate_download_process()

const BACKUP_DIR_NAME := "wallets_backup"

func check_for_wallet_backup(id):
	print("Checking for wallet backup. ID: ", id)
	var user_data_dir := OS.get_user_data_dir()
	var backup_dir_path := "%s/%s" % [user_data_dir, BACKUP_DIR_NAME]
	var backup_file_path := "%s/%s" % [backup_dir_path, id]  # Use the ID to form the backup file path without assuming an extension.
	
	# Correct usage of DirAccess to check for directories
	var dir_access = DirAccess.open(backup_dir_path)
	if dir_access:
		if dir_access.file_exists(backup_file_path) or dir_access.dir_exists(backup_file_path):
			print("Backup exists at location: ", backup_file_path)
			return {
				"exists": true,
				"backup_path": backup_file_path,
				"original_path": load_wallet_paths_info()[id]  # Load the original path to where the wallet should be restored.
			}
		else:
			print("No backup file or directory found at the specified backup location: ", backup_file_path)
	else:
		print("Failed to access backup directory.")

	return {"exists": false, "backup_path": "", "original_path": ""}

func load_wallet_paths_info():
	print("Loading wallet paths info from: ", WALLET_INFO_PATH)
	var file = FileAccess.open(WALLET_INFO_PATH, FileAccess.ModeFlags.READ)
	if file != null:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			print("Successfully parsed JSON. Data: ", json.data)
			return json.data
		else:
			print("Failed to parse JSON. Error: ", error)
	else:
		print("Failed to open file at path: ", WALLET_INFO_PATH)
	return {}
	
func ensure_directory_structure(target_path: String):
	# Ensure target_path is absolute; adjust logic if necessary.
	if not DirAccess.dir_exists_absolute(target_path.get_base_dir()):
		var error = DirAccess.make_dir_recursive_absolute(target_path.get_base_dir())
		if error != OK:
			print("Failed to create directory structure for: ", target_path)
		else:
			print("Directory structure created for: ", target_path)
	else:
		print("Directory already exists: ", target_path)

#func move_file(source_path: String, target_path: String):
	#var command: String
	#var arguments: PackedStringArray
	#var output = []  # Initialize an array for the output
#
	## Determine the operating system to use the appropriate command
	#print("Source path: ", source_path)
	#print("Target path: ", target_path)
#
	#if OS.get_name() == "Windows":
		#if source_path.ends_with(".mdb"):
			#print(".mdb found")
			## Handle .mdb files as single files
			#command = "cmd"
			#arguments = ["/c", "move", '"' + source_path + '"', '"' + target_path + '"']
			#var result = OS.execute(command, arguments, output, true, false)
			#if result == OK:
				#print("File moved successfully from ", source_path, " to ", target_path)
			#else:
				#print("Failed to move file. Exit code: ", result)
				#for line in output:
					#print(line)  # Print each line of output to diagnose the error
		#else:
			## Windows-specific logic to handle a directory containing multiple files
#
			#print(chain_provider.id)
#
			#var dir = DirAccess.open(source_path)
#
			#if dir:
				#dir.list_dir_begin()
				#var file_name = dir.get_next()
				#while file_name != "":
					#if not dir.current_is_dir(): # Ensure it's a file
						#var full_source_path = source_path + "\\" + file_name
						#var full_target_path = target_path.get_base_dir() + "\\" + file_name
						#
						## Use "cmd /c move" to move the file
						#command = "cmd"
						#arguments = ["/c", "move", '"' + full_source_path + '"', '"' + full_target_path + '"']
						#var result = OS.execute(command, arguments, output, true, false)
						#
						#if result == OK:
							#print("File moved successfully from", full_source_path, " to ", full_target_path)
						#else:
							#print("Failed to move file. Exit code: ", result)
							#for line in output:
								#print(line) # Print each line of output to diagnose the error
					#
					#file_name = dir.get_next()
				#
				#dir.list_dir_end()
			#else:
				#print("Failed to open source directory: ", source_path)
	#else:
		## Use "mv" for Unix-like systems
		#var dir = DirAccess.open(source_path)
		#if dir:
			#dir.list_dir_begin()
			#var file_name = dir.get_next()
			#while file_name != "":
				#if not dir.current_is_dir():  # Ensure it's a file
					#var full_source_path = source_path + "/" + file_name
					#var full_target_path = target_path.get_base_dir() + "/" + file_name
					#command = "mv"
					#arguments = [full_source_path, full_target_path]
					## Execute the command
					#var result = OS.execute(command, arguments, output, true, false)
					#if result == OK:
						#print("File moved successfully from ", full_source_path, " to ", full_target_path)
					#else:
						#print("Failed to move file. Exit code: ", result)
						#for line in output:
							#print(line)  # Print each line of output to diagnose the error
					#break
				#file_name = dir.get_next()
			#dir.list_dir_end()
		#else:
			#print("Failed to open source directory: ", source_path)



#func move_file(source_path: String, target_path: String):
	#var command: String
	#var arguments: PackedStringArray
	#var output = [] # Correctly initialize an array for the output
	## Determine the operating system to use the appropriate command
	#if OS.get_name() == "Windows":
		## On Windows, use "cmd /c move"
		#command = "cmd"
		#arguments = ["/c", "move", source_path, target_path]
	#else:
		## On Unix-like systems, use "mv"
		#command = "mv"
		#arguments = [source_path, target_path]
	#
	## Execute the command
	#var result = OS.execute(command, arguments, output, true, false)
	#if result == OK:
		#print("File moved successfully.")
		#for line in output:
			#print(line) # Print each line of output (if any)
	#else:
		#print("Failed to move file. Exit code: ", result)
		#for line in output:
			#print(line) # Print each line of output to diagnose the error

func move_file(source_path: String, target_path: String):
	var command: String
	var arguments: PackedStringArray
	var output = []
	
	if OS.get_name() == "Windows":
		# Check for specific chain_provider IDs to decide between using 'copy' or 'xcopy'
		if chain_provider.id in ["drivechain", "testchain"]:
			print(chain_provider.id + " wallet detected")
			# Use the 'copy' command for handling individual files like 'wallet.dat'
			command = "cmd"
			arguments = ["/c", "copy", '"' + source_path + '"', '"' + target_path + '"']
		else:
			# Use 'xcopy' for general directory copying
			command = "xcopy"
			source_path = '"' + source_path + '\\*"'
			target_path = '"' + target_path + '"'
			arguments = [source_path, target_path, "/E", "/I", "/Y"]

		# Print the constructed command for debugging
		print("Command to execute:")
		print("Command: ", command)
		print("Arguments: ", ' '.join(arguments))

	else:
		# Assuming Unix-like commands for non-Windows operating systems
		command = "mv"
		arguments = [source_path, target_path]

		# Print the constructed command for debugging
		print("Command to execute:")
		print("Command: ", command, ' '.join(arguments))

	# Execute the command
	var result = OS.execute(command, arguments, output, true)
	if result == OK:
		print("Files moved successfully.")
	else:
		print("Failed to move files. Exit code: ", result)
		for line in output:
			print(line)  # Print each line of output to diagnose the issue


func setup_download_requirements():
	if download_req != null:
		remove_child(download_req)
	
	if progress_timer != null:
		progress_timer.stop()
		remove_child(progress_timer)

func initiate_download_process():
	print("Downloading ", chain_provider.display_name, " from ", chain_provider.download_url)
	download_req = HTTPRequest.new()
	add_child(download_req)
	download_req.request_completed.connect(self._on_download_complete)
	
	var err = download_req.request(chain_provider.download_url)
	if err != OK:
		push_error("An error occurred during download request.")
		return
	
	action_button.disabled = true
	
	progress_timer = Timer.new()
	add_child(progress_timer)
	progress_timer.wait_time = 0.1
	progress_timer.timeout.connect(self._on_download_progress)
	progress_timer.start()
	progress_bar.visible = true
	

func _on_download_progress():
	if download_req != null:
		var bodySize: float = download_req.get_body_size()
		var downloadedBytes: float = download_req.get_downloaded_bytes()
		progress_bar.value = downloadedBytes*100/bodySize
	
	
func _on_download_complete(result, response_code, _headers, body):
	reset_download()
	if result != 0 or response_code != 200:
		print("Could not download ", chain_provider.display_name, ": ", response_code)
		return
		
	print("Downloading ", chain_provider.display_name,  ": OK" )
	var path = chain_provider.base_dir + "/" + chain_provider.id + ".zip"
	var save_game = FileAccess.open(path, FileAccess.WRITE)
	save_game.store_buffer(body)
	save_game.close()
	action_button.disabled = false
	
	unzip_file_and_setup_binary(chain_provider.base_dir, path)
	
	
func unzip_file_and_setup_binary(base_dir: String, zip_path: String):
	var prog = "unzip"
	var args = [zip_path, "-d", base_dir]
	if Appstate.get_platform() == Appstate.platform.WIN:
		prog = "powershell.exe"
		args = ["-Command", 'Expand-Archive -Force ' + zip_path + ' ' + base_dir]


	print("Unzipping ", zip_path, ": ", prog, " ", args, )

	# We used to check for the exit code here. However, unzipping sometimes
	# throw bad errors on symbolic links, but output the files just fine...
	OS.execute(prog, args) 

	chain_provider.write_start_script()
	if Appstate.get_platform() != Appstate.platform.WIN:
		var start_path = ProjectSettings.globalize_path(chain_provider.get_start_path())
		print("chmodding start path: ", start_path)

		var bin_path = ProjectSettings.globalize_path(chain_provider.base_dir + "/" + chain_provider.binary_zip_path)
		print("chmodding bin path: ", bin_path)

		OS.execute("chmod", ["+x", start_path])
		OS.execute("chmod", ["+x", bin_path])

		## This will error on non-zcash chains, but that's OK. Just swallow it.
		#var zside_params_name = "zside-fetch-params.sh"
		#OS.execute("chmod", ["+x", ProjectSettings.globalize_path(chain_provider.base_dir + "/" + zside_params_name)])

	update_view()
	
	
func reset_download():
	remove_child(download_req)
	download_req.queue_free()
	progress_timer.stop()
	
	remove_child(progress_timer)
	progress_timer.queue_free()
	
	
	progress_bar.visible = false
	action_button.set_state(ActionButton.RUN)


func _on_start_button_pressed():
	print("Starting chain: ", chain_provider.id)

	if chain_provider.id != "drivechain":
		var drivechain_state = Appstate.get_drivechain_state()
		assert(drivechain_state != null)
			
		#if await drivechain_state.needs_activation(chain_provider):
			#print("Activating sidechain: ", chain_provider.id)
			#await drivechain_state.request_create_sidechain_proposal(chain_provider)
			
	chain_provider.start_chain()
		
	action_button.set_state(ActionButton.RUN)
	
	
func _on_stop_button_pressed():
	if chain_provider.id == "drivechain":
		for k in Appstate.chain_states:
			Appstate.chain_states[k].stop_chain()
	else:
		chain_state.stop_chain()

	# Reset the button's appearance
	action_button.disabled = false
	action_button.modulate = enabled_modulate

	# Stop the cooldown timer if it's running
	if not cooldown_timer.is_stopped():
		cooldown_timer.stop()
	
	
func _on_automine_toggled(button_pressed):
	chain_state.set_automine(button_pressed)
	
	
func _on_info_button_pressed():
	Appstate.show_chain_provider_info(self.chain_provider)
	
	

func _on_action_button_pressed():
	if cooldown_timer.is_stopped():
		match action_button.state:
			ActionButton.DOWNLOAD:
				download()
			ActionButton.RUN:
				_on_start_button_pressed()
			ActionButton.STOP:
				_on_stop_button_pressed()
		if action_button.state == ActionButton.RUN:
			start_cooldown()  # Only start cooldown if we're attempting to run
	else:
		print("Action is on cooldown. Please wait.")

func start_cooldown():
	cooldown_timer.start() # Start the cooldown timer
	action_button.disabled = true  # Disable the button
	action_button.modulate = disabled_modulate # Grey out the button

func _on_focus_entered():
	if chain_provider.chain_type == ChainProvider.c_type.MAIN: return


func _on_focus_exited():
	if chain_provider.chain_type == ChainProvider.c_type.MAIN: return


func _on_settings_button_pressed():
	Appstate.show_chain_provider_info(chain_provider)


func _on_settings_button_2_pressed():
	print("settings button 2 pressed") # Replace with function body.
	backup_wallet()
	purge()

func _on_settings_button_3_pressed():
	# Create the confirmation dialog on the fly
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to delete your node AND wallet?"
	confirmation_dialog.min_size = Vector2(400, 100)  # Adjust size to your preference
	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()  # Center and show the dialog

	# Connect the 'confirmed' signal to a custom method to handle the confirmation
	confirmation_dialog.connect("confirmed", Callable(self, "_on_confirm_delete_and_purge"))

	# Connect the 'popup_hide' signal to automatically queue_free the dialog after closing
	confirmation_dialog.connect("popup_hide", Callable(confirmation_dialog, "queue_free"))

func _on_confirm_delete_and_purge():
	print("User has confirmed the action.")
	delete_backup()
	purge()

	##print(chain_provider.id) # Replace with function body.
	##var reset_window = reset_confirm_scene.instantiate()
	##get_tree().root.get_node("Main").add_child(reset_window)
	##reset_window.show()  # Call this method if the window is not set to automatically show upon being added to the scene tree.
	##print("Reset window opened")
	#delete_backup()
	#purge()



func _on_reset_everything_window_close_requested() -> void:
	reset_confirm_scene.queue_free()  # This removes the window from the scene tree and frees it
	print("Reset window closed")

const WALLET_INFO_PATH := "user://wallets_backup/wallet_info.json"

func backup_wallet():
	print("Starting backup process for provider: ", chain_provider.id, "\n")
	var backup_dir_path = Appstate.setup_wallets_backup_directory()
	print("Backup directory path: ", backup_dir_path, "\n")

	var provider = chain_provider  # Correctly assign the whole chain_provider object

	var wallet_path: String
	if chain_provider.id == "ethsail":
		wallet_path = Appstate.get_ethsail_wallet_path()
	elif chain_provider.id == "zsail":
		wallet_path = Appstate.get_zsail_wallet_path()
	else:
		var dir_separator = "/" if OS.get_name() != "Windows" else "\\"
		var base_dir = provider.base_dir.replace("/", dir_separator).replace("\\", dir_separator)
		var wallet_dir = (provider.wallet_dir_win if OS.get_name() == "Windows" else provider.wallet_dir_linux)

		wallet_dir = wallet_dir.replace("/", dir_separator).replace("\\", dir_separator)
		if base_dir.ends_with(dir_separator):
			if wallet_dir.begins_with(dir_separator):
				wallet_dir = wallet_dir.substr(1)
		else:
			if not wallet_dir.begins_with(dir_separator):
				wallet_dir = dir_separator + wallet_dir

		wallet_path = base_dir + wallet_dir

	print("Constructed wallet path: ", wallet_path, "\n")

	# Load existing wallet paths info
	var wallet_paths_info = load_existing_wallet_paths_info()

	# Update the dictionary with the new wallet path
	wallet_paths_info[chain_provider.id] = wallet_path

	var command: String
	var arguments: PackedStringArray
	var target_backup_path = "%s/%s" % [backup_dir_path, chain_provider.id.replace("/", "_")]
	var dir_separator = "\\" if OS.get_name() == "Windows" else "/"
	target_backup_path = target_backup_path.replace("/", dir_separator).replace("\\", dir_separator)

	print("Target backup path: ", target_backup_path, "\n")

	var output: Array = []
	print("Determining command based on OS: ", OS.get_name(), "\n")
	match OS.get_name():
		"Windows":
			command = "xcopy"
			arguments = PackedStringArray([wallet_path, target_backup_path + "\\", "/I", "/Q", "/Y"])
		"Linux", "macOS", "FreeBSD":
			command = "cp"
			arguments = PackedStringArray(["-r", wallet_path, target_backup_path])
		_:
			print("OS not supported for direct folder copy.\n")
			return

	print("Executing command: ", command, " with arguments: ", arguments, "\n")
	var result = OS.execute(command, arguments, output, false, false)
	if result == OK:
		print("Successfully backed up wallet for '", chain_provider.id, "' to: ", target_backup_path, "\n")
	else:
		var output_str = Appstate.array_to_string(output)
		print("Failed to back up wallet for ", chain_provider.id, "\n")

	# Save updated wallet paths info to JSON file
	save_wallet_paths_info(wallet_paths_info)
	print("Wallet paths info successfully saved in JSON format.\n")

func load_existing_wallet_paths_info() -> Dictionary:
	var wallet_paths_info = {}
	var file = FileAccess.open(WALLET_INFO_PATH, FileAccess.ModeFlags.READ)
	if file != null:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			wallet_paths_info = json.data
		else:
			print("Failed to parse existing wallet paths JSON. Error: ", error)
	else:
		print("No existing wallet paths JSON file found. Starting with an empty dictionary.")
	return wallet_paths_info

func save_wallet_paths_info(wallet_paths_info: Dictionary) -> void:
	var json_text := JSON.stringify(wallet_paths_info)
	var file := FileAccess.open(WALLET_INFO_PATH, FileAccess.ModeFlags.WRITE)
	if file != null:
		file.store_string(json_text)
		file.flush()
		file.close()
	else:
		print("Failed to open JSON file for writing: ", WALLET_INFO_PATH)

func array_to_string(array: Array) -> String:
	var result = ""
	for line in array:
		result += line + "\n"
	return result

func delete_backup():
	print("Starting deletion process for provider: ", chain_provider.id, "\n")
	var backup_dir_path = Appstate.setup_wallets_backup_directory()
	var target_backup_path = "%s/%s" % [backup_dir_path, chain_provider.id.replace("/", "_")]
	var dir_separator = "\\" if OS.get_name() == "Windows" else "/"
	target_backup_path = target_backup_path.replace("/", dir_separator).replace("\\", dir_separator)

	print("Target backup path for deletion: ", target_backup_path, "\n")

	# Determine the system command based on the OS
	var command: String
	var arguments: PackedStringArray
	var output: Array = []

	match OS.get_name():
		"Windows":
			command = "cmd"
			arguments = PackedStringArray(["/c", "rd", "/s", "/q", target_backup_path])
		"Linux", "macOS", "FreeBSD":
			command = "rm"
			arguments = PackedStringArray(["-rf", target_backup_path])
		_:
			print("OS not supported for direct folder deletion.\n")
			return

	print("Executing deletion command: ", command, " with arguments: ", arguments, "\n")
	var result = OS.execute(command, arguments, output, false, false)
	if result == OK:
		print("Successfully deleted backup for '", chain_provider.id, "' at: ", target_backup_path, "\n")
		# Remove entry from wallet_paths_info
		var wallet_paths_info = load_existing_wallet_paths_info()
		wallet_paths_info.erase(chain_provider.id)
		save_wallet_paths_info(wallet_paths_info)
		print("Successfully removed '", chain_provider.id, "' from wallet paths info.\n")
	else:
		var output_str = array_to_string(output)
		print("Failed to delete backup for ", chain_provider.id, "\n")


	
func _on_button_2_pressed():
	delete_backup()
	purge()
	
func purge():
	print("Button 2 pressed. Chain provider is initialized.")
	# Stop the chain and handle clean-up
	stop_and_cleanup_chain()
	
	# After ensuring the chain has stopped and cleaned up, purge the directory
	await get_tree().create_timer(1.0).timeout  # Wait for the chain to fully stop and clean up
	queue_free()
	purge_directory()
		# Re-loading and re-setting up configurations and state.
	print("Loading version configuration...")
	Appstate.load_version_config()

	print("Loading configuration...")
	Appstate.load_config()

	print("Saving configuration...")
	Appstate.save_config()

	Appstate.load_app_config()

	print("Setting up directories...")
	Appstate.setup_directories()

	print("Setting up configurations...")
	Appstate.setup_confs()

	print("Setting up chain states...")
	Appstate.setup_chain_states()
	
	Appstate.chain_providers_changed.emit()
	
	Appstate.start_chain_states()


func stop_and_cleanup_chain():
	if chain_provider:
		print("Attempting to stop and clean up the chain for provider: ", chain_provider.id)
		# Directly access the chain state using the chain_provider's id
		if chain_provider.id in Appstate.chain_states:
			var chain_state = Appstate.chain_states[chain_provider.id]
			if chain_state:
				chain_state.stop_chain()
				await get_tree().create_timer(1.0).timeout  # Allow time for any background operations to complete
				if is_instance_valid(chain_state):
					remove_child(chain_state)  # This will remove the chain state from the scene tree
					chain_state.cleanup()  # Perform any necessary cleanup operations


					print("Chain stopped and node removed for provider:", chain_provider.display_name)
				else:
					print("Chain state is no longer valid after stopping.")
			else:
				print("Chain state not found in AppState.chain_states for id: ", chain_provider.id)
		else: 
			print("Chain provider id not found in AppState.chain_states: ", chain_provider.id)
	else:
		print("stop_and_cleanup_chain called but no chain provider available.")
		
func purge_directory():
	# Check if chain_provider.id is "ethsail" or "zsail"
	if chain_provider.id == "ethsail":
		Appstate.delete_ethereum_directory()
	elif chain_provider.id == "zsail":
		# Perform a different action for "zsail"
		Appstate.delete_zcash_directory()  # Assuming there's a corresponding function

	print("Preparing to purge directory for provider: ", chain_provider.display_name)
	var directory_text = ProjectSettings.globalize_path(chain_provider.base_dir)
	print(directory_text + " is the directory txt")
	
	if OS.get_name() == "Windows":
		directory_text = directory_text.replace("/", "\\")  # Windows-style separators
	
	Appstate.purge(directory_text)
	print("Directory purged: " + directory_text)
