extends MarginContainer

const PBKDF2_ROUNDS = 2048
const MASTER_KEY_DERIVATION_PATH = "m/44'/0'/0'/0"
const HARDENED_OFFSET = 0x80000000
const CHAIN_CODE_SIZE = 32 # Size of the chain code in bytes

@onready var input = $VBoxContainer/HBoxContainer/TextIn
@onready var bin_out = $VBoxContainer/HBoxContainer2/VBoxContainer/BIP39Out
@onready var words_out = $VBoxContainer/HBoxContainer2/VBoxContainer/WordList
@onready var xpriv_out = $VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer/XprivOut
@onready var addr_out = $VBoxContainer/HBoxContainer2/VBoxContainer2/AddressesOut

func _ready():
	input.connect("text_changed", Callable(self, "_on_text_in_changed"))

func _on_text_in_changed(master: String):
	#var wallet = BitcoinWallet.new()
	pass
