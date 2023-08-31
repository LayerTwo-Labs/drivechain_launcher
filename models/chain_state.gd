extends Node
class_name ChainState

var id: String
var state: c_state
var height: int = 0
var automine: bool = false
var refreshbmm: bool = false

var chain_provider: ChainProvider

enum c_state { WAITING, RUNNING }

@onready var get_block_height_request: HTTPRequest = $GetBlockHeightRequest
@onready var automine_request: HTTPRequest = $AutomineMainChainRequest
@onready var list_active_sidechains_request: HTTPRequest = $ListActiveSidechainsRequest
@onready var stop_chain_request: HTTPRequest = $StopChainRequest
@onready var create_sidechain_proposal_request: HTTPRequest = $CreateSidechainProposalRequest
@onready var mainchain_mine_request: HTTPRequest = $MainChainMineRequest


func setup(_chain_provider: ChainProvider):
	self.id = _chain_provider.id
	self.chain_provider = _chain_provider
	self.state = c_state.WAITING
	self.name = "cs_" + _chain_provider.id
	
	
func set_automine(value):
	if value == true and automine != true:
		request_automine()
	automine = value
	
	
func start():
	request_block_height()
	set_automine(true)
	
	
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
	make_request("getblockcount", [], get_block_height_request)
	
	
func _on_get_block_height_request_completed(_result, response_code, _headers, body):
	var res = get_result(response_code, body)
	if res.has("result"):
		if height != res.result:
			height = res.result
			Appstate.chain_states_changed.emit()
		if not state == c_state.RUNNING:
			state = c_state.RUNNING
			Appstate.chain_states_changed.emit()
	else:
		if not state == c_state.WAITING:
			state = c_state.WAITING
			Appstate.chain_states_changed.emit()
			
	await get_tree().create_timer(1).timeout
	request_block_height()
	
	
func request_automine():
	make_request("generate", [1], automine_request)
	
	
func _on_automine_mainchain_request_completed(_result, _response_code, _headers, _body):
	if automine:
		await get_tree().create_timer(1).timeout
		request_automine()
		
		
func request_create_sidechain_proposal(_chain_provider: ChainProvider) -> bool:
	if chain_provider.id != "drivechain":
		return false
		
	make_request("createsidechainproposal", [_chain_provider.slot, _chain_provider.id], create_sidechain_proposal_request)
	var completed = await create_sidechain_proposal_request.request_completed
	if completed.size() >= 2 and completed[1] == 200:
		make_request("generate", [201], mainchain_mine_request)
		await mainchain_mine_request.request_completed
		return true
		
	return false
	
	
func request_mainchain_mine(blocks_to_generate: int):
	if chain_provider.id != "drivechain":
		return
		
	make_request("generate", [blocks_to_generate], automine_request)
	
	
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
	
func stop_chain():
	make_request("stop", [], stop_chain_request)
	
	
func cleanup():
	self.queue_free()
	
	
