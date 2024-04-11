extends PanelContainer
class_name BaseChainDashboardPanel

var chain_provider : ChainProvider
var chain_state    : ChainState

var download_req   : HTTPRequest
var progress_timer : Timer

var cooldown_timer : Timer


@export var drivechain_title_font_size : int = 32
@export var drivechain_descr_font_size : int = 16
@export var drivechain_minimum_height  : int = 100
@export var subchain_title_font_size   : int = 20
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
	block_height.visible = chain_state.state == ChainState.c_state.RUNNING
	action_button.text = str(int(_chain_provider.binary_zip_size * 0.000001)) + " mb"
	#download_button.tooltip_text = _chain_provider.download_url
	
	update_view()
	
	
func update_view():
	block_height.visible = chain_state.state == ChainState.c_state.RUNNING
	block_height.text = 'Block height: %d' % chain_state.height

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
		refresh_bmm_button.visible = true
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
	settings_button.disabled = true
	action_button.hide()
#	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	secondary_desc.visible = true
	secondary_desc.text = "[i]This sidechain is currently not available for this platform -- try Linux instead.[/i]"
	modulate = disabled_modulate
	
const WALLET_INFO_PATH = "user://wallets_backup/wallet_info.json"

#func clear_backup_directory(target_backup_path: String) -> void:
	#print("\nAttempting to clear backup directory at: ", target_backup_path, "\n")
#
	#var command: String
	#var arguments: Array = []
	#var output: Array = []
	#var exit_code: int
#
	## Determine the command based on the operating system
	#if OS.get_name() == "Windows":
		#command = "cmd"
		#arguments = ["/c", "rd", "/s", "/q", target_backup_path]  # Use rd to remove directory
	#else:  # Assuming Unix-like system
		#command = "rm"
		#arguments = ["-rf", target_backup_path]  # Use rm to remove, -rf for recursive force
#
	## Execute the command and capture output
	#exit_code = OS.execute(command, arguments, output, true)
#
	## Check the result
	#if exit_code == OK:
		#print("Successfully cleared the backup directory: ", target_backup_path, "\n")
	#else:
		## Assuming 'output' is an array of strings:
		#var output_str := ""
		#for line in output:
			#output_str += line + "\n"
		#output_str = output_str.strip_edges(true, false) # Remove trailing newline
#


func download():
	print("\nStarting download process...\n")
	print("Chain provider ID: ", chain_provider.id, "\n")

	# Check for existing wallet backup before download
	#var backup_info = check_for_wallet_backup(chain_provider.id)
	#if backup_info["exists"]:
		#print("Backup exists. Preparing for restoration...\n")
#
		## The backup path where the wallet backup is currently located
		#var backup_path = backup_info["backup_path"]
#
		## The original intended location where the wallet should be restored
		#var target_path = backup_info["original_path"]
		#print("Backup path: ", backup_path, "\n")
		#print("Restoration target path: ", target_path, "\n")
#
		## Ensure directory structure for the target path
		#ensure_directory_structure(target_path)
#
		## Move file from backup location to the original intended location
		#move_file(backup_path, target_path)
		#print("Restoration completed.\n")
	#else:
		#print("No backup found for restoration.\n")

	# Continue with the original download logic regardless of backup restoration
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

func move_file(source_path: String, target_path: String):
	var command: String
	var arguments: PackedStringArray
	var output = [] # Correctly initialize an array for the output
	# Determine the operating system to use the appropriate command
	if OS.get_name() == "Windows":
		# On Windows, use "cmd /c move"
		command = "cmd"
		arguments = ["/c", "move", source_path, target_path]
	else:
		# On Unix-like systems, use "mv"
		command = "mv"
		arguments = [source_path, target_path]
	
	# Execute the command
	var result = OS.execute(command, arguments, output, true, false)
	if result == OK:
		print("File moved successfully.")
		for line in output:
			print(line) # Print each line of output (if any)
	else:
		print("Failed to move file. Exit code: ", result)
		for line in output:
			print(line) # Print each line of output to diagnose the error

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
	
	
# A prior implementation of this unzipped through using ZIPReader. 
# However, this swallowed file types and permissions. Instead, we 
# execute a program that handles this for us. 
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
