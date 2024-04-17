extends Node2D

enum platform { LINUX, MAC, WIN, UNSUPPORTED }

const DEFAULT_CHAIN_PROVIDERS_PATH : String = "res://chain_providers.cfg"
const CHAIN_PROVIDERS_PATH         : String = "user://chain_providers.cfg"
const APP_CONFIG_PATH              : String = "user://app.cfg"
const VERSION_CONFIG               : String = "res://version.cfg"

const DRIVENET_NODE                : String = "172.105.148.135"

@onready var chain_state           : Resource = preload("res://models/chain_state.tscn")
@onready var chain_provider_info   : Resource = preload("res://ui/components/dashboard/chain_providers_info/chain_provider_info.tscn")
#@onready var z_params_modal        : Resource = preload("res://ui/components/dashboard/z_params_modal/z_params_modal.tscn")

var chain_providers_config : ConfigFile
var app_config             : ConfigFile
var version_config         : ConfigFile

var chain_providers        : Dictionary = {}
var chain_states           : Dictionary = {}
var ethsail_pid: int = -1


signal chain_providers_changed
signal chain_states_changed

func _ready():
	if Appstate.get_platform() == platform.UNSUPPORTED:
		push_error("Unsupported platform")
		get_tree().quit()

	load_app_config()
	load_version_config()
	load_config()
	save_config()
	setup_directories()
	setup_confs()
	setup_chain_states()

	chain_providers_changed.emit()

	start_chain_states()
	create_cleanup_batch_script()
	#backup_wallets()
#
	#print("Starting backup process...\n")
	#var backup_dir_path = setup_wallets_backup_directory()
	#print("Backup directory path: ", backup_dir_path, "\n")
#
	#var wallet_paths_info = {}
	#print("Enumerating chain providers...\n")
#
	#for id in chain_providers.keys():
		#print("--------------------------------Processing provider with ID: ", id, "----------------------------------------------\n")
		#var provider = chain_providers[id]
#
		#var wallet_path: String
		#if id == "ethsail":
			## Dynamically construct the wallet path for "ethsail" to ensure it works for any user.
			#wallet_path = get_ethsail_wallet_path()
		#elif id == "zsail":
			## Dynamically construct the wallet path for "zsail" to ensure it works for any user.
			#wallet_path = get_zsail_wallet_path()
		#else:
			## Constructing the wallet path for other providers directly from configuration
			#var dir_separator = "/" if OS.get_name() != "Windows" else "\\"
			#var base_dir = provider.base_dir.replace("/", dir_separator).replace("\\", dir_separator)
			#var wallet_dir = (provider.wallet_dir_win if OS.get_name() == "Windows" else provider.wallet_dir_linux)
#
			## Check if wallet_dir starts with a slash, and add one if missing
			#if not wallet_dir.begins_with("/") and not wallet_dir.begins_with("\\"):
				#wallet_dir = dir_separator + wallet_dir
#
			## Replace slashes in wallet_dir with the appropriate separator
			#wallet_dir = wallet_dir.replace("/", dir_separator).replace("\\", dir_separator)
#
			#wallet_path = base_dir + wallet_dir
#
		#print("Constructed wallet path: ", wallet_path, "\n")
				## Save original path info
		#wallet_paths_info[id] = wallet_path
#
		## Determine the system command based on the OS
		#var command: String
		#var arguments: PackedStringArray
		#var target_backup_path = "%s/%s" % [backup_dir_path, id.replace("/", "_")]
		#if OS.get_name() == "Windows":
			#target_backup_path = target_backup_path.replace("/", "\\")
		#print("Target backup path: ", target_backup_path, "\n")
		#
				### Check if the backup directory already exists
		##var dir_access = DirAccess.open(backup_dir_path)
		##if dir_access.dir_exists(target_backup_path):
			##print("Existing backup found. Clearing the backup directory...\n")
			##var remove_result = dir_access.remove(target_backup_path)
			##if remove_result != OK:
				##print("Failed to remove existing backup directory: ", target_backup_path, "\n")
				##continue
				##
		#var output: Array = []
		#print("Determining command based on OS: ", OS.get_name(), "\n")
		#match OS.get_name():
			#"Windows":
				#command = "xcopy"
				#arguments = PackedStringArray([wallet_path, target_backup_path + "\\", "/E", "/I", "/Q"])
			#"Linux", "macOS", "FreeBSD":
				#command = "cp"
				#arguments = PackedStringArray(["-r", wallet_path, target_backup_path])
			#_:
				#print("OS not supported for direct folder copy.\n")
				#return
