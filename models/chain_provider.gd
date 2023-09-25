class_name ChainProvider

var id: String
var display_name: String
var description: String
var repo_url: String
var download_url: String
var base_dir: String
var binary_zip_path: String
var executable_name: String
var binary_zip_size: int
var binary_zip_hash: String
var port: int
var slot: int
var version: String
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
	self.version = dict.get('version', '')
	
	match Appstate.get_platform():
		Appstate.platform.LINUX:
			var file_path = dict.get('download_file_linux', '')
			if file_path != '':
				self.download_url = dict.get('base_download_url') + "/" + file_path
				self.binary_zip_hash = dict.get('download_hash_linux', '')
				self.binary_zip_size = dict.get('download_size_linux', 0)
			self.base_dir = Appstate.get_home() + "/" + dict.get('base_dir_linux', '')
		Appstate.platform.WIN:
			var file_path = dict.get('download_file_win', '')
			if file_path != '':
				self.download_url = dict.get('base_download_url') + "/" + file_path
				self.binary_zip_path += ".exe"
				self.binary_zip_hash = dict.get('download_hash_win', '')
				self.binary_zip_size = dict.get('download_size_linux', 0)
			self.base_dir = Appstate.get_home() + "/AppData/Roaming/" + dict.get('base_dir_win', '')
		Appstate.platform.MAC:
			var file_path = dict.get('download_file_mac', '')
			if file_path != '':
				self.download_url = dict.get('base_download_url') + "/" + file_path
				self.binary_zip_hash = dict.get('download_hash_mac', '')
				self.binary_zip_size = dict.get('download_size_mac', 0)
			self.base_dir = Appstate.get_home() + "/Library/Application Support/" + dict.get('base_dir_mac', '')
			
	self.executable_name = self.binary_zip_path.split("/")[-1]
	
	
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
		"testchain","bitassets","zside":
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
				
	conf.close()
	
	
func write_start_script():
	if FileAccess.file_exists(get_start_path()):
		DirAccess.remove_absolute(get_start_path())
		
	var cmd: String
	match id:
		"thunder","bitnames":
			var drivechain = Appstate.get_drivechain_provider()
			if drivechain == null:
				return
				
			var data_dir = " -d " + ProjectSettings.globalize_path(base_dir + "/data")
			var net_addr = " -n " + "127.0.0.1:" + str(port * 2)
			var dc_addr = " -m " + "127.0.0.1:" + str(drivechain.port)
			var rpc_addr = " -r" + "127.0.0.1:" + str(port)
			var dc_user = " -u " + drivechain.rpc_user
			var dc_pass = " -p " + drivechain.rpc_password
			cmd = get_executable_path() + data_dir + net_addr + dc_addr + dc_user + dc_pass + rpc_addr
		_:
			cmd = get_executable_path() + " --conf=" + get_conf_path()
		
	var file = FileAccess.open(get_start_path(), FileAccess.WRITE)
	match Appstate.get_platform():
		Appstate.platform.LINUX:
			file.store_line("#!/bin/bash")
			file.store_line(cmd)
		Appstate.platform.MAC:
			file.store_line("#!/bin/bash")
			cmd = cmd.replace("Application Support", "Application\\ Support")
			file.store_line(cmd)
		Appstate.platform.WIN:
			file.store_line("start " + cmd)
			
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
			if id == "zside":
				var dir = DirAccess.open(ProjectSettings.globalize_path(Appstate.get_home() + "/.zcash-params"))
				if dir == null:
					Appstate.show_zparams_modal(self)
				else:
					var pid = OS.create_process(get_start_path(), [], false)
					print("Process with started with pid: " + str(pid))
			else:
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
	
	
func get_local_zip_hash() -> String:
	return FileAccess.get_sha256(ProjectSettings.globalize_path(base_dir + "/" + id + ".zip"))
	
