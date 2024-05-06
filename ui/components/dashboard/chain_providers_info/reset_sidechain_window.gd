extends ColorRect

@onready var label = $CenterContainer/Panel/MarginContainer/VBoxContainer/Label
@onready var button = $CenterContainer/Panel/MarginContainer/VBoxContainer/Button
@onready var label2 = $CenterContainer/Panel/MarginContainer/VBoxContainer/Label2
@onready var button2 = $CenterContainer/Panel/MarginContainer/VBoxContainer/Button2
var chain_provider: ChainProvider

func setup(_chain_provider: ChainProvider):
	chain_provider = _chain_provider
	
	if label:
		label.text = "Choose \"Reset and backup " + chain_provider.display_name + "\" to get a fresh install of " + chain_provider.display_name + " and backup your wallet."
		
	if button:
		button.text = "Reset and backup " + chain_provider.display_name 
		
	if label2: 
		label2.text = "Choose \"Reset " + chain_provider.display_name + "\" to get a fresh install of " + chain_provider.display_name + " and delete your wallet."
	
	if button2:
		button2.text = "Reset " + chain_provider.display_name

func _ready():
	# Ensure chain_provider is initialized before calling setup
	setup(chain_provider)

func _on_button_pressed():
	print("button 1 pressed")

func _on_button_2_pressed():
	if chain_provider:
		stop_chain()  # Call to stop the chain
		await get_tree().create_timer(1.0).timeout  # Optional: wait for the chain to fully stop
		purge_directory()
	else:
		print("Chain provider is not initialized!")

func stop_chain():
	if chain_provider.id == "drivechain":
		for k in Appstate.chain_states:
			Appstate.chain_states[k].stop_chain()
	else:
		Appstate.chain_states[chain_provider.id].stop_chain()

func purge_directory():
	var directory_text = ProjectSettings.globalize_path(chain_provider.base_dir)
	if OS.get_name() == "Windows":
		directory_text = directory_text.replace("/", "\\")  # Ensure the path uses Windows-style separators
	Appstate.purge(directory_text)
	print("Directory purged: " + directory_text)
	print("Button 2 pressed for " + chain_provider.display_name)

func _on_center_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			queue_free()
