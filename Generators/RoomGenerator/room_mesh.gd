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

@export var start: bool = false : set = set_start
@export var grid_map: GridMap
@export var room_cell_scene: PackedScene

#var room_cell_scene: PackedScene = preload("res://Generator/MeshLibrary/GeneratorCell.tscn")

var directions : Dictionary = {
	"n": Vector3i.FORWARD,
	"s": Vector3i.BACK,
	"w": Vector3i.LEFT,
	"e": Vector3i.RIGHT
}


func _ready() -> void:
	print("GridMap %s " % grid_map)


#Setters
func set_start(_val:bool)->void:
	if Engine.is_editor_hint():
		update_dungeon()



##Helpers##
#Handler Functions
func handle_none(cell:Node3D, dir: String ):
	var tile_idx: int = grid_map.get_cell_item(cell.position)
	if tile_idx == ROOM_TILE:
		cell.name = "WallTile"
		cell.call("remove_door_"+dir)
	elif tile_idx == DOOR_TILE:
		cell.name = "DoorTile"
		cell.call("remove_wall_"+dir)

# This naming convention uses the tile indexes of the types of tiles we care about
# i.e. handle_00 is going from a room tile (idx:0) to another room tile (idx:0)

#Room to Room 
func handle_00(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)

#Room to Hallway
func handle_01(cell:Node3D, dir: String ):
	cell.call("remove_door_"+dir)

#Room to Door
func handle_02(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)

#Hallway to Room
func handle_10(cell:Node3D, dir: String ):
	cell.call("remove_door_"+dir)

#Hallway to Hallway
func handle_11(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)


#Hallway to Door
func handle_12(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)


#Door to Room
func handle_20(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)

#Door to Hallway
func handle_21(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)

#Door to Door
func handle_22(cell:Node3D, dir: String ):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)



func update_dungeon():
	#if(grid_map == null):
		#grid_map = get_node(grid_map_path)
	
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	for cell in grid_map.get_used_cells():
		var cell_index : int = grid_map.get_cell_item(cell)
		if cell_index <= DOOR_TILE && cell_index >= ROOM_TILE:
			var dun_cell: GeneratorCell = room_cell_scene.instantiate()
			dun_cell.position = Vector3(cell) #+ Vector3(0.5, 0, 0.5) #This offest should be a const
			dun_cell.connect("north_door_opened", _on_north_door_opened)
			dun_cell.connect("south_door_opened", _on_south_door_opened)
			dun_cell.connect("east_door_opened", _on_east_door_opened)
			dun_cell.connect("west_door_opened", _on_west_door_opened)
			add_child(dun_cell)
			dun_cell.set_owner(owner)
			for i in 4: #Number of sides of a room
				var cell_n: Vector3i  = cell + directions.values()[i]
				var cell_n_index: int = grid_map.get_cell_item(cell_n)
				if cell_n_index == -1 || cell_n_index == BORDER_TILE:
					handle_none(dun_cell, directions.keys()[i])
				else:
					var key: String = str(cell_index) + str(cell_n_index)
					call("handle_"+key, dun_cell, directions.keys()[i])
				

func update_dungeon_cell(room_id: String, cell_pos: Vector3):
	var cells:Array[Node] = get_children()
	var cellArr: Array[Node] = get_children().filter(
		func(c:Node):
			var cell: GeneratorCell = c
			print("Room Id: %s | Cell Id: %s" % [room_id, cell.room_id])
			return room_id == c.room_id
	)
	if cellArr.size() > 0:
		print("Updating dungeon cell" % cellArr[0].name)
	
	
	


#Signal Functions
func _on_north_door_opened():
	north_door_opened.emit()

func _on_south_door_opened():
	south_door_opened.emit()

func _on_east_door_opened():
	east_door_opened.emit()

func _on_west_door_opened():
	west_door_opened.emit()
