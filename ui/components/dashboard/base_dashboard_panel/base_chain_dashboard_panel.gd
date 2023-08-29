extends PanelContainer
class_name BaseChainDashboardPanel

var chain_provider: ChainProvider
var chain_state: ChainState

var download_req: HTTPRequest
var progress_timer: Timer

@onready var title = $Margin/VBox/Header/Title
@onready var desc = $Margin/VBox/Content/Description
@onready var secondary_desc = $Margin/VBox/Content/SecondaryDescription
@onready var left_indicator = $LeftColor
@onready var background = $BackgroundPattern
@onready var start_button = $Margin/VBox/Footer/StartButton
@onready var stop_button = $Margin/VBox/Footer/StopButton
@onready var auto_mine_button = $Margin/VBox/Footer/Automine
@onready var refresh_bmm_button = $Margin/VBox/Footer/RefreshBMM
@onready var download_button = $Margin/VBox/Footer/VBox/DownloadButton
@onready var progress_bar = $Margin/VBox/Footer/VBox/ProgressBar
@onready var settings_button = $Margin/VBox/Header/SettingsButton

var enabled_modulate: Color
var disabled_modulate: Color

func _ready():
	Appstate.connect("chain_states_changed", self.update_view)
	enabled_modulate = modulate
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
	#download_button.tooltip_text = _chain_provider.download_url
	
	update_view()
	
	
func update_view():
	if chain_state == null:
		show_unsupported_state()
		return
		
	if not chain_provider.available_for_platform():
		show_unsupported_state()
		return
	
	if chain_provider.id == 'drivechain':
		if not chain_provider.is_ready_for_execution():
			show_download_state()
		elif chain_provider.is_ready_for_execution() and chain_state.state != ChainState.c_state.RUNNING:
			show_executable_state()
		else:
			show_running_state()
	else:
		if not chain_provider.is_ready_for_execution():
			show_download_state()
		elif chain_provider.is_ready_for_execution() and chain_state.state != ChainState.c_state.RUNNING:
			if Appstate.drivechain_running():
				show_executable_state()
			else:
				show_waiting_on_drivechain_state()
		else:
			show_running_state()
	
func show_waiting_on_drivechain_state():
	download_button.visible = false
	start_button.visible = false
	stop_button.visible = false
	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	secondary_desc.visible = true
	modulate = enabled_modulate
	
	
func show_running_state():
	start_button.visible = false
	stop_button.visible = true
	download_button.visible = false
	modulate = enabled_modulate
	
	if chain_provider.id == 'drivechain':
		auto_mine_button.visible = true
		auto_mine_button.set_pressed_no_signal(chain_state.automine)
		refresh_bmm_button.visible = false
	else:
		auto_mine_button.visible = false
		refresh_bmm_button.visible = false
		#refresh_bmm_button.visible = true
		#refresh_bmm_button.set_pressed_no_signal(chain_state.refreshbmm)
		
		
func show_executable_state():
	start_button.visible = true
	stop_button.visible = false
	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	download_button.visible = false
	modulate = enabled_modulate
	
	
func show_download_state():
	start_button.visible = false
	stop_button.visible = false
	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	download_button.visible = true
	download_button.disabled = false
	modulate = enabled_modulate
	
	
func show_unsupported_state():
	download_button.visible = false
	start_button.visible = false
	stop_button.visible = false
	auto_mine_button.visible = false
	refresh_bmm_button.visible = false
	secondary_desc.visible = true
	secondary_desc.text = "[i]This sidechain is currently not available for this platform[/i]"
	modulate = disabled_modulate
	
	
func download():
	if not chain_provider.available_for_platform():
		return
		
	if download_req != null:
		remove_child(download_req)
		
	if progress_timer != null:
		progress_timer.stop()
		remove_child(progress_timer)
		
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
		return
		
	var path = chain_provider.base_dir + "/" + chain_provider.id + ".zip"
	var save_game = FileAccess.open(path, FileAccess.WRITE)
	save_game.store_buffer(body)
	save_game.close()
	
	unzip_file_and_setup_binary(path)
	
	
func unzip_file_and_setup_binary(zip_path: String):
	var reader := ZIPReader.new()
	var err := reader.open(zip_path)
	if err != OK:
		push_error("Unabled to read zip")
		show_download_state()
		return
		
	var files = reader.get_files()
	var binary_index: int
	for i in files.size():
		if files[i].ends_with(chain_provider.binary_zip_path):
			binary_index = i
			break
			
	if binary_index != null && binary_index >= 0:
		var path = files[binary_index]
		var binary = reader.read_file(path)
		
		if binary.size() > 0:
			var save = FileAccess.open(chain_provider.get_executable_path(), FileAccess.WRITE)
			save.store_buffer(binary)
			save.close()
			OS.execute("chmod", ["+x", chain_provider.get_executable_path()])
			
			chain_provider.write_start_script()
			OS.execute("chmod", ["+x", ProjectSettings.globalize_path(chain_provider.get_start_path())])
			
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
	if chain_provider.id != "drivechain":
		var drivechain_state = Appstate.get_drivechain_state()
		if drivechain_state == null:
			return
			
		if await drivechain_state.needs_activation(chain_provider):
			await drivechain_state.request_create_sidechain_proposal(chain_provider)
			chain_provider.start_chain()
		else:
			chain_provider.start_chain()
	else:
		chain_provider.start_chain()
	
	
func _on_stop_button_pressed():
	if chain_provider.id == "drivechain":
		for k in Appstate.chain_states:
			Appstate.chain_states[k].stop_chain()
	else:
		chain_state.stop_chain()
	
	
func _on_automine_toggled(button_pressed):
	chain_state.set_automine(button_pressed)
	
	
