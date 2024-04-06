extends Node2D

enum platform { LINUX, MAC, WIN, UNSUPPORTED }

const DEFAULT_CHAIN_PROVIDERS_PATH : String = "res://chain_providers.cfg"
const CHAIN_PROVIDERS_PATH         : String = "user://chain_providers.cfg"
const APP_CONFIG_PATH              : String = "user://app.cfg"
const VERSION_CONFIG               : String = "res://version.cfg"

const DRIVENET_NODE                : String = "172.105.148.135"

@onready var chain_state           : Resource = preload("res://models/chain_state.tscn")
@onready var chain_provider_info   : Resource = preload("res://ui/components/dashboard/chain_providers_info/chain_provider_info.tscn")
@onready var z_params_modal        : Resource = preload("res://ui/components/dashboard/z_params_modal/z_params_modal.tscn")

var chain_providers_config : ConfigFile
var app_config             : ConfigFile
var version_config         : ConfigFile

var chain_providers        : Dictionary = {}
var chain_states           : Dictionary = {}

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
	#create_cleanup_batch_script()
	find_and_print_wallet_paths()

func find_and_print_wallet_paths():
	for id in chain_providers.keys():
		var provider = chain_providers[id]
		
		# Construct the full path for the wallet file or directory
		var wallet_path = provider.base_dir
		if provider.wallet_dir_linux.begins_with("/"):
			wallet_path += provider.wallet_dir_linux
		else:
			wallet_path = "%s/%s" % [wallet_path, provider.wallet_dir_linux]
		
		wallet_path = wallet_path.replace("//", "/").replace("/./", "/")

		# Try opening the path as a directory to check if it's a directory
		var dir = DirAccess.open(wallet_path)
		if dir:
			print("Found a wallet directory for '", id, "' at: ", wallet_path)
			# No need to "close" DirAccess as it's refcounted and will be cleaned up automatically
		elif FileAccess.file_exists(wallet_path):
			print("Found a wallet file for '", id, "' at: ", wallet_path)
		else:
			print("No wallet found for '", id, "' at: ", wallet_path)

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


func setup_wallets_backup_directory():
	var backup_dir_name := "wallets_backup"
	var user_data_dir := OS.get_user_data_dir()
	var backup_dir_path := "%s/%s" % [user_data_dir, backup_dir_name]

	var dir_access = DirAccess.open(user_data_dir)
	if dir_access:
		if not dir_access.dir_exists(backup_dir_name):
			var error = dir_access.make_dir_recursive(backup_dir_name)
			if error != OK:
				print("Failed to create wallets backup directory at: %s" % backup_dir_path)
			else:
				print("Wallets backup directory successfully created at: %s" % backup_dir_path)
		else:
			print("Wallets backup directory already exists at: %s" % backup_dir_path)
		dir_access.list_dir_end()
	else:
		print("Failed to access user data directory.")


func reset_everything():
	print("Starting reset process...")
	# Setup the backup directory before purging to ensure it's not deleted.
	setup_wallets_backup_directory()
	
	# Purge directories while preserving the wallets_backup folder.
	var user_data_dir = OS.get_user_data_dir()

	purge_except_backup(user_data_dir, "wallets_backup")


	# Remaining operations on chains and configurations.
	for i in chain_states:
		print("Stopping chain: %s" % i)
		chain_states[i].stop_chain()
		await get_tree().create_timer(0.1).timeout
		print("Removing chain state child: %s" % i)
		remove_child(chain_states[i])
		print("Cleaning up chain state: %s, with data: %s" % [i, str(chain_states[i])])
		chain_states[i].cleanup()

	if OS.get_name() == "Windows":
		print("Executing Windows-specific cleanup...")
		execute_cleanup_script_windows()  # Windows-specific cleanup 
		return

	print("Clearing chain states...")
	chain_states.clear()
	print("Chain states after clearing: %s" % str(chain_states))

	print("Clearing chain providers...")
	chain_providers.clear()
	print("Chain providers after clearing: %s" % str(chain_providers))

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
		print("Cleanup batch script created successfully at: ", script_path)
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
	
	
func show_zparams_modal(chain_provider: ChainProvider):
	var zparams = z_params_modal.instantiate()
	zparams.name = "z_params_modal"
	get_tree().root.get_node("Main").add_child(zparams)
	zparams.setup(chain_provider)


func add_drivenet_test_node() -> void:
	await get_tree().create_timer(3.5).timeout
	if chain_states.has('drivechain'):
		chain_states['drivechain'].add_node(DRIVENET_NODE)
