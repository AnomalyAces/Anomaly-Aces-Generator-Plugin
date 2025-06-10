@tool
class_name SpaceEditor extends Node

##Tiles that make up the different environments in a region
@export var environmentTileIndices: Array[int] = [] :
	set(p_envTiles):
		if p_envTiles != environmentTileIndices:
			environmentTileIndices = p_envTiles
			update_configuration_warnings()
##Most Common Space on the Board
@export var normalSpace: Space :
	set(p_normalSpace):
		if p_normalSpace != normalSpace:
			normalSpace = p_normalSpace
			update_configuration_warnings()
@export_subgroup("Special Spaces")
##Pecertage of the board that are made of special spaces
@export_range(0, 100, 1) var specialSpacePercentage: int = 20
##Number of spaces before a special space repeats
@export var specialSpaceDistance: int = 2
## Collection of Special Spaces and their attributes
@export var specialSpaceEditor: SpecialSpaceEditor

@export_subgroup("Building Tiles")
## Collection of Building tiles and their attributes
@export var buildingEditor: BuildingEditor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if environmentTileIndices.size() == 0:
		warnings.append("Environment Tiles Not Defined")
	if normalSpace == null:
		warnings.append("Normal Space Not Defined")
	return warnings
