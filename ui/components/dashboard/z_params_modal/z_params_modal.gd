#extends ColorRect
#
#var chain_provider: ChainProvider
#var zside_thread: Thread
#var spinner_chars = ["|", "/", "-", "\\", "|", "/", "-", "\\"]
#var cursor_index = 0
#var frames = 0
#var output
#
#@onready var label = $Center/Panel/Margin/Label
#
#func setup(_chain_provider: ChainProvider):
	#chain_provider = _chain_provider
	##if chain_provider.id == "zside" || chain_provider.id == "zsail":
		##zside_thread = Thread.new()
		##zside_thread.start(_zside_fetch_params_thread)
		##while zside_thread != null and zside_thread.is_alive():
			##await Appstate.get_tree().process_frame
			##
		##zside_thread.wait_to_finish()
		##zside_thread = null
		##chain_provider.start_chain()
		##queue_free()
	##else:
	#queue_free()
		#
#func _zside_fetch_params_thread():
	#var script = ProjectSettings.globalize_path("res://zside-fetch-params.sh")
	#print("executing zcash params fetch script: ", script)
	#var exit_code = OS.execute(script, [], [])
	#
	#assert(exit_code == OK, "Unable to execute params fetch script")	
	#print("successfully downnloaded zcash params")/
		#
		#
		#
#func _process(_delta):
	#frames += 1
	#if frames % 8 == 0:
		#var c = spinner_chars[cursor_index]
		#cursor_index += 1
		#if cursor_index == spinner_chars.size():
			#cursor_index = 0
		#label.text = "Downloading zparams   " + c