#
		#print("Executing command: ", command, " with arguments: ", arguments, "\n")
		## Execute the command
		#var result = OS.execute(command, arguments, output, false, false)
		#if result == OK:
			#print("Successfully backed up wallet for '", id, "' to: ", target_backup_path, "\n")
		#else:
			#var output_str = array_to_string(output)
			#print("Failed to back up wallet for ", id, "\n")

const WALLET_INFO_PATH := "user://wallets_backup/wallet_info.json"

func backup_wallets():
	
	print("Starting backup process...\n")
	var backup_dir_path = setup_wallets_backup_directory()
	print("Backup directory path: ", backup_dir_path, "\n")

	var wallet_paths_info = {}
	print("Enumerating chain providers...\n")

	for id in chain_providers.keys():
		print("--------------------------------Processing provider with ID: ", id, "----------------------------------------------\n")
		var provider = chain_providers[id]

		var wallet_path: String
		if id == "ethsail":
			# Dynamically construct the wallet path for "ethsail" to ensure it works for any user.
			wallet_path = get_ethsail_wallet_path()
		elif id == "zsail":
			# Dynamically construct the wallet path for "zsail" to ensure it works for any user.
			wallet_path = get_zsail_wallet_path()
		else:
			# Constructing the wallet path for other providers directly from configuration
			var dir_separator = "/" if OS.get_name() != "Windows" else "\\"
			var base_dir = provider.base_dir.replace("/", dir_separator).replace("\\", dir_separator)
			var wallet_dir = (provider.wallet_dir_win if OS.get_name() == "Windows" else provider.wallet_dir_linux)

			# Check if wallet_dir starts with a slash, and add one if missing
			if not wallet_dir.begins_with("/") and not wallet_dir.begins_with("\\"):
				wallet_dir = dir_separator + wallet_dir

			# Replace slashes in wallet_dir with the appropriate separator
			wallet_dir = wallet_dir.replace("/", dir_separator).replace("\\", dir_separator)

			wallet_path = base_dir + wallet_dir

		print("Constructed wallet path: ", wallet_path, "\n")
				# Save original path info
		wallet_paths_info[id] = wallet_path

		# Determine the system command based on the OS
		var command: String
		var arguments: PackedStringArray
		var target_backup_path = "%s/%s" % [backup_dir_path, id.replace("/", "_")]
		if OS.get_name() == "Windows":
			target_backup_path = target_backup_path.replace("/", "\\")
		print("Target backup path: ", target_backup_path, "\n")
		
		var output: Array = []
		print("Determining command based on OS: ", OS.get_name(), "\n")
		match OS.get_name():
			"Windows":
				command = "xcopy"
				arguments = PackedStringArray([wallet_path, target_backup_path + "\\", "/E", "/I", "/Q"])
			"Linux", "macOS", "FreeBSD":
				command = "cp"
				arguments = PackedStringArray(["-r", wallet_path, target_backup_path])
			_:
				print("OS not supported for direct folder copy.\n")
				return

		print("Executing command: ", command, " with arguments: ", arguments, "\n")
		# Execute the command
		var result = OS.execute(command, arguments, output, false, false)
		if result == OK:
			print("Successfully backed up wallet for '", id, "' to: ", target_backup_path, "\n")
		else:
			var output_str = array_to_string(output)
			print("Failed to back up wallet for ", id, "\n")
	# After backing up all wallets, save the wallet_paths_info dictionary for later restoration
	print("Saving wallet paths info to JSON file.\n")
	var json_text := JSON.stringify(wallet_paths_info)
	var file := FileAccess.open(WALLET_INFO_PATH, FileAccess.ModeFlags.WRITE)
	if file != null:
		file.store_string(json_text)
		file.flush() # Make sure data is written to disk
		file.close()
		print("Wallet paths info successfully saved in JSON format.\n")
	else:
		print("Failed to open JSON file for writing: ", WALLET_INFO_PATH, "\n")

func array_to_string(array: Array) -> String:
	var result: String = ""
	for i in array:
		result += str(i) + "\n"
	return result.strip_edges(true, false)

func get_ethsail_wallet_path() -> String:
	var home_dir_path: String
	if OS.get_name() in ["Linux", "macOS"]:
		home_dir_path = OS.get_environment("HOME")
		return "%s/.ethereum/keystore" % home_dir_path
	else: # Assuming Windows
		home_dir_path = OS.get_environment("USERPROFILE")
		return "%s\\AppData\\Roaming\\Ethereum\\keystore" % home_dir_path

