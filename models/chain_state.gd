extends Node
class_name ChainState

var id: String
var state: c_state
var height: int = -1
var automine: bool = false
var refreshbmm: bool = false

var chain_provider: ChainProvider

enum c_state { WAITING, RUNNING }

@onready var get_block_height_request: HTTPRequest = $GetBlockHeightRequest
#@onready var automine_request: HTTPRequest = $AutomineMainChainRequest
@onready var list_active_sidechains_request: HTTPRequest = $ListActiveSidechainsRequest
@onready var stop_chain_request: HTTPRequest = $StopChainRequest
#@onready var create_sidechain_proposal_request: HTTPRequest = $CreateSidechainProposalRequest
@onready var mainchain_mine_request: HTTPRequest = $MainChainMineRequest
@onready var add_node_request: HTTPRequest = $AddNodeRequest

func setup(_chain_provider: ChainProvider):
	self.id = _chain_provider.id
	self.chain_provider = _chain_provider
	self.state = c_state.WAITING
	self.name = "cs_" + _chain_provider.id
	
	
#func set_automine(value):
	#if value == true and automine != true:
		#request_automine()
	#automine = value
	
	
func start():
	request_block_height()
	# set_automine(true)
	
	
func make_request(method: String, params: Variant, http_request: HTTPRequest):
	var auth = chain_provider.rpc_user + ":" + chain_provider.rpc_password
	var auth_bytes = auth.to_utf8_buffer()
	var auth_encoded = Marshalls.raw_to_base64(auth_bytes)
	var headers: PackedStringArray = []
	headers.push_back("Authorization: Basic " + auth_encoded)
	headers.push_back("content-type: application/json")
	
	var jsonrpc := JSONRPC.new()
	var req = jsonrpc.make_request(method, params, 1)
	
	http_request.request("http://127.0.0.1:" + str(chain_provider.port), headers, HTTPClient.METHOD_POST, JSON.stringify(req))
	
	
func get_result(response_code, body) -> Dictionary:
	var res = {}
	var json = JSON.new()
	if response_code != 200:
		if body != null:
			var err = json.parse(body.get_string_from_utf8())
			if err == OK:
				print(json.get_data())
	else:
		var err = json.parse(body.get_string_from_utf8())
		if err == OK:
			res = json.get_data() as Dictionary
			
	return res
	
	
func request_block_height():
	if chain_provider.id == "ethsail":
		make_request("eth_blockNumber", [], get_block_height_request)
	else:
		make_request("getblockcount", [], get_block_height_request)
	
	
func _on_get_block_height_request_completed(_result, response_code, _headers, body):
	var res = get_result(response_code, body)
	if res.has("result"):
		# Directly use the string with '0x' prefix to convert hex to int
		var result_height = int(res["result"])
		
		# Now compare the integer values
		if height != result_height:
			height = result_height
			Appstate.chain_states_changed.emit()

		if not state == c_state.RUNNING:
			state = c_state.RUNNING
			Appstate.chain_states_changed.emit()
	else:
		if not state == c_state.WAITING:
			state = c_state.WAITING
			Appstate.chain_states_changed.emit()
	
	await get_tree().create_timer(.5).timeout
	request_block_height()

#func request_automine():
	#make_request("generate", [1], automine_request)
	#
	#
#func _on_automine_mainchain_request_completed(_result, _response_code, _headers, _body):
	#if automine:
		#await get_tree().create_timer(1).timeout
		#request_automine()
		#request_block_height()
		#
		#
#func request_create_sidechain_proposal(_chain_provider: ChainProvider) -> bool:
	#if chain_provider.id != "drivechain":
		#return false
		#
	#make_request("createsidechainproposal", [_chain_provider.slot, _chain_provider.id], create_sidechain_proposal_request)
	#var completed = await create_sidechain_proposal_request.request_completed
	#if completed.size() >= 2 and completed[1] == 200:
		#make_request("generate", [21], mainchain_mine_request)
		#await mainchain_mine_request.request_completed
		#return true
		#
	#return false
