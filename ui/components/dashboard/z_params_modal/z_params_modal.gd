extends ColorRect

var chain_provider: ChainProvider
var zside_thread: Thread
var spinner_chars = ["|", "/", "-", "\\", "|", "/", "-", "\\"]
var cursor_index = 0
var frames = 0
var output

@onready var label = $Center/Panel/Margin/Label

func setup(_chain_provider: ChainProvider):
	chain_provider = _chain_provider
	if chain_provider.id == "zside":
		zside_thread = Thread.new()
		zside_thread.start(_zside_fetch_params_thread)
		while zside_thread != null and zside_thread.is_alive():
			await Appstate.get_tree().process_frame
			
		zside_thread.wait_to_finish()
		zside_thread = null
		chain_provider.start_chain()
		queue_free()
	else:
		queue_free()
		
func _zside_fetch_params_thread():
	var zside_params_name = "zside-fetch-params.sh"
	var exit_code = OS.execute(ProjectSettings.globalize_path(chain_provider.base_dir + "/" + zside_params_name), [], [])
	
	if exit_code != 0:
		printerr("Error occured: %d" % exit_code)
		
		
		
func _process(_delta):
	frames += 1
	if frames % 8 == 0:
		var c = spinner_chars[cursor_index]
		cursor_index += 1
		if cursor_index == spinner_chars.size():
			cursor_index = 0
		label.text = "Downloading zparams   " + c
