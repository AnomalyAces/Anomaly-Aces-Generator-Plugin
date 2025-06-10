class_name RegionProp extends Resource
## Image of the Prop
@export var image: Resource:
	set(p_image):
		if p_image != image:
			image = p_image
			emit_changed()
## Y position of prop
@export var y_pos: float:
	set(p_y_pos):
		if p_y_pos != y_pos:
			y_pos = p_y_pos
			emit_changed()
## Scale of Prop
@export var scale: Vector3 = Vector3(1,1,1) :
	set(p_scale):
		if p_scale != scale:
			scale = p_scale
			emit_changed()
## Determines how likely a prop will get chosen. The higher the number the more likely it will be chosen 
@export var weight: int = 1 :
	set(p_weight):
		if p_weight != weight:
			weight = p_weight
			emit_changed()
var acc_weight: int :
	set(p_acc_weight):
		if p_acc_weight != acc_weight:
			acc_weight = p_acc_weight
			emit_changed()
