extends Node2D

enum platform { LINUX, MAC, WIN, UNSUPPORTED }

const DEFAULT_CHAIN_PROVIDERS_PATH = "res://chain_providers.cfg"
const CHAIN_PROVIDERS_PATH = "user://chain_providers.cfg"

var chain_providers_config = ConfigFile.new()
var chain_providers: Array[ChainProvider] = []

signal chain_providers_changed

func _ready():
	if Appstate.get_platform() == platform.UNSUPPORTED:
		push_error("Unsupported platfom")
		get_tree().quit()
		
	load_config(true)
	save_config()
	setup_directories()
	setup_confs()
	
	chain_providers_changed.emit()
	
	
func load_config(force_default = false):
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
		chain_providers.push_back(ChainProvider.new(inner_dict))
		
	print(str(chain_providers.size()) + " Chain Providers loaded from config")
	
	
func setup_directories():
	for cp in chain_providers:
		cp.write_dir()
			
			
func setup_confs():
	for cp in chain_providers:
		cp.write_conf()
		
		
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
