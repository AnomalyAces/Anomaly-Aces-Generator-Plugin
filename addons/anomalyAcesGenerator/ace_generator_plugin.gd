@tool
extends EditorPlugin

func _enter_tree():
	pass
	# Initialization of the plugin goes here.
	#Add Custom Types
	#add_custom_type(
		#"AceGenerator", 
		#"Node3D",
		#preload("res://addons/AceGenerator/ace_generator.gd"),
		#preload("res://addons/AceGenerator/Anomaly Aces Ace Generator.svg")
	#)
	#print("Ace Generator Entering Tree")
	
	#Add Autoloads
	#add_autoload_singleton("AceTableConstants", "res://addons/anomalyAcesTable/Scripts/Table/AceTableConstants.gd")
	#add_autoload_singleton("AceTableManager", "res://addons/anomalyAcesTable/Scripts/Table/AceTableManager.gd")

func _exit_tree():
	pass
	#remove custom types
	#remove_custom_type("AceGenerator")
	
	#remove singletons
	#remove_autoload_singleton("AceTableManager")
	#remove_autoload_singleton("AceTableConstants")
