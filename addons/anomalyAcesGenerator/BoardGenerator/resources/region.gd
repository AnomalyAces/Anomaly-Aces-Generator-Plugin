@tool
class_name Region extends Resource

static var region_id: int = 0

@export_group("Environment")
## Environment tile index from Mesh Library that should be placed in region
@export var environmentSpace: Space :
	set(p_environmentSpace):
		if p_environmentSpace != environmentSpace:
			environmentSpace = p_environmentSpace
			_assign_id()
			emit_changed()
@export_group("Size")
## Width of region
@export var width: int :
	set(p_width):
		if p_width != width:
			width = p_width
			_assign_id()
			emit_changed()
## Height of region
@export var height: int :
	set(p_height):
		if p_height != height:
			height = p_height
			_assign_id()
			emit_changed()
@export_group("Props")
## Min number of Props to place in region
@export var minProps: int :
	set(p_minProps):
		if p_minProps != minProps:
			minProps = p_minProps
			_assign_id()
			emit_changed()
## Max number of Props to place in region
@export var maxProps: int :
	set(p_maxProps):
		if p_maxProps != maxProps:
			maxProps = p_maxProps
			_assign_id()
			emit_changed()
## List of Props to show in region
@export var propList: Array[RegionProp]
## Unique Region Identifier
var id: int = -1
## Region Ranges
var region_width_range: Vector2i = Vector2i.ZERO
var region_height_range: Vector2i = Vector2i.ZERO
## Space Ranges
var space_width_range: Vector2i = Vector2i.ZERO
var space_height_range: Vector2i = Vector2i.ZERO


func _assign_id():
	if id == -1:
		id = region_id
		region_id += 1

func pick_random_space() -> Vector3i:
	var x = randi_range(region_width_range.x,region_width_range.y)
	var y = randi_range(region_height_range.x, region_height_range.y)
	return Vector3i(x, 0, y)
