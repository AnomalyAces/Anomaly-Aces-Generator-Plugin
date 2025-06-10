@tool
extends EditorPlugin

func _enter_tree():
	#Initialization of the plugin goes here.
	#Add Custom Types
	add_custom_type(
		"AceBoardGenerator", 
		"Node3D",
		preload("res://addons/anomalyAcesGenerator/BoardGenerator/ace_board_generator.gd"),
		preload("res://addons/anomalyAcesGenerator/BoardGenerator/AceBoardGenerator.svg")
	)
	
	print("AceBoardGenerator Entering Tree")
	
	add_custom_type(
		"AceRoomGenerator", 
		"Node3D",
		preload("res://addons/anomalyAcesGenerator/RoomGenerator/ace_room_generator.gd"),
		preload("res://addons/anomalyAcesGenerator/RoomGenerator/AceRoomGenerator.svg")
	)
	print("AceRoomGenerator Entering Tree")
	
	add_custom_type(
		"AceDungeonGenerator", 
		"Node3D",
		preload("res://addons/anomalyAcesGenerator/DungeonGenerator/ace_dungeon_generator.gd"),
		preload("res://addons/anomalyAcesGenerator/DungeonGenerator/AceDungeonGenerator.svg")
	)
	
	print("AceDungeonGenerator Entering Tree")
	
	#Add Autoloads
	#add_autoload_singleton("AceTableConstants", "res://addons/anomalyAcesTable/Scripts/Table/AceTableConstants.gd")
	#add_autoload_singleton("AceTableManager", "res://addons/anomalyAcesTable/Scripts/Table/AceTableManager.gd")

func _exit_tree():
	#remove custom types
	remove_custom_type("AceBoardGenerator")
	remove_custom_type("AceRoomGenerator")
	remove_custom_type("AceGeneratorGenerator")
	
	#remove singletons
	#remove_autoload_singleton("AceTableManager")
	#remove_autoload_singleton("AceTableConstants")
