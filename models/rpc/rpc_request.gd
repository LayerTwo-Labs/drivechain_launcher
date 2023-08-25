extends Node
class_name RPCRequest

@onready var request: HTTPRequest = $HTTPRequest

signal on_rpc_response(rpc_response: Dictionary)

func _init(dict: Dictionary):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func _on_request_completed(result, response_code, headers, body):
	pass # Replace with function body.
	pass