func get_zsail_wallet_path() -> String:
	var os_name := OS.get_name()
	var zsail_provider = chain_providers["zsail"]
	var home_dir_path : String
	match os_name:
		"Linux":
			home_dir_path = OS.get_environment("HOME") + "/" + zsail_provider.wallet_dir_linux
		"macOS":
			home_dir_path = OS.get_environment("HOME") + "/" + zsail_provider.wallet_dir_mac
		_:
			return "Error: Unsupported OS"
	return home_dir_path


func get_keystore_path() -> String:
	var home_dir: String
	if OS.get_name() == "Windows":
		home_dir = OS.get_environment("USERPROFILE")
	else: # Assuming Unix-like for anything not Windows
		home_dir = OS.get_environment("HOME")

	# Construct the keystore path based on the platform
	var keystore_path: String
	if OS.get_name() == "Windows":
		# On Windows, Ethereum wallets might be stored in a location like this, but adjust as needed
		keystore_path = "%s/AppData/Roaming/Ethereum/keystore" % home_dir
	else:
		# On Unix-like systems, it's often directly under the user's home directory
		keystore_path = "%s/.ethereum/keystore" % home_dir

	return keystore_path

func load_app_config():

	DisplayServer.window_set_title("Drivechain Launcher")
	var dpi = DisplayServer.screen_get_dpi()
	var scale_factor: float = clampf(snappedf(dpi * 0.01, 0.1), 1, 2)

	app_config = ConfigFile.new()
	var err = app_config.load(APP_CONFIG_PATH)
	if err != OK:
		app_config.set_value("", "scale_factor", scale_factor)
		app_config.save(APP_CONFIG_PATH)
	else:
		scale_factor = app_config.get_value("", "scale_factor", scale_factor)

	update_display_scale(scale_factor)

func update_display_scale(scale_factor: float):
	scale_factor = clampf(scale_factor, 1, 2)
	var screen_size = DisplayServer.screen_get_size(0)
	var new_screen_size = Vector2i(screen_size.x / 2, screen_size.y / 2)
	DisplayServer.window_set_size(new_screen_size)
	get_tree().root.set_content_scale_factor(scale_factor)

	app_config = ConfigFile.new()
	app_config.load(APP_CONFIG_PATH)
	app_config.set_value("", "scale_factor", scale_factor)
	app_config.save(APP_CONFIG_PATH)


func purge_except_backup(base_dir: String, keep_dir_name: String):
	delete_zcash_directory()
	delete_ethereum_directory()
	var dir = DirAccess.open(base_dir)
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename != keep_dir_name:
				var full_path = base_dir + "/" + filename  # Corrected path concatenation
				if dir.current_is_dir():
					purge_except_backup(full_path, "")
					dir.remove(full_path)  # Remove the directory after clearing it
				else:
					dir.remove(full_path)  # Directly remove file
			filename = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: %s" % base_dir)


func delete_ethereum_directory():
	var os_name = OS.get_name()
	var command = ""
	var arguments = PackedStringArray()
	var output = Array()
	var error_output = Array()
	var home_path = OS.get_environment("HOME") if OS.get_name() == "Linux" else OS.get_environment("USERPROFILE") # X11 is Linux
	var ethereum_path = home_path + "/.ethereum" if OS.get_name() == "Linux" else home_path + "\\.ethereum"

	if os_name == "Windows":
		command = "cmd.exe"
		arguments.push_back("/C")
		var deletion_command = "rmdir /s /q \"" + ethereum_path + "\""
		arguments.push_back(deletion_command)
	elif os_name == "Linux":
		command = "sh"
		arguments.push_back("-c")
		var deletion_command = "rm -rf \"" + ethereum_path + "\""
		arguments.push_back(deletion_command)
	else:
		print("Unsupported operating system: " + os_name)
		return

	print("Attempting to delete: " + ethereum_path)

	var result = OS.execute(command, arguments, output, true, true)
	if result == OK and output.size() == 0:
		print("Successfully deleted: " + ethereum_path)
	else:
		print("Failed to delete: " + ethereum_path)
		if output.size() > 0:
			print("Reason: " + output[0])
		else:
			print("Reason: Unknown error.")

