extends Node

# TODO rename this and move it on the server as well?

# Server signals
signal fast_withdraw_requested(peer : int, amount: float, destination: String)
signal fast_withdraw_invoice_paid(peer : int, txid: String, amount: float, destination: String)

# Client signals
signal fast_withdraw_invoice(amount: float, destination: String)
signal fast_withdraw_complete(txid: String, amount: float, destination: String)

# TODO add params: SC #, MC fee, MC destination
@rpc("any_peer", "call_remote", "reliable")
func request_fast_withdraw(amount : float, destination : String) -> void:
	print("Received fast withdrawal request")
	print("Amount: ", amount)
	print("Destination: ", destination)
	print("Peer: ", multiplayer.get_remote_sender_id())
	
	fast_withdraw_requested.emit(multiplayer.get_remote_sender_id(), amount, destination)


@rpc("authority", "call_remote", "reliable")
func receive_fast_withdraw_invoice(amount : float, destination : String) -> void:
	print("Received fast withdrawal invoice")
	print("Amount: ", amount)
	print("Destination: ", destination)
	print("Peer: ", multiplayer.get_remote_sender_id())
	
	fast_withdraw_invoice.emit(amount, destination)


@rpc("any_peer", "call_remote", "reliable")
func invoice_paid(txid: String, amount : float, destination : String) -> void:
	print("Paid fast withdrawal invoice")
	print("Amount: ", amount)
	print("Destination: ", destination)
	print("Txid: ", txid)
	print("Peer: ", multiplayer.get_remote_sender_id())
	
	fast_withdraw_invoice_paid.emit(multiplayer.get_remote_sender_id(), txid, amount, destination)


@rpc("authority", "call_remote", "reliable")
func withdraw_complete(txid: String, amount : float, destination : String) -> void:
	print("Fast withdraw completed!")
	print("Amount: ", amount)
	print("Destination: ", destination)
	print("Txid: ", txid)
	
	fast_withdraw_complete.emit(txid, amount, destination)
