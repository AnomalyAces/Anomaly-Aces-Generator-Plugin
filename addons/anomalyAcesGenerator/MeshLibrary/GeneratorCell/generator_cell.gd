@tool
class_name GeneratorCell extends Node3D

signal north_door_opened
signal north_door_closed
signal south_door_opened
signal south_door_closed
signal east_door_opened
signal east_door_closed
signal west_door_opened
signal west_door_closed

@onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var north_door: GeneratorDoor = get_node("%NorthDoor/StaticBody3D")
@onready var south_door: GeneratorDoor = get_node("%SouthDoor/StaticBody3D")
@onready var east_door: GeneratorDoor = get_node("%EastDoor/StaticBody3D")
@onready var west_door: GeneratorDoor = get_node("%WestDoor/StaticBody3D")


var door_type: GeneratorDoor.DOOR_TYPE


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if anim_player:
		if north_door.has_method("initialize_door"):
			north_door.initialize_door(anim_player, "north_door", door_type)
		if south_door.has_method("initialize_door"):
			south_door.initialize_door(anim_player, "south_door", door_type)
		if east_door.has_method("initialize_door"):
			east_door.initialize_door(anim_player, "east_door", door_type)
		if west_door.has_method("initialize_door"):
			west_door.initialize_door(anim_player, "west_door", door_type)
	
	
	north_door.connect("door_opened", _on_north_door_opened)
	south_door.connect("door_opened", _on_south_door_opened)
	east_door.connect("door_opened", _on_east_door_opened)
	west_door.connect("door_opened", _on_west_door_opened)
	
	north_door.connect("door_closed", _on_north_door_closed)
	south_door.connect("door_closed", _on_south_door_closed)
	east_door.connect("door_closed", _on_east_door_closed)
	west_door.connect("door_closed", _on_west_door_closed)

func remove_wall_n():
	$wall_N.free()
func remove_door_n():
	$doorway_N.free()
func remove_wall_s():
	$wall_S.free()
func remove_door_s():
	$doorway_S.free()
func remove_wall_e():
	$wall_E.free()
func remove_door_e():
	$doorway_E.free()
func remove_wall_w():
	$wall_W.free()
func remove_door_w():
	$doorway_W.free()

#Signal Functions
func _on_north_door_opened():
	north_door.set_collision_layer_value(1, false)
	north_door_opened.emit()

func _on_north_door_closed():
	north_door.set_collision_layer_value(1, true)

func _on_south_door_opened():
	south_door.set_collision_layer_value(1, false)
	south_door_opened.emit()

func _on_south_door_closed():
	south_door.set_collision_layer_value(1, true)

func _on_east_door_opened():
	east_door.set_collision_layer_value(1, false)
	east_door_opened.emit()

func _on_east_door_closed():
	east_door.set_collision_layer_value(1, true)

func _on_west_door_opened():
	west_door.set_collision_layer_value(1, false)
	west_door_opened.emit()
	
func _on_west_door_closed():
	west_door.set_collision_layer_value(1, true)
	
	