# removed due to switching to signet
	
	
#func request_mainchain_mine(blocks_to_generate: int):
	#if chain_provider.id != "drivechain":
		#return
		#
	#make_request("generate", [blocks_to_generate], automine_request)
	# removed due to switching to signet
	
func needs_activation(_chain_provider: ChainProvider) -> bool:
	if chain_provider.id != "drivechain":
		return false
		
	make_request("listactivesidechains", [], list_active_sidechains_request)
	var completed = await list_active_sidechains_request.request_completed
	var result = get_result(completed[1], completed[3])
	for v in result.result:
		if v.title == _chain_provider.id:
			return false
			
	return true
	
func add_node(node: String) -> void:
	make_request("addnode", [node, "onetry"], add_node_request)
	
func stop_chain():
	if chain_provider.id == "ethsail":
		# Use the PID from Appstate for conditional stopping logic
		stop_ethsail_gracefully()
	elif chain_provider.id == "zsail":
		# Stopping logic for zsail chain
		stop_zsail_related_processes_gracefully()
	else:
		# Standard stopping logic for other chains
		make_request("stop", [], stop_chain_request)

func stop_zsail_related_processes_gracefully():
	var pids = find_zsail_related_pids()
	if pids.size() == 0:
		print("No PIDs found for zsail or zsided.")
		return

	for pid in pids:
		var command = ""
		var args = []
		var output = []

		if OS.get_name() == "Windows":
			command = "taskkill"
			args = ["/PID", str(pid), "/F"]  # Forcefully ends the process
		else:  # Assuming Unix-like OS
			command = "kill"
			args = ["-TERM", str(pid)]  # Sends the SIGTERM signal

		var result = OS.execute(command, args, output, true, false)
		if result == OK:
			print("Graceful shutdown command sent to PID", pid)
		else:
			print("Failed to send shutdown command to PID", pid)

func find_zsail_related_pids() -> Array:
	var output = []
	var pids = []
	if OS.get_name() != "Windows":
		# Adjust the regex pattern as needed to accurately match your processes.
		var result = OS.execute("pgrep", ["-f", "zsail|zsided"], output, true)
		if result == OK and output.size() > 0:
			var pid_strings = output[0].split("\n")
			for pid_str in pid_strings:
				if pid_str.strip_edges() != "":
					pids.append(int(pid_str))
	return pids


func find_ethsail_pids() -> Array:
	var output = []
	var pids = []
	var os_name = OS.get_name()

	if os_name != "Windows":
		# Command for Unix-like systems to find processes by command-line pattern
		var result = OS.execute("pgrep", ["-f", "ethsail.*ethsail.conf"], output, true)
		if result == OK and output.size() > 0:
			# Handle multiple PIDs
			var pid_strings = output[0].split("\n")
			# Filter out empty strings and convert to int
			for pid_str in pid_strings:
				if pid_str.strip_edges() != "":
					pids.append(int(pid_str))
	return pids

func stop_ethsail_gracefully():
	var os_name = OS.get_name()

	if os_name == "Windows":
		# Directly kill processes by name on Windows
		var commands = [
			["taskkill", "/IM", "ethsail.exe", "/T", "/F"],
			["taskkill", "/IM", "sidegeth.exe", "/T", "/F"]
		]
		for args in commands:
			var output = []
			var result = OS.execute(args[0], args.slice(1, args.size()), output, true, false)
			print("Command sent to kill", args[2], ", result: ", result)
	else:
		# Use the existing logic for Unix-like systems
		var pids = find_ethsail_pids()
		if pids.size() == 0:
			print("No PIDs found for ethsail.")
			return

		for pid in pids:
			var command = "kill"
			var args = ["-TERM", str(pid)]
			var output = []
			# Execute the gentle shutdown command
			var result = OS.execute(command, args, output, true, false)
			print("Gentle shutdown command sent to PID ", pid, ", result: ", result)

		# Optional: wait and check for process termination
		OS.delay_msec(500)  # Delay 500 milliseconds between commands

	# Reset stored PID if needed
	Appstate.ethsail_pid = -1

	
func cleanup():
	self.queue_free()
	
	
