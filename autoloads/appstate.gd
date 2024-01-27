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
		push_error("Unsupported platfom")
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
	
	
func reset_everything():
	
	for i in chain_states:
		chain_states[i].stop_chain()
		await get_tree().create_timer(0.1).timeout
		remove_child(chain_states[i])
		chain_states[i].cleanup()
		
	for i in chain_providers:
		var err = OS.move_to_trash(ProjectSettings.globalize_path(chain_providers[i].base_dir))
		if err != OK:
			print(err)
		
	chain_states.clear()
	chain_providers.clear()
	
	var err = OS.move_to_trash(ProjectSettings.globalize_path(OS.get_user_data_dir()))
	if err != OK:
		print(err)
		return
		
	load_version_config()
	load_config()
	save_config()
	setup_directories()
	setup_confs()
	setup_chain_states()
	
	chain_providers_changed.emit()
	
	start_chain_states()
	
	
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
		print(ProjectSettings.globalize_path(CHAIN_PROVIDERS_PATH) + " not found. Trying to load from embeded cfg")
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
			return get_home() + "/.drivechain"
		Appstate.platform.WIN:
			return get_home() + "/AppData/Roaming/Drivechain"
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