func delete_zcash_directory():
	var os_name = OS.get_name()
	var command = "sh"
	var arguments = PackedStringArray()
	var output = Array()
	var error_output = Array()

	# Determine the home path and set the Zcash directory path based on the operating system
	var home_path = OS.get_environment("HOME")
	var zcash_path = ""

	match os_name:
		"Linux":
			zcash_path = home_path + "/.zcash-drivechain"
		"macOS":
			zcash_path = home_path + "/ZcashDrivechain"
		_:
			print("Unsupported operating system: " + os_name)
			return

	print("Attempting to delete: " + zcash_path)

	# Setup command to delete the directory
	arguments.push_back("-c")
	arguments.push_back("rm -rf \"" + zcash_path + "\"")

	# Execute the command and handle output
	var result = OS.execute(command, arguments, output, true, true)
	if result == OK and output.size() == 0:
		print("Successfully deleted: " + zcash_path)
	else:
		print("Failed to delete: " + zcash_path)
		if output.size() > 0:
			print("Reason: " + output[0])
		else:
			print("Reason: Unknown error.")

func setup_wallets_backup_directory():
	var backup_dir_name := "wallets_backup"
	var user_data_dir := OS.get_user_data_dir()

	# Normalize path for Windows
	if OS.get_name() == "Windows":
		user_data_dir = user_data_dir.replace("/", "\\")

	var backup_dir_path := "%s\\%s" % [user_data_dir, backup_dir_name]

	var dir_access = DirAccess.open(user_data_dir)
	if dir_access:
		if dir_access.dir_exists(backup_dir_name):
			print("Wallets backup directory already exists at: %s" % backup_dir_path)
			clear_backup_directory(backup_dir_path)
		# Create the directory after clearing it.
		var error = dir_access.make_dir_recursive(backup_dir_name)
		if error != OK:
			print("Failed to create wallets backup directory at: %s" % backup_dir_path)
		else:
			print("Wallets backup directory successfully created at: %s" % backup_dir_path)
		dir_access.list_dir_end()
	else:
		print("Failed to access user data directory.")
	return backup_dir_path



func reset_everything():
	backup_wallets()
	print("Starting reset process...")
	# Purge directories while preserving the wallets_backup folder.
	var user_data_dir = OS.get_user_data_dir()

	purge_except_backup(user_data_dir, "wallets_backup")


	# Remaining operations on chains and configurations.
	for i in chain_states:
		#print("Stopping chain: %s" % i)
		chain_states[i].stop_chain()
		await get_tree().create_timer(0.1).timeout
		#print("Removing chain state child: %s" % i)
		remove_child(chain_states[i])
		#print("Cleaning up chain state: %s, with data: %s" % [i, str(chain_states[i])])
		chain_states[i].cleanup()

	if OS.get_name() == "Windows":
		print("Executing Windows-specific cleanup...")
		execute_cleanup_script_windows()  # Windows-specific cleanup
		return

	print("Removing chain providers...")
	for i in chain_providers:
		#print("Moving chain provider to trash:", i)
		var err = OS.move_to_trash(ProjectSettings.globalize_path(chain_providers[i].base_dir))
		if err != OK:
			print("Error moving to trash:", err)

	print("Clearing chain states...")
	chain_states.clear()
	#print("Chain states after clearing: %s" % str(chain_states))

	print("Clearing chain providers...")
	chain_providers.clear()
	#print("Chain providers after clearing: %s" % str(chain_providers))

	print("Loading version configuration...")
	load_version_config()

	print("Loading configuration...")
	load_config()

	print("Saving configuration...")
	save_config()

	load_app_config()

	print("Setting up directories...")
	setup_directories()

	print("Setting up configurations...")
	setup_confs()

	print("Setting up chain states...")
	setup_chain_states()

	print("Emitting chain providers changed signal...")
	chain_providers_changed.emit()

	print("Starting chain states...")
	start_chain_states()

	create_cleanup_batch_script()

	print("Reset process completed successfully.")

func clear_backup_directory(target_backup_path: String) -> void:
	print("\nAttempting to clear backup directory\n")

	var command: String
	var arguments: Array = []
	var output: Array = []
	var exit_code: int

	# Determine the command based on the operating system
	if OS.get_name() == "Windows":
		command = "cmd"
		arguments = ["/c", "rd", "/s", "/q", target_backup_path.replace("/", "\\")]  # Adjusted for backslashes
	else:  # Assuming Unix-like system
		command = "rm"
		arguments = ["-rf", target_backup_path]

	# Execute the command and capture output
	exit_code = OS.execute(command, arguments, output, true)

	# Check the result
	if exit_code == OK:
		print("Successfully cleared the backup directory\n")
	else:
		print("Failed to clear the backup directory. Output:\n")
		for line in output:
			print(line)


