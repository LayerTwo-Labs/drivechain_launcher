extends PanelContainer
class_name BaseChainDashboardPanel

var chain_provider : ChainProvider
var chain_state    : ChainState

var download_req   : HTTPRequest
var progress_timer : Timer

@onready var title              : Control = $Margin/VBox/Header/Title
@onready var desc               : Control = $Margin/VBox/Content/Description
@onready var block_height       : Control = $Margin/VBox/Footer/BlockHeight
@onready var secondary_desc     : Control = $Margin/VBox/Content/SecondaryDescription
@onready var left_indicator     : Control = $LeftColor
@onready var background         : Control = $BackgroundPattern
@onready var start_button       : Control = $Margin/VBox/Footer/StartButton
@onready var stop_button        : Control = $Margin/VBox/Footer/StopButton
#@onready var auto_mine_button  : Control = $Margin/VBox/Footer/Automine # removed due to signet
@onready var refresh_bmm_button : Control = $Margin/VBox/Footer/RefreshBMM
@onready var download_button    : Control = $Margin/VBox/Footer/VBox/DownloadButton
@onready var progress_bar       : Control = $Margin/VBox/Footer/VBox/ProgressBar
@onready var settings_button    : Control = $Margin/VBox/Header/SettingsButton

var enabled           : bool = true

var enabled_modulate  : Color
var disabled_modulate : Color

func _ready():
	Appstate.connect("chain_states_changed", self.update_view)
	enabled_modulate  = modulate
	disabled_modulate = modulate.darkened(0.3)
	
	
func setup(_chain_provider: ChainProvider, _chain_state: ChainState):
	self.chain_provider = _chain_provider
	self.chain_state = _chain_state
	if chain_provider.chain_type == ChainProvider.c_type.MAIN:
		left_indicator.visible = true
		background.visible = true
	else:
		left_indicator.visible = false
		background.visible = false
		
	title.text = chain_provider.display_name
	desc.text = chain_provider.description
	block_height.visible = chain_state.state == ChainState.c_state.RUNNING
	download_button.text = str(int(_chain_provider.binary_zip_size * 0.000001)) + " mb"
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
		if chain_provider.id == 'drivechain' or Appstate.drivechain_running():
			show_executable_state()
		else:
			show_waiting_on_drivechain_state()
	else:
		show_running_state()
	
func show_waiting_on_drivechain_state():
	download_button.visible = false
	start_button.visible = false
	stop_button.visible = false
	#auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	secondary_desc.visible = true
	modulate = enabled_modulate
	
	
func show_running_state():
	start_button.visible = false
	stop_button.visible = true
	download_button.visible = false
	modulate = enabled_modulate
	
	
	if chain_provider.id == 'drivechain':
		#auto_mine_button.visible = false # changed to false due to signet, and removed 
		#auto_mine_button.visible = true
		#auto_mine_button.set_pressed_no_signal(chain_state.automine)
		refresh_bmm_button.visible = false
	else:
		#auto_mine_button.visible = false
		refresh_bmm_button.visible = false
		refresh_bmm_button.visible = true
		refresh_bmm_button.set_pressed_no_signal(chain_state.refreshbmm)
		
		
func show_executable_state():
	settings_button.disabled = false
	start_button.visible = true
	start_button.disabled = false
	stop_button.visible = false
#	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	download_button.visible = false
	modulate = enabled_modulate
	
	
func show_download_state():
	settings_button.disabled = false
	start_button.visible = false
	stop_button.visible = false
#	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	download_button.visible = true
	download_button.disabled = false
	modulate = enabled_modulate
	
	
func show_unsupported_state():
	settings_button.disabled = true
	download_button.visible = false
	start_button.visible = false
	stop_button.visible = false
#	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	secondary_desc.visible = true
	secondary_desc.text = "[i]This sidechain is currently not available for this platform -- try Linux instead.[/i]"
	modulate = disabled_modulate
	
	
func download():
	if not chain_provider.available_for_platform():
		return
		
	if download_req != null:
		remove_child(download_req)
		
	if progress_timer != null:
		progress_timer.stop()
		remove_child(progress_timer)
		
	print("Downloading ", chain_provider.display_name, " from " ,  chain_provider.download_url)
	download_req = HTTPRequest.new()
	add_child(download_req)
	
	download_req.request_completed.connect(self._on_download_complete)
	var err = download_req.request(chain_provider.download_url)
	if err != OK:
		push_error("An error occured")
		return
		
	download_button.disabled = true
	
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

		# This will error on non-zcash chains, but that's OK. Just swallow it.
		var zside_params_name = "zside-fetch-params.sh"
		OS.execute("chmod", ["+x", ProjectSettings.globalize_path(chain_provider.base_dir + "/" + zside_params_name)])

	update_view()
	
	
func reset_download():
	remove_child(download_req)
	download_req.queue_free()
	progress_timer.stop()
	
	remove_child(progress_timer)
	progress_timer.queue_free()
	
	download_button.visible = false
	progress_bar.visible = false
	start_button.disabled = false


func _on_start_button_pressed():
	print("Starting chain: ", chain_provider.id)

	if chain_provider.id != "drivechain":
		var drivechain_state = Appstate.get_drivechain_state()
		assert(drivechain_state != null)
			
		#if await drivechain_state.needs_activation(chain_provider):
			#print("Activating sidechain: ", chain_provider.id)
			#await drivechain_state.request_create_sidechain_proposal(chain_provider)
			
	chain_provider.start_chain()
		
	start_button.disabled = true
	
	
func _on_stop_button_pressed():
	if chain_provider.id == "drivechain":
		for k in Appstate.chain_states:
			Appstate.chain_states[k].stop_chain()
	else:
		chain_state.stop_chain()
	
	
func _on_automine_toggled(button_pressed):
	chain_state.set_automine(button_pressed)
	
	
func _on_info_button_pressed():
	Appstate.show_chain_provider_info(self.chain_provider)
	
	
