class_name Room extends Object

static var count: int = 0

var id: String
var tiles: Array[Vector3i] = []
var start_position: Vector3i
var end_position: Vector3i
var north_room: Room
var south_room: Room
var west_room: Room
var east_room: Room
var neighbors_generated: bool = false

func _init() -> void:
	count+=1
	id = "Room-"+str(count)