func create_cleanup_batch_script():
	var script_path := "user://cleanup_drivechain_data.bat"
	var launcher_path := OS.get_executable_path() # Dynamically obtain the launcher's executab	create_cleanup_batch_script()le path

	# Start the script content with an explicit type declaration
	var script_content: String = """
	@echo off

	REM Define the directory names
	SET DRIVECHAIN_DIR=Drivechain
	SET LAUNCHER_DIR=drivechain_launcher
	SET LAUNCHER_SIDECHAINS_DIR=drivechain_launcher_sidechains
	SET TESTCHAIN_DIR=Testchain
	SET CFG_FILE=chain_providers.cfg
	REM Define the name of the config file to delete

	REM Introduce a short delay
	timeout /t 1 /nobreak

	REM Delete the Drivechain directory
	IF EXIST "%APPDATA%\\%DRIVECHAIN_DIR%" (
		ECHO Deleting the Drivechain directory...
		RMDIR /S /Q "%APPDATA%\\%DRIVECHAIN_DIR%"
		ECHO Deletion complete.
	) ELSE (
		ECHO Drivechain directory not found.
	)

	REM Delete the drivechain_launcher_sidechains directory
	IF EXIST "%APPDATA%\\%LAUNCHER_SIDECHAINS_DIR%" (
		ECHO Deleting the drivechain_launcher_sidechains directory...
		RMDIR /S /Q "%APPDATA%\\%LAUNCHER_SIDECHAINS_DIR%"
		ECHO Deletion complete.
	) ELSE (
		ECHO drivechain_launcher_sidechains directory not found.
	)

	REM Delete only the chain_providers.cfg file in the Drivechain Launcher directory
	IF EXIST "%APPDATA%\\%LAUNCHER_DIR%\\%CFG_FILE%" (
		ECHO Deleting the %CFG_FILE% file...
		DEL "%APPDATA%\\%LAUNCHER_DIR%\\%CFG_FILE%"
		ECHO %CFG_FILE% deletion complete.
	) ELSE (
		ECHO %CFG_FILE% file not found in the Drivechain Launcher directory.
	)

	REM Start the Drivechain Launcher
	SET LAUNCHER_PATH="{launcher_path}"
	IF "%LAUNCHER_PATH%"=="" (
		ECHO Launcher path not provided. Exiting.
		exit
	) ELSE (
		ECHO Launcher path: %LAUNCHER_PATH%
		timeout /t 1 /nobreak
		REM Short delay before restart to ensure cleanup has finished
		start "" "%LAUNCHER_PATH%"
		ECHO Drivechain Launcher has been started.
	)
	"""

	# Replace {launcher_path} with the actual launcher path in the script content
	script_content = script_content.replace("{launcher_path}", launcher_path)

   # Write the batch script to the file
	var file := FileAccess.open(script_path, FileAccess.WRITE)
	if file:
		file.store_string(script_content)
		file.close()
		#print("Cleanup batch script created successfully at: ", script_path)
	else:
		print("Failed to create batch script.")

func execute_cleanup_script_windows():
	create_cleanup_batch_script()
	print("Starting detached cleanup script...")

	var script_path := "user://cleanup_drivechain_data.bat"
	script_path = ProjectSettings.globalize_path(script_path)  # Convert to an absolute OS path

	# Prepare the arguments for the script execution. Since it's a .bat file, use cmd.exe to run it
	var arguments := PackedStringArray(["/c", script_path])

	# Use create_process to start the batch script in a separate process
	var pid = OS.create_process("cmd.exe", arguments, false)
	if pid != -1:
		print("Detached cleanup script started with PID:", pid)
	else:
		print("Failed to start detached cleanup script.")

	# Now you can quit the application safely
	get_tree().quit()





func load_version_config():
	version_config = ConfigFile.new()
	var err = version_config.load(VERSION_CONFIG)
	if err != OK:
		print(ProjectSettings.globalize_path(VERSION_CONFIG) + " not found. Something went terribly wrong")
		get_tree().quit() # TODO: Set exit code

	var version = version_config.get_value("", "version")
	var current_version = app_config.get_value("", "version", "")
	if current_version == "":
		app_config.set_value("", "version", version)
		app_config.save(APP_CONFIG_PATH)
		return
	else:
		if version != current_version:
			app_config.set_value("", "version", version)
			app_config.save(APP_CONFIG_PATH)
			reset_everything()


