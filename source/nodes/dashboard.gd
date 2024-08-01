extends MarginContainer

@onready var scroll_container = $ScrollContainer
@onready var window = scroll_container.get_node("Window")
var panel = preload("res://source/nodes/node_panel/node_panel.tscn")
const CUSTOM_FONT_PATH = "res://assets/fonts/Satoshi-Bold.otf"

@export var panel_vertical_spacing: float = 6  # Adjust this value to increase/decrease spacing

func _ready():
	Appstate.connect("chain_providers_changed", self._on_chain_providers_changed)
	Appstate.connect("drivechain_downloaded", Callable(self, "_on_drivechain_downloaded"))
	_on_chain_providers_changed()

func _on_drivechain_downloaded():
	for panel in get_node_panels():
		panel.update_view()

func get_node_panels():
	return get_tree().get_nodes_in_group("node_panels")

func _on_chain_providers_changed():
	# Remove all existing children from window
	var current_panels = window.get_children()
	for p in current_panels:
		window.remove_child(p)
		p.queue_free()
	
	var chain_providers = Appstate.chain_providers
	var chain_states = Appstate.chain_states
	
	# Add available providers first
	add_providers(chain_providers, chain_states, true)
	
	# Add unavailable providers
	add_providers(chain_providers, chain_states, false)

func add_providers(chain_providers, chain_states, available: bool):
	for k in chain_providers:
		var cp = chain_providers[k]
		if cp.available_for_platform() == available:
			if chain_states.has(k):
				var cs = chain_states[k]
				var p = panel.instantiate()
				p.name = "panel_" + cp.id
				window.add_child(p)
				p.setup(cp, cs)
				
				# Apply custom font to the panel
				apply_custom_font(p)
				
				# Add vertical spacing
				var spacer = Control.new()
				spacer.custom_minimum_size.y = panel_vertical_spacing
				window.add_child(spacer)

func set_panel_spacing(spacing: float):
	panel_vertical_spacing = spacing
	_on_chain_providers_changed()

func apply_custom_font(node: Node):
	var custom_font = load(CUSTOM_FONT_PATH)
	if custom_font:
		apply_font_recursive(node, custom_font)

func apply_font_recursive(node: Node, font: Font):
	if node is Label or node is Button or node is LineEdit or node is TextEdit:
		node.add_theme_font_override("font", font)
	for child in node.get_children():
		apply_font_recursive(child, font)
