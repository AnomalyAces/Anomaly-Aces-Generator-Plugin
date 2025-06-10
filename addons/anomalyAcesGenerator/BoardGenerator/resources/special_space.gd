@tool
class_name SpecialSpace extends Space
@export_group("Special Space Config")
## Should this space be present once in all regions
@export var isRegional: bool
## Space should only occur once in the map
@export var isSingleton: bool
## Percentage of Special Spaces that this space should be. All Special Spaces should total 100 that are not regional or singleton.
@export_range(0,100,1) var percentage: int

func _to_string() -> String:
	return "{name: %s, description: %s, isRegional: %s, isSingleton: %s, percentage: %f}" % [name, description, isRegional, isSingleton, percentage]
