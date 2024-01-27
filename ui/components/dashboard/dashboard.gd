extends ScrollContainer

@onready var drivechain = $VBox/Drivechain
@onready var grid = $VBox/Grid/HBox/VBox

var panel = preload("res://ui/components/dashboard/base_dashboard_panel/base_chain_dashboard_panel.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Appstate.connect("chain_providers_changed", self._on_chain_providers_changed)
	_on_chain_providers_changed()
	
	
func _on_chain_providers_changed():
	var current_panels = grid.get_children()
	for p in current_panels:
		grid.remove_child(p)
		p.queue_free()
		
	for p in drivechain.get_children():
		drivechain.remove_child(p)
		p.queue_free()
		
		
	var chain_providers = Appstate.chain_providers
	var chain_states = Appstate.chain_states
	# add available providers first
	for k in chain_providers:
		var cp = chain_providers[k]
		if cp.available_for_platform():
			if chain_states.has(k):
				var cs = chain_states[k]
				var p = panel.instantiate()
				p.name = "panel_" + cp.id
				if cp.id == "drivechain":
					drivechain.add_child(p)
				else:
					grid.add_child(p)
				p.setup(cp, cs)
				
	for k in chain_providers:
		var cp = chain_providers[k]
		if not cp.available_for_platform():
			if chain_states.has(k):
				var cs = chain_states[k]
				var p = panel.instantiate()
				p.name = "panel_" + cp.id
				grid.add_child(p)
				p.setup(cp, cs)
