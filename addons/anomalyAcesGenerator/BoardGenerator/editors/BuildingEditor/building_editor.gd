@tool
class_name BuildingEditor extends Node

## Collection of Building tiles and their attributes
@export var buildings: Array[Building] :
	set(p_buildings):
		if p_buildings != buildings:
			buildings = p_buildings
			update_configuration_warnings()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if buildings.size() > 0:
		for i in buildings.size():
			if buildings[i].buildingName.is_empty():
				warnings.append("[%d] Building Name Not Defined" % [i])
			else:
				if buildings[i].buildingIndex == -1:
					warnings.append("[%d] %s building index not defined" % [i, buildings[i].buildingName])
				if buildings[i].spaceIndex == -1:
					warnings.append("[%d] %s space index not defined" % [i, buildings[i].buildingName])
				if buildings[i].buildingTransparentIndex == -1:
					warnings.append("[%d] %s building tranparency index not defined. No transparency will be applied to this building" % [i, buildings[i].buildingName])
	
	
	return warnings
