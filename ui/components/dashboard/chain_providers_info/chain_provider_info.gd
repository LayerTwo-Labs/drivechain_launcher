extends ColorRect

@onready var title = $Center/Panel/Margin/VBox/Titlebar/Title
@onready var remote_zip_button = $Center/Panel/Margin/VBox/DownloadLink/LinkButton
@onready var remote_hash = $Center/Panel/Margin/VBox/RemoteHash/Hash
@onready var directory = $Center/Panel/Margin/VBox/SidechainDirectory/Value
@onready var local_hash = $Center/Panel/Margin/VBox/LocalHash/Hash

var chain_provider: ChainProvider

func setup(_chain_provider: ChainProvider):
	chain_provider = _chain_provider
	title.text = chain_provider.display_name + " Info"
	
	remote_zip_button.uri = chain_provider.download_url
	
	var url_split = chain_provider.download_url.split("/")
	remote_zip_button.text = url_split[url_split.size()-1]
	
	remote_hash.text = chain_provider.binary_zip_hash
	var directory_text : String = ProjectSettings.globalize_path(chain_provider.base_dir)
	if Appstate.get_platform() == Appstate.platform.WIN:
		directory.text = "\\".join(directory_text.split("/"))
	else:
		directory.text = directory_text
	var local_sha = chain_provider.get_local_zip_hash()
	if local_sha != null and local_sha != "":
		local_hash.text = local_sha
	else:
		local_hash.text = "Not Downloaded yet..."
		
		
func _on_directory_button_pressed():
	OS.shell_open(ProjectSettings.globalize_path(chain_provider.base_dir))


func _on_center_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				queue_free()
