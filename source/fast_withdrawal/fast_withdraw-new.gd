extends Control

const SERVER_LOCALHOST : String = "127.0.0.1"
const SERVER_L2L_GA : String = "172.105.148.135"
const PORT : int = 8382

var invoice_address : String = ""
var connected_to_server : bool = false
var selected_chain : String = ""

signal fast_withdraw_server_connection_status_changed

func _ready() -> void:
	$LabelConnectionStatus.visible = false
	
	selected_chain = $"/root/Net".FAST_WITHDRAW_CHAIN_TESTCHAIN
	
	multiplayer.connected_to_server.connect(_on_connected_to_withdrawal_server)
	multiplayer.connection_failed.connect(_on_failed_connect_to_withdrawal_server)
	multiplayer.server_disconnected.connect(_on_disconnected_from_withdrawal_server)

	$"/root/Net".fast_withdraw_invoice.connect(_on_fast_withdraw_invoice)
	$"/root/Net".fast_withdraw_complete.connect(_on_fast_withdraw_complete)
	

func _on_connected_to_withdrawal_server() -> void:
	if $"/root/Net".print_debug_net:
		print("Connected to fast withdraw server")
	
	$LabelConnectionStatus.text = "Connected"
	
	connected_to_server = true
	fast_withdraw_server_connection_status_changed.emit()
	
	
func _on_disconnected_from_withdrawal_server() -> void:
	if $"/root/Net".print_debug_net:
		print("Disonnected from fast withdraw server")
	
	$LabelConnectionStatus.text = "Disconnected"
	$LabelInvoice.text = ""
	connected_to_server = false
	fast_withdraw_server_connection_status_changed.emit()
	
	
func _on_failed_connect_to_withdrawal_server() -> void:
	if $"/root/Net".print_debug_net:
		print("Failed to connect to fast withdraw server")
		
	$LabelConnectionStatus.text = "Not Connected"

	connected_to_server = false
	fast_withdraw_server_connection_status_changed.emit()


func connect_to_withdrawal_server() -> void:
	# Create fast withdraw client
	var peer = ENetMultiplayerPeer.new()
	if $CheckButtonLocalhost.is_pressed():
		if $"/root/Net".print_debug_net:
			print("Using fast withdraw server: localhost")
		
		var error = peer.create_client(SERVER_LOCALHOST, PORT)
		if error and $"/root/Net".print_debug_net:
			print_debug("Error: ", error)
	else:
		if $"/root/Net".print_debug_net:
			print("Using fast withdraw server: L2L-GA")
		var error = peer.create_client(SERVER_L2L_GA, PORT)
		if error and $"/root/Net".print_debug_net:
			print_debug("Error: ", error)
	
	$LabelConnectionStatus.text = "Connecting..."
	
	multiplayer.multiplayer_peer = peer


func _on_fast_withdraw_invoice(amount : float, destination: String) -> void:
	if $"/root/Net".print_debug_net:
		print("Received fast withdraw invoice!")
		print("Amount: ", amount)
		print("Destination: ", destination)
	
	var invoice_text = "Fast withdraw request received! Invoice created:\n"
	invoice_text += str("Send ", amount, " L2 coins to ", destination, "\n") 
	invoice_text += "Once you have paid enter the L2 txid and hit invoice paid"
	
	invoice_address = destination
	
	$LabelInvoice.text = invoice_text


func _on_fast_withdraw_complete(txid: String, amount : float, destination: String) -> void:
	if $"/root/Net".print_debug_net:
		print("Fast withdraw complete!")
		print("TxID: ", txid)
		print("Amount: ", amount)
		print("Destination: ", destination)
	
	var output : String = "Withdraw complete!\n"
	output += "Mainchain payout txid:\n" + txid + "\n"
	output += "Amount: " + str(amount) + "\n"
	output += "Destination: " + destination + "\n"
	$LabelComplete.text = output
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()


func _on_button_copy_address_pressed() -> void:
	DisplayServer.clipboard_set(invoice_address)
	

func _on_button_invoice_paid_pressed() -> void:
	# Tell the server we paid
	var txid : String = $LineEditTXID.text
	$"/root/Net".invoice_paid.rpc_id(1, selected_chain, txid, $SpinBoxAmount.value, $LineEditMainchainAddress.text)


func _on_button_request_invoice_pressed() -> void:
	# Establish connection with fast withdraw server
	connect_to_withdrawal_server()
	$LabelConnectionStatus.visible = true
	
	await fast_withdraw_server_connection_status_changed
	
	# Send fast withdraw request only to server
	$"/root/Net".request_fast_withdraw.rpc_id(1, $SpinBoxAmount.value, selected_chain, $LineEditMainchainAddress.text)


func _on_chain_selection_button_item_selected(index):
	var selection_index = $ChainSelectionButton.get_selected()
	selected_chain = $ChainSelectionButton.get_item_text(selection_index)
