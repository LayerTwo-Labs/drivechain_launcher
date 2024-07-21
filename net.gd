extends Node

# Enable this for debug printing in net.gd and fast_withdraw.gd
var print_debug_net : bool = false

const FAST_WITHDRAW_CHAIN_TESTCHAIN : String = "Testchain"
const FAST_WITHDRAW_CHAIN_THUNDER : String = "Thunder"
const FAST_WITHDRAW_CHAIN_ZSIDE : String = "ZSide"

# Server signals
signal fast_withdraw_requested(peer : int, chain_name : String, amount: float, destination: String)
signal fast_withdraw_invoice_paid(peer : int, chain_name : String, txid: String, amount: float, destination: String)

# Client signals
signal fast_withdraw_invoice(amount: float, destination: String)
signal fast_withdraw_complete(txid: String, amount: float, destination: String)

# TODO add params: MC fee 
@rpc("any_peer", "call_remote", "reliable")
func request_fast_withdraw(amount : float, chain_name: String, destination : String) -> void:
	if print_debug_net:
		print("Received fast withdrawal request")
		print("Chain: ", chain_name)
		print("Amount: ", amount)
		print("Destination: ", destination)
		print("Peer: ", multiplayer.get_remote_sender_id())
	
	fast_withdraw_requested.emit(multiplayer.get_remote_sender_id(), chain_name, amount, destination)


@rpc("authority", "call_remote", "reliable")
func receive_fast_withdraw_invoice(amount : float, destination : String) -> void:
	if print_debug_net:
		print("Received fast withdrawal invoice")
		print("Amount: ", amount)
		print("Destination: ", destination)
		print("Peer: ", multiplayer.get_remote_sender_id())
	
	fast_withdraw_invoice.emit(amount, destination)


@rpc("any_peer", "call_remote", "reliable")
func invoice_paid(chain_name : String, txid: String, amount : float, destination : String) -> void:
	if print_debug_net:
		print("Paid fast withdrawal invoice")
		print("Chain: ", chain_name)
		print("Amount: ", amount)
		print("Destination: ", destination)
		print("Txid: ", txid)
		print("Peer: ", multiplayer.get_remote_sender_id())
	
	fast_withdraw_invoice_paid.emit(multiplayer.get_remote_sender_id(), chain_name, txid, amount, destination)


@rpc("authority", "call_remote", "reliable")
func withdraw_complete(txid: String, amount : float, destination : String) -> void:
	if print_debug_net:
		print("Fast withdraw completed!")
		print("Amount: ", amount)
		print("Destination: ", destination)
		print("Txid: ", txid)
		
	fast_withdraw_complete.emit(txid, amount, destination)
