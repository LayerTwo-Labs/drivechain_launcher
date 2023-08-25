extends Node2D

enum platform { LINUX, MAC, WIN, UNSUPPORTED }

const DEFAULT_CHAIN_PROVIDERS_PATH = "res://chain_providers.cfg"
const CHAIN_PROVIDERS_PATH = "user://chain_providers.cfg"

@onready var chain_state = preload("res://models/chain_state.tscn")

var chain_providers_config: ConfigFile

var chain_providers: Dictionary = {}
var chain_states: Dictionary = {}

signal chain_providers_changed
signal chain_states_changed

func _ready():
	if Appstate.get_platform() == platform.UNSUPPORTED:
		push_error("Unsupported platfom")
		get_tree().quit()
		
	DisplayServer.window_set_title("Drivechain Launcher")
		
	load_config(true)
	save_config()
	setup_directories()
	setup_confs()
	setup_chain_states()
	
	chain_providers_changed.emit()
	
	start_chain_states()
	
	
func reset_everything():
	
	for i in chain_states:
		chain_states[i].stop_chain()
		await get_tree().create_timer(0.1).timeout
		remove_child(chain_states[i])
		chain_states[i].cleanup()
		
	chain_states.clear()
	chain_providers.clear()
	
	var err = OS.move_to_trash(ProjectSettings.globalize_path(OS.get_user_data_dir()))
	if err != OK:
		print(err)
		return
		
	err = OS.move_to_trash(ProjectSettings.globalize_path(get_drivechain_dir()))
	if err != OK:
		print(err)
		return
		
		
	load_config(true)
	save_config()
	setup_directories()
	setup_confs()
	setup_chain_states()
	
	chain_providers_changed.emit()
	
	start_chain_states()
	
	
func load_config(force_default = false):
	chain_providers_config = ConfigFile.new()
	if not force_default:
		var err = chain_providers_config.load(CHAIN_PROVIDERS_PATH)
		if err != OK:
			print(ProjectSettings.globalize_path(CHAIN_PROVIDERS_PATH) + " not found. Trying to load from embeded cfg")
			err = chain_providers_config.load(DEFAULT_CHAIN_PROVIDERS_PATH)
			if err != OK:
				print(ProjectSettings.globalize_path(DEFAULT_CHAIN_PROVIDERS_PATH) + " not found. Something went terribly wrong")
				get_tree().quit() # TODO: Set exit code
	else:
		var err = chain_providers_config.load(DEFAULT_CHAIN_PROVIDERS_PATH)
		if err != OK:
			print(ProjectSettings.globalize_path(DEFAULT_CHAIN_PROVIDERS_PATH) + " not found. Something went terribly wrong")
			get_tree().quit() # TODO: Set exit code
		
	var sections = chain_providers_config.get_sections()
	var dict = {}
	for s in sections:
		var inner_dict = {}
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
	
	
static func get_platform() -> platform:
	match OS.get_name():
		"Windows", "UWP":
			return Appstate.platform.WIN
		"macOS":
			return Appstate.platform.MAC
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return Appstate.platform.LINUX
	return Appstate.platform.UNSUPPORTED
	
	
static func get_home() -> String:
	match get_platform():
		Appstate.platform.WIN:
			return OS.get_environment("USERPROFILE")
	return OS.get_environment("HOME")

static func get_drivechain_dir() -> String:
	match get_platform():
		Appstate.platform.LINUX:
			return get_home() + "/.drivechain"
		Appstate.platform.WIN,Appstate.platform.MAC:
			return get_home() + "/Drivechain"
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
