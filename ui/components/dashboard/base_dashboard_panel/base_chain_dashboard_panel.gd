extends PanelContainer
class_name BaseChainDashboardPanel

var chain_provider: ChainProvider

var download_req: HTTPRequest
var progress_timer: Timer

@onready var title = $Margin/VBox/Header/Title
@onready var desc = $Margin/VBox/Content/Description
@onready var secondary_desc = $Margin/VBox/Content/SecondaryDescription
@onready var left_indicator = $LeftColor
@onready var background = $BackgroundPattern
@onready var start_button = $Margin/VBox/Footer/StartButton
@onready var mine_button = $Margin/VBox/Footer/MineButton
@onready var download_button = $Margin/VBox/Footer/VBox/DownloadButton
@onready var progress_bar = $Margin/VBox/Footer/VBox/ProgressBar
@onready var settings_button = $Margin/VBox/Header/SettingsButton


func setup(_chain_provider: ChainProvider):
	self.chain_provider = _chain_provider
	if chain_provider.chain_type == ChainProvider.c_type.MAIN:
		left_indicator.visible = true
		background.visible = true
	else:
		left_indicator.visible = false
		background.visible = false
		
	title.text = chain_provider.display_name
	desc.text = chain_provider.description
	
	if chain_provider.is_ready_for_execution():
		download_button.visible = false
		start_button.disabled = false
		
	if not chain_provider.available_for_platform():
		download_button.disabled = true
		start_button.disabled = true
		mine_button.disabled = true
		settings_button.disabled = true
		secondary_desc.visible = true
		secondary_desc.text = "[i]This sidechain is currently not available.[/i]"
		modulate = modulate.darkened(0.2)

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
		return
		
	var files = reader.get_files()
	var binary_index = files.find(chain_provider.binary_zip_path)
	
	if binary_index >= 0:
		var path = files[binary_index]
		var binary = reader.read_file(path)
		
		if binary.size() > 0:
			var executable_path = chain_provider.base_dir + "/" + chain_provider.executable_name
			var save = FileAccess.open(executable_path, FileAccess.WRITE)
			save.store_buffer(binary)
			save.close()
			OS.execute("chmod", ["+x", ProjectSettings.globalize_path(executable_path)])
			
			
func reset_download():
	remove_child(download_req)
	download_req.queue_free()
	progress_timer.stop()
	
	remove_child(progress_timer)
	progress_timer.queue_free()
	
	download_button.visible = false
	progress_bar.visible = false
	start_button.disabled = false
