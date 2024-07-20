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

var wallet_dir_linux: String = ""
var wallet_dir_mac: String = ""
var wallet_dir_win: String = ""


var rpc_user: String
var rpc_password: String

enum c_type { MAIN, CORE, PLAIN, ETH, ZCASH, ZSIDE }

func _init(dict: Dictionary):
	self.id = dict.get('id', '')
	self.display_name = dict.get('display_name', '')
	self.description = dict.get('description', '')
	self.repo_url = dict.get('repo_url', '')
	
	self.wallet_dir_linux = dict.get('wallet_dir_linux', '')
	self.wallet_dir_mac = dict.get('wallet_dir_mac', '')
	self.wallet_dir_win = dict.get('wallet_dir_win', '')

	var binary_zip_path_fallback = dict.get('binary_zip_path', '')
	self.binary_zip_path = dict.get('binary_zip_path' + Appstate.get_platform_config_suffix(), binary_zip_path_fallback)
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
				self.binary_zip_size = dict.get('download_size_win', 0)
			self.base_dir = Appstate.get_home() + "\\AppData\\Roaming\\" + dict.get('base_dir_win', '').replace('/', '\\')
			print("Windows base_dir:", self.base_dir)
			print("Windows wallet_dir_win:", self.wallet_dir_win)
		Appstate.platform.MAC:
			var file_path = dict.get('download_file_mac', '')
			if file_path != '':
				self.download_url = dict.get('base_download_url') + "/" + file_path
				self.binary_zip_hash = dict.get('download_hash_mac', '')
				self.binary_zip_size = dict.get('download_size_mac', 0)
			self.base_dir = Appstate.get_home() + "/Library/Application Support/" + dict.get('base_dir_mac', '')
	#print("Determined base directory for ", self.id, ": ", self.base_dir)		

	# Look for both a version suffixed binary path, as well as one without
	# a suffix.
	self.executable_name = dict.get(
		"binary_zip_path" + Appstate.get_platform_config_suffix(), 
		dict.get("binary_zip_path", "")
	)
	

	
func available_for_platform() -> bool:
	return self.download_url != ""
	
	
func is_ready_for_execution() -> bool:
	if not available_for_platform():
		return false
	return FileAccess.file_exists(ProjectSettings.globalize_path(get_start_path()))
	
	
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
			conf.store_line("server=1")
		"testchain","bitassets","zsail":
			conf.store_line("rpcuser=user")
			conf.store_line("rpcpassword=password")
			conf.store_line("server=1")
		"latestcore":
			conf.store_line("server=1")
			conf.store_line("splash=0")
			conf.store_line("rpcuser=user")
			conf.store_line("rpcpassword=password")
			
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
	print("Writing start script: ", get_start_path())
	if FileAccess.file_exists(get_start_path()):
		DirAccess.remove_absolute(get_start_path())

	var env = ""
	if id == "testsail" || id == "ethsail" || id == "zsail":
		env = "SIDESAIL_DATADIR=" + base_dir

	var cmd = get_executable_path()
	match id:
		"thunder", "bitnames", "bitassets":
			var drivechain = Appstate.get_drivechain_provider()
			if drivechain == null:
				return

			# Remove explicit network, mainchain RPC, and RPC port configurations
			var data_dir = " -d " + ProjectSettings.globalize_path(base_dir + "/data")
			var dc_user = " -u " + drivechain.rpc_user
			var dc_pass = " -p " + drivechain.rpc_password
			cmd = cmd + data_dir + dc_user + dc_pass
		_:
			cmd = cmd + " --conf=" + get_conf_path()

	var file = FileAccess.open(get_start_path(), FileAccess.WRITE)
	match Appstate.get_platform():
		Appstate.platform.LINUX:
			file.store_line("#!/bin/bash")
			if env != "":
				file.store_line("export "+env)

			file.store_line(cmd)

		Appstate.platform.MAC:
			file.store_line("#!/bin/bash")
			cmd = cmd.replace("Application Support", "Application\\ Support")
			if env != "":
				file.store_line("export "+env)

			file.store_line(cmd)

		Appstate.platform.WIN:
			if env != "":
				file.store_line("set " + env)
			
			file.store_line("start " + cmd)

	file.close()

	
func write_dir():
	var dir = ProjectSettings.globalize_path(base_dir)
	if not DirAccess.dir_exists_absolute(dir):
		var err = DirAccess.make_dir_recursive_absolute(dir)
		#if err != OK:
			#print("Unable to create directory: " + dir)
		#else:
			#print("Sidechain directory found: " + dir)
			#
			
			
func start_chain():
	#if id == "zside" || id == "zsail":
		#var dir = DirAccess.open(ProjectSettings.globalize_path(Appstate.get_home() + "/.zcash-params"))
		#if dir == null:
			#print("zcash params not present, showing download modal")
			#Appstate.show_zparams_modal(self)

			## important: return here! once the params are finished downloading,
			## the binary will be launched by the params fetched modal.

			#return 
	

	var binary = get_start_path()
	print("Starting binary: ", binary)

	var pid = OS.create_process(binary, [], false)
	assert(pid != -1, "could not start process: " + binary)
	print("Process started with pid: " + str(pid))
	
	# Store PID for ethsail
	if id == "ethsail":
		Appstate.ethsail_pid = pid
	
	# Add test network sync node right after starting
	if id == "drivechain":
		Appstate.add_drivenet_test_node()
				
				
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
	
