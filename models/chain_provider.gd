class_name ChainProvider

var id: String
var display_name: String
var description: String
var repo_url: String
var download_url: String
var base_dir: String
var binary_zip_path: String
var executable_name: String
var port: int
var slot: int
var chain_type: c_type

var rpc_user: String
var rpc_password: String

enum c_type { MAIN, CORE, PLAIN, ETH, ZCASH, ZSIDE }

func _init(dict: Dictionary):
	self.id = dict.get('id', '')
	self.display_name = dict.get('display_name', '')
	self.description = dict.get('description', '')
	self.repo_url = dict.get('repo_url', '')
	self.binary_zip_path = dict.get('binary_zip_path', '')
	self.port = dict.get('port', -1)
	self.slot = dict.get('slot', -1)
	self.chain_type = dict.get('chain_type', 0)
	
	if self.id == "drivechain":
		self.base_dir = Appstate.get_drivechain_dir()
	else:
		self.base_dir = "user://" + dict.get('base_dir', '')
		
	self.executable_name = self.binary_zip_path.split("/")[-1]
	
	match Appstate.get_platform():
		Appstate.platform.LINUX:
			self.download_url = dict.get('download_url_linux', '')
		Appstate.platform.WIN:
			self.download_url = dict.get('download_url_win', '')
		Appstate.platform.MAC:
			self.download_url = dict.get('download_url_mac', '')
			
			
			
func set_download(dict: Dictionary):
	pass
	
	
func available_for_platform() -> bool:
	return self.download_url != ""
	
	
func is_ready_for_execution() -> bool:
	if not available_for_platform():
		return false
	return FileAccess.file_exists(ProjectSettings.globalize_path(base_dir + "/" + executable_name))
	
	
func write_conf(force_write := true):
	if force_write:
		if FileAccess.file_exists(get_conf_path()):
			DirAccess.remove_absolute(get_conf_path())
	elif FileAccess.file_exists(get_conf_path()):
		return
	
	var conf = FileAccess.open(get_conf_path(), FileAccess.WRITE)
	match id:
		"drivechain":
			conf.store_line("rpcuser=user")
			conf.store_line("rpcpassword=password")
			conf.store_line("rpcport=" + str(port))
			conf.store_line("regtest=1")
			conf.store_line("server=1")
			conf.store_line("datadir=" + ProjectSettings.globalize_path(base_dir))
		"testchain","bitassets":
			conf.store_line("rpcuser=user")
			conf.store_line("rpcpassword=password")
			conf.store_line("rpcport=" + str(port))
			conf.store_line("regtest=1")
			conf.store_line("server=1")
			conf.store_line("datadir=" + ProjectSettings.globalize_path(base_dir))
			conf.store_line("slot=" + str(slot))
		"latestcore":
			conf.store_line("chain=regtest")
			conf.store_line("server=1")
			conf.store_line("splash=0")
			conf.store_line("datadir=" + ProjectSettings.globalize_path(base_dir))
			conf.store_line("slot=" + str(slot))
			conf.store_line("")
			conf.store_line("[regtest]")
			conf.store_line("rpcuser=user")
			conf.store_line("rpcpassword=password")
			conf.store_line("rpcport=" + str(port))
			
	conf.close()
	
	
func read_conf():
	if not FileAccess.file_exists(get_conf_path()):
		return
		
	var conf = FileAccess.open(get_conf_path(), FileAccess.READ)
	var index = 0
	while not conf.eof_reached():
		var line = conf.get_line()
		if line.begins_with("rpcuser"):
			var user = line.split("=")
			if user.size() == 2:
				rpc_user = user[1]
		elif line.begins_with("rpcpassword"):
			var password = line.split("=")
			if password.size() == 2:
				rpc_password = password[1]
				
				
func write_start_script():
	if FileAccess.file_exists(get_start_path()):
		DirAccess.remove_absolute(get_start_path())
		
	var file = FileAccess.open(get_start_path(), FileAccess.WRITE)
	match Appstate.get_platform():
		Appstate.platform.LINUX,Appstate.platform.MAC:
			file.store_line("#!/bin/bash")
			file.store_line(get_executable_path() + " --conf=" + get_conf_path())
		Appstate.platform.WIN:
			file.store_line("start " + get_executable_path() + " --conf=" + get_conf_path())
			
	file.close()
	
	
func write_dir():
	var dir = ProjectSettings.globalize_path(base_dir)
	if not DirAccess.dir_exists_absolute(dir):
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			print("Unable to create directory: " + dir)
		else:
			print("Sidechain directory found: " + dir)
			
			
			
func start_chain():
	match Appstate.get_platform():
		Appstate.platform.LINUX,Appstate.platform.MAC,Appstate.platform.WIN:
			var pid = OS.create_process(get_start_path(), [], false)
			print("Process with started with pid: " + str(pid))
				
				
func get_start_path() -> String:
	match Appstate.get_platform():
		Appstate.platform.LINUX,Appstate.platform.MAC:
			return ProjectSettings.globalize_path(base_dir + "/start.sh")
		Appstate.platform.WIN:
			return ProjectSettings.globalize_path(base_dir + "/start.bat")
	return ""
	
func get_conf_path() -> String:
	return ProjectSettings.globalize_path(base_dir + "/" + id + ".conf")
	
	
func get_executable_path() -> String:
	return ProjectSettings.globalize_path(base_dir + "/" + executable_name)
	
	
