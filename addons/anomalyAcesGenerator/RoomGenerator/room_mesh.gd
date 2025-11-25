@tool
class_name RoomMesh extends Node3D

const ROOM_TILE:int = 0
const HALLWAY_TILE:int = 1
const DOOR_TILE:int = 2
const BORDER_TILE:int = 3

signal north_door_opened
signal south_door_opened
signal east_door_opened
signal west_door_opened

var grid_map: GridMap
var room_cell_scene: PackedScene
var room_door_type: GeneratorDoor.DOOR_TYPE

#var room_cell_scene: PackedScene = preload("res://Generator/MeshLibrary/GeneratorCell.tscn")

var directions : Dictionary = {
	"n": Vector3i.FORWARD,
	"s": Vector3i.BACK,
	"w": Vector3i.LEFT,
	"e": Vector3i.RIGHT
}


func _ready() -> void:
	AceLog.printLog(["GridMap %s " % grid_map])



##Intialize##
func initalize_room_mesh(g_map: GridMap, cell_scene: PackedScene, d_type: GeneratorDoor.DOOR_TYPE):
	grid_map = g_map
	room_cell_scene = cell_scene
	room_door_type = d_type


func update_dungeon():
	#if(grid_map == null):
		#grid_map = get_node(grid_map_path)
	
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	for cell in grid_map.get_used_cells():
		var cell_index : int = grid_map.get_cell_item(cell)
		if cell_index <= DOOR_TILE && cell_index >= ROOM_TILE:
			var room_cell: GeneratorCell = room_cell_scene.instantiate()
			room_cell.door_type = room_door_type
			AceLog.printLog(["Grid Map Pos %s" % cell])
			AceLog.printLog(["Local Pos %s" % grid_map.map_to_local(cell)])
			room_cell.position = grid_map.map_to_local(cell) + _get_grid_map_offset()
			AceLog.printLog(["Local Pos Offset %s" % room_cell.position])
			room_cell.connect("north_door_opened", _on_north_door_opened)
			room_cell.connect("south_door_opened", _on_south_door_opened)
			room_cell.connect("east_door_opened", _on_east_door_opened)
			room_cell.connect("west_door_opened", _on_west_door_opened)
			add_child(room_cell)
			room_cell.set_owner(owner)
			for i in 4: #Number of sides of a room
				var cell_n: Vector3i  = cell + directions.values()[i]
				var cell_n_index: int = grid_map.get_cell_item(cell_n)
				if cell_n_index == -1 || cell_n_index == BORDER_TILE:
					_handle_none(room_cell, directions.keys()[i])
				else:
					var key: String = str(cell_index) + str(cell_n_index)
					call("_handle_"+key, room_cell, directions.keys()[i])
				


###Helpers###

##Handler Functions
func _handle_none(cell:Node3D, dir: String ):
	var tile_idx: int = grid_map.get_cell_item(grid_map.local_to_map(cell.position))
	if tile_idx == ROOM_TILE:
		cell.name = "WallTile"
		cell.call("remove_door_"+dir)
	elif tile_idx == DOOR_TILE:
		cell.name = "DoorTile"
		cell.call("remove_wall_"+dir)

# This naming convention uses the tile indexes of the types of tiles we care about
# i.e. handle_00 is going from a room tile (idx:0) to another room tile (idx:0)

#Room to Room 
func _handle_00(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)

#Room to Hallway
func _handle_01(cell:Node3D, dir: String ):
	cell.call("remove_door_"+dir)

#Room to Door
func _handle_02(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)

#Hallway to Room
func _handle_10(cell:Node3D, dir: String ):
	cell.call("remove_door_"+dir)

#Hallway to Hallway
func _handle_11(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)


#Hallway to Door
func _handle_12(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)


#Door to Room
func _handle_20(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)

#Door to Hallway
func _handle_21(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)

#Door to Door
func _handle_22(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)


##Utility
func _get_grid_map_offset() -> Vector3:
	return Vector3(-grid_map.cell_size.x, 0, -grid_map.cell_size.z) * 0.5


##Signals Functions##
func _on_north_door_opened():
	north_door_opened.emit()

func _on_south_door_opened():
	south_door_opened.emit()

func _on_east_door_opened():
	east_door_opened.emit()

func _on_west_door_opened():
	west_door_opened.emit()