func load_config():
	chain_providers_config = ConfigFile.new()
	var err = chain_providers_config.load(CHAIN_PROVIDERS_PATH)
	if err != OK:
		print(ProjectSettings.globalize_path(CHAIN_PROVIDERS_PATH) + " not found. Trying to load from embedded cfg")
		err = chain_providers_config.load(DEFAULT_CHAIN_PROVIDERS_PATH)
		if err != OK:
			print(ProjectSettings.globalize_path(DEFAULT_CHAIN_PROVIDERS_PATH) + " not found. Something went terribly wrong")
			get_tree().quit() # TODO: Set exit code

	else:
		print("Loaded config file from path ", ProjectSettings.globalize_path(CHAIN_PROVIDERS_PATH))


	var sections = chain_providers_config.get_sections()
	var dict = {}
	for s in sections:
		var inner_dict = {}

		# Let the chain providers specify a download URL
		var baseURL = chain_providers_config.get_value(s, "base_download_url")

		# But fallback to the global download URL if that's not set
		if baseURL == null:
			baseURL = version_config.get_value("", "base_download_url")

		inner_dict['base_download_url'] = baseURL

		var keys = chain_providers_config.get_section_keys(s)
		for k in keys:
			inner_dict[k] = chain_providers_config.get_value(s, k) #TODO: Default?
		dict[s] = inner_dict


	for k in dict:
		var inner_dict: Dictionary = dict.get(k)
		if inner_dict == null:
			continue
		var cp = ChainProvider.new(inner_dict)
		chain_providers[cp.id] = cp

	print(str(chain_providers.size()) + " Chain Providers loaded from config")


func setup_directories():
	for k in chain_providers:
		chain_providers[k].write_dir()


func setup_confs():
	for k in chain_providers:
		chain_providers[k].write_conf()
		chain_providers[k].read_conf()


func setup_chain_states():
	for k in chain_providers:
		var cp = chain_providers[k]
		if not chain_states.find_key(cp.id):
			var cs = chain_state.instantiate()
			cs.setup(cp)
			chain_states[cp.id] = cs
			add_child(cs)


func start_chain_states():
	for k in chain_states:
		chain_states[k].start()


func save_config():
	chain_providers_config.save(CHAIN_PROVIDERS_PATH)



func get_platform_config_suffix() -> String:
	match OS.get_name():
		"Windows", "UWP":
			return "_win"
		"macOS":
			return "_mac"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "_linux"
	return ""

func get_platform() -> platform:
	match OS.get_name():
		"Windows", "UWP":
			return Appstate.platform.WIN
		"macOS":
			return Appstate.platform.MAC
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return Appstate.platform.LINUX
	return Appstate.platform.UNSUPPORTED


func get_home() -> String:
	match get_platform():
		Appstate.platform.WIN:
			return OS.get_environment("USERPROFILE")
	return OS.get_environment("HOME")


func get_drivechain_dir() -> String:
	match get_platform():
		Appstate.platform.LINUX:
			return get_home() + "/drivechain"
		Appstate.platform.WIN:
			return get_home() + "\\AppData\\Roaming\\Drivechain"
		Appstate.platform.MAC:
			return get_home() + "/Library/Application Support/Drivechain"
	return ""


func drivechain_running() -> bool:
	if not chain_states.has('drivechain'):
		return false
	return chain_states['drivechain'].state == ChainState.c_state.RUNNING


func get_drivechain_state() -> ChainState:
	if not chain_states.has('drivechain'):
		return null
	return chain_states['drivechain']


func get_drivechain_provider() -> ChainProvider:
	if not chain_providers.has('drivechain'):
		return null
	return chain_providers['drivechain']


func show_chain_provider_info(chain_provider: ChainProvider):
	var info = chain_provider_info.instantiate()
	info.name = "chain_provider_info"
	get_tree().root.get_node("Main").add_child(info)
	info.setup(chain_provider)


#func show_zparams_modal(chain_provider: ChainProvider):
	#var zparams = z_params_modal.instantiate()
	#zparams.name = "z_params_modal"
	#get_tree().root.get_node("Main").add_child(zparams)
	#zparams.setup(chain_provider)


func add_drivenet_test_node() -> void:
	await get_tree().create_timer(3.5).timeout
	if chain_states.has('drivechain'):
		chain_states['drivechain'].add_node(DRIVENET_NODE)
