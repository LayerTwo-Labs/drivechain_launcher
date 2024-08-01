extends Node

func _ready():
	# Load and instantiate the scene
	var application_scene = load("res://source/application/application.tscn")
	if application_scene:
		var application_instance = application_scene.instantiate()
		# Add the scene to the current tree
		add_child(application_instance)
	else:
		print("Failed to load the application scene.")
