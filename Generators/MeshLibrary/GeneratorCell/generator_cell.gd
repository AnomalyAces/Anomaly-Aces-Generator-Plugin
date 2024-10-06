@tool
class_name GeneratorCell extends Node3D

signal north_door_opened
signal south_door_opened
signal east_door_opened
signal west_door_opened

@onready var north_door: GeneratorDoor = get_node("%NorthDoor")
@onready var south_door: GeneratorDoor = get_node("%SouthDoor")
@onready var east_door: GeneratorDoor = get_node("%EastDoor")
@onready var west_door: GeneratorDoor = get_node("%WestDoor")

var room_id: String

func _ready() -> void:
	north_door.connect("door_opened", _on_north_door_opened)
	south_door.connect("door_opened", _on_south_door_opened)
	east_door.connect("door_opened", _on_east_door_opened)
	west_door.connect("door_opened", _on_west_door_opened)

func remove_wall_n():
	$wall_N.free()
func remove_door_n():
	$wall_doorway_N.free()
func remove_wall_s():
	$wall_S.free()
func remove_door_s():
	$wall_doorway_S.free()
func remove_wall_e():
	$wall_E.free()
func remove_door_e():
	$wall_doorway_E.free()
func remove_wall_w():
	$wall_W.free()
func remove_door_w():
	$wall_doorway_W.free()

#Signal Functions
func _on_north_door_opened():
	north_door_opened.emit()

func _on_south_door_opened():
	south_door_opened.emit()

func _on_east_door_opened():
	east_door_opened.emit()

func _on_west_door_opened():
	west_door_opened.emit()
