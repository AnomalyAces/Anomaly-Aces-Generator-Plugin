@tool
class_name SpecialSpaceEditor extends Node

## Collection of Special Spaces and their attributes
@export var specialSpaces: Array[SpecialSpace] = [] :
	set(p_specialSpaces):
		if p_specialSpaces != specialSpaces:
			specialSpaces = p_specialSpaces
			_update_special_space_arrays()
			update_configuration_warnings()
			

var singletonSpecialSpaces: Array[SpecialSpace] = []
var regionSpecialSpaces: Array[SpecialSpace] = []
var regularSpecialSpaces: Array[SpecialSpace] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_special_space_arrays()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	if specialSpaces.size() > 0:
		for special in specialSpaces:
			if(special != null && special.isRegional && special.isSingleton):
				warnings.append("%s cannot be regional and singleton" % special.name)
		
		if regularSpecialSpaces.size() > 0 && _is_percentage_spaces_valid(regularSpecialSpaces):
			warnings.append("Non-Singleton, Non-Regional Special Spaces Total Percentage should equal 100")
			
	return warnings

func _is_percentage_spaces_valid(spaces:Array[SpecialSpace]) -> bool:
	var total: int = 0
	for space in spaces:
		total += space.percentage
	
	return total == 100

func _update_special_space_arrays():
	singletonSpecialSpaces = specialSpaces.filter(func(space: SpecialSpace): return space != null && space.isSingleton)
	regionSpecialSpaces = specialSpaces.filter(func(space: SpecialSpace): return space != null && space.isRegional)
	regularSpecialSpaces = specialSpaces.filter(func(space: SpecialSpace): return space != null && (!space.isRegional || !space.isSingleton) )
