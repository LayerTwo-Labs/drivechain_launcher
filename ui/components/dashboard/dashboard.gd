extends ScrollContainer

@onready var grid = $VBox/Grid

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
		
	var chain_providers = Appstate.chain_providers
	for cp in chain_providers:
		var p = panel.instantiate()
		grid.add_child(p)
		p.setup(cp)
