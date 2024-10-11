@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	#Add Custom Types
	add_custom_type(
		"AceTable", 
		"Control", 
		preload("res://addons/anomalyAcesTable/Scripts/ace_table_properties.gd"),
		preload("res://addons/anomalyAcesTable/AceTable.svg")
	)
	
	#Add Autoloads
	add_autoload_singleton("AceTableConstants", "res://addons/anomalyAcesTable/Scripts/Table/AceTableConstants.gd")
	add_autoload_singleton("AceTableManager", "res://addons/anomalyAcesTable/Scripts/Table/AceTableManager.gd")

func _exit_tree():
	#remove custom types
	remove_custom_type("AceTable")
	
	#remove singletons
	remove_autoload_singleton("AceTableManager")
	remove_autoload_singleton("AceTableConstants")
