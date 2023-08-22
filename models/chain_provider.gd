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
		self.base_dir = Appstate.get_home() + "/" + dict.get('base_dir', '')
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
			
			
func available_for_platform() -> bool:
	return self.download_url != ""
	
	
func is_ready_for_execution() -> bool:
	if not available_for_platform():
		return false
	return FileAccess.file_exists(ProjectSettings.globalize_path(base_dir + "/" + executable_name))
	
	
func write_conf(force_default := true):
	if not force_default:
		if FileAccess.file_exists(ProjectSettings.globalize_path(base_dir + "/" + id + ".conf")):
			return
	
	var conf = ConfigFile.new()
	match id:
		"drivechain":
			conf.set_value("", "rpcuser", "user")
			conf.set_value("", "rpcpassword", "password")
			conf.set_value("", "rpcport", port)
			conf.set_value("", "regtest", 1)
			conf.set_value("", "server", 1)
			conf.set_value("", "datadir", ProjectSettings.globalize_path(base_dir))
		"testchain","bitassets":
			conf.set_value("", "rpcuser", "user")
			conf.set_value("", "rpcpassword", "password")
			conf.set_value("", "rpcport", port)
			conf.set_value("", "regtest", 1)
			conf.set_value("", "server", 1)
			conf.set_value("", "datadir", ProjectSettings.globalize_path(base_dir))
			conf.set_value("", "slot", slot)
		"latestcore":
			conf.set_value("", "chain", "regtest")
			conf.set_value("", "server", 1)
			conf.set_value("", "splash", 0)
			conf.set_value("", "datadir", ProjectSettings.globalize_path(base_dir))
			conf.set_value("", "slot", slot)
			conf.set_value("regtest", "rpcuser", "user")
			conf.set_value("regtest", "rpcpassword", "password")
			conf.set_value("regtest", "rpcport", port)
			
	conf.save(ProjectSettings.globalize_path(base_dir + "/" + id + ".conf"))
	
	
func write_dir():
	var dir = ProjectSettings.globalize_path(base_dir)
	if not DirAccess.dir_exists_absolute(dir):
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			print("Unable to create directory: " + dir)
		else:
			print("Sidechain directory found: " + dir)
