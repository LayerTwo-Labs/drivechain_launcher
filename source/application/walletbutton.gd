extends VBoxContainer

signal wallet_created
signal wallet_deleted

@onready var wallet_button: Button = $Menu/MarginContainer/HBox/Panel/Wallet
@onready var wallet_tab: TabContainer = $TabContainer2
@onready var wallet_screen: TabContainer = $TabContainer2/Wallet

@export var wallet_exists_theme_path: String = "res://ui/themes/wallet-button.tres"
@export var wallet_not_exists_theme_path: String = "res://ui/themes/wallet-null.tres"

func _ready():
	wallet_button.connect("pressed", Callable(self, "_on_wallet_button_pressed"))
	wallet_created.connect(Callable(self, "_on_wallet_created"))
	wallet_deleted.connect(Callable(self, "_on_wallet_deleted"))
	update_wallet_state()

func update_wallet_state():
	var user_data_dir = OS.get_user_data_dir()
	var wallet_file = user_data_dir.path_join("wallet_starters/wallet_master_seed.txt")
	
	if FileAccess.file_exists(wallet_file):
		_set_wallet_exists_state()
	else:
		_set_wallet_not_exists_state()

func _set_wallet_exists_state():
	load_and_set_theme(wallet_exists_theme_path)
	wallet_button.disabled = false
	wallet_tab.current_tab = 1
	wallet_screen.current_tab = 1

func _set_wallet_not_exists_state():
	load_and_set_theme(wallet_not_exists_theme_path)
	wallet_button.disabled = true
	wallet_tab.current_tab = 0

func load_and_set_theme(theme_path: String):
	if ResourceLoader.exists(theme_path):
		var theme = load(theme_path) as Theme
		if theme:
			wallet_button.theme = theme
		else:
			print("Failed to load theme from path: ", theme_path)
	else:
		print("Theme file does not exist at path: ", theme_path)

func _on_wallet_button_pressed():
	if wallet_tab.current_tab == 0:
		wallet_tab.current_tab = 1
		wallet_screen.current_tab = 1
	else:
		wallet_tab.current_tab = 0
		var user_data_dir = OS.get_user_data_dir()
		var wallet_file = user_data_dir.path_join("wallet_starters/wallet_master_seed.txt")
		if FileAccess.file_exists(wallet_file):
			wallet_screen.current_tab = 1
		else:
			wallet_screen.current_tab = 0
		

func _on_wallet_created():
	_set_wallet_exists_state()
	

func _on_wallet_deleted():
	_set_wallet_not_exists_state()
