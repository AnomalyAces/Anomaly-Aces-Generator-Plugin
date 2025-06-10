class_name RegionPropScene extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _init(prop: RegionProp, pos: Vector3i) -> void:
	var prop_offset = Vector3(0.5, 0, 0.5)
	texture = prop.image
	position = Vector3(pos.x, prop.y_pos, pos.z) + prop_offset
	prop.scale = prop.scale
