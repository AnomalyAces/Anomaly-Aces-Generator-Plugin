@tool
@icon("res://addons/anomalyAcesGenerator/AceRoomGenerator.svg")
extends Node3D

const ROOM_TILE:int = 0
const HALLWAY_TILE:int = 1
const DOOR_TILE:int = 2
const BORDER_TILE:int = 3

@export_group("Room Generator")
@export_subgroup("Room")
@export var start:bool = false : set = set_start
@export var number_of_rooms: int = 10
@export var min_room_size: int = 2
@export var max_room_size:int = 4
@export var room_margin: int = 1
@export var custom_seed : String = "" : set = set_seed
@export_subgroup("Generator Cell")
@export var room_cell_scene: PackedScene
@export var door_type: GeneratorDoor.DOOR_TYPE
@export_subgroup("Grid Map")
@export var cell_size: Vector3i = Vector3i.ONE
@export var mesh_library: MeshLibrary
@export_subgroup("Character")
@export var player: CharacterBody3D



@onready var grid_map: GridMap = $GridMap
@onready var room_mesh: RoomMesh = $RoomMesh

var room_tiles: Array[PackedVector3Array] = []
var room_positions: PackedVector3Array = []

#Incremental Room Vars
var start_room: Vector3
var rooms: Array[Room] = []

func _ready() -> void:
	_initialize_grid_map(cell_size, mesh_library)
	room_mesh.initalize_room_mesh(grid_map, room_cell_scene, door_type)
	
	room_mesh.connect("north_door_opened", _move_to_north_room)
	room_mesh.connect("south_door_opened", _move_to_south_room)
	room_mesh.connect("east_door_opened", _move_to_east_room)
	room_mesh.connect("west_door_opened", _move_to_west_room)
	
	if Engine.is_editor_hint():
		return
	generate()


#Setters
func set_start(_val:bool)->void:
	if Engine.is_editor_hint():
		number_of_rooms = 5
		_initialize_grid_map(cell_size, mesh_library)
		room_mesh.initalize_room_mesh(grid_map, room_cell_scene, door_type)
		generate()


func set_seed(val:String)->void:
	custom_seed = val
	seed(val.hash())


#Helper functions
func generate():
	print("generating room...")
	rooms.clear()
	if !custom_seed.is_empty():
		set_seed(custom_seed) 
	grid_map.clear()
	while rooms.size() < number_of_rooms:
		if rooms.size() == 0:
			_generate_next_rooms()
		else:
			var neighborless_rooms: Array[Room] = rooms.filter(func(r: Room): return !r.neighbors_generated)
			for room in neighborless_rooms:
				_generate_next_rooms(room)
		
	

func _initialize_grid_map(cell_sz: Vector3i, mesh_lib: MeshLibrary):
	grid_map.cell_size = cell_sz
	grid_map.mesh_library = mesh_lib

func _generate_next_rooms(room: Room = null):
	var rooms_to_create: int = clamp(randi_range(1,4), 1, (number_of_rooms - rooms.size()) )
	var directions: Array[String] 
	print("Generating Room and Next %s room neighbors at random..." % rooms_to_create)
	
	var start_pos: Vector3i
	
	if room == null:
		#Select starting position
		start_pos = Vector3i.ZERO
		room = _generate_next_room(start_pos)
		rooms.append(room)
	else:
		#Select starting position
		start_pos = room.tiles.front()
		
		if room.neighbors_generated:
			print("Room %s has already generated neighbors" % room.id)
			return
	
	directions = _filter_room_directions(room)
	
	for i in rooms_to_create:
		if directions.size() == 0:
			break
		var dir: String = directions.pick_random()
		directions.erase(dir)
		print("Direction Selected: %s" % dir)
		var dir_pos: Vector3i = start_pos + (Vector3i(max_room_size+room_margin,0,max_room_size+room_margin ) * AceGeneratorConstants.DIRECTIONS.get(dir))
		
		if grid_map.get_cell_item(dir_pos) == ROOM_TILE:
			print("Position %s already contains a room" % dir_pos)
			continue
		
		match dir:
			"n":
				var n_room: Room = _generate_next_room(dir_pos)
				room.north_room = n_room
				n_room.south_room = room
				_place_room_door(room, dir)
				_place_room_door(n_room, "s")
				rooms.append(n_room)
			"s":
				var s_room: Room = _generate_next_room(dir_pos)
				room.south_room = s_room
				s_room.north_room = room
				_place_room_door(room, dir)
				_place_room_door(s_room, "n")
				rooms.append(s_room)
			"w":
				var w_room: Room = _generate_next_room(dir_pos)
				room.west_room = w_room
				w_room.east_room = room
				_place_room_door(room, dir)
				_place_room_door(w_room, "e")
				rooms.append(w_room)
			"e":
				var e_room: Room = _generate_next_room(dir_pos)
				room.east_room = e_room
				e_room.west_room = room
				_place_room_door(room, dir)
				_place_room_door(e_room, "w")
				rooms.append(e_room)
			_:
				print("Direction %s not supoorted" % dir )
	
	room.neighbors_generated = true
	room_mesh.update_dungeon()

func _filter_room_directions(room: Room) -> Array[String]:
	var directions: Array[String] 
	var temp_array: Array[String] 
	temp_array.append_array(AceGeneratorConstants.DIRECTIONS.keys())
	
	for dir in AceGeneratorConstants.DIRECTIONS.keys():
		match dir:
			"n":
				if room.north_room != null:
					temp_array.erase(dir)
			"s":
				if room.south_room != null:
					temp_array.erase(dir)
			"e":
				if room.east_room != null:
					temp_array.erase(dir)
			"w":
				if room.west_room != null:
					temp_array.erase(dir)
			_:
				push_warning("Direction %s not supported" % dir)
	directions.append_array(temp_array)
	return directions

func _get_start_pos(character: Character) -> Vector3i:	
	var map_position = grid_map.local_to_map(character.position)
	
	print("Character Position: %s" % character.position)
	print("Map Position: %s" % map_position)
	var curr_room: Room = _get_current_room(character)
	
	return curr_room.tiles.front()



func _get_current_room(character: Character) -> Room:
	var map_position = grid_map.local_to_map(character.position)
	
	print("Character Position: %s" % character.position)
	print("Map Position: %s" % map_position)
	
	var curr_room: Room
	
	for room in rooms:
		for tile in room.tiles:
			if map_position.x == tile.x && map_position.z == tile.z:
				curr_room = room
				break
		if curr_room != null:
			break
	return curr_room

func _generate_next_room(start_pos: Vector3i) -> Room:
	
	#Select random width and height for room
	var width: int = (randi() % (max_room_size - min_room_size)) + min_room_size
	var height: int = (randi() % (max_room_size - min_room_size)) + min_room_size
	
	
	
	#Create room
	var room: Room = Room.new()
	for r in height:
		for c in width:
			var pos: Vector3i = start_pos + Vector3i(c,0,r)
			grid_map.set_cell_item(pos, ROOM_TILE)
			room.tiles.append(pos)
	
	#set the rooms starting postiion 
	room.start_position = start_pos
	room.end_position = room.tiles.back()
	return room

func _place_room_door(room: Room, dir: String):
	#Add buffer to avoid corners
	var min_width: int = room.start_position.x
	var max_width: int = room.end_position.x
	var min_height: int = room.start_position.z
	var max_height: int = room.end_position.z
	
	match dir:
		"n":
			var pos: Vector3i = Vector3i(randi_range(min_width+1, max_width-1),0, min_height)
			while grid_map.get_cell_item(pos) == DOOR_TILE:
				pos = Vector3i(randi_range(min_width+1, max_width-1),0, min_height)
			grid_map.set_cell_item(pos, DOOR_TILE)
		"s":
			var pos: Vector3i = Vector3i(randi_range(min_width+1, max_width-1),0, max_height)
			while grid_map.get_cell_item(pos) == DOOR_TILE:
				pos = Vector3i(randi_range(min_width+1, max_width-1),0, max_height)
			grid_map.set_cell_item(pos, DOOR_TILE)
		"e":
			var pos: Vector3i = Vector3i(max_width, 0, randi_range(min_height+1,max_height-1))
			while grid_map.get_cell_item(pos) == DOOR_TILE:
				pos = Vector3i(max_width, 0, randi_range(min_height+1,max_height-1))
			grid_map.set_cell_item(pos, DOOR_TILE)
		"w":
			var pos: Vector3i = Vector3i(min_width, 0, randi_range(min_height+1,max_height-1))
			while grid_map.get_cell_item(pos) == DOOR_TILE:
				pos = Vector3i(min_width, 0, randi_range(min_height+1,max_height-1))
			grid_map.set_cell_item(pos, DOOR_TILE)
		_:
			pass

#Signal Functions
func _move_to_north_room():
	var curr_room = _get_current_room(player)
	var find_north_room_door = func(vec: Vector3i): 
		# Find the door in the south region of the north room
		return grid_map.get_cell_item(vec) && vec.z == curr_room.north_room.end_position.z
	var room_door: Vector3i = AceArrayUtil.findFirst(curr_room.north_room.tiles, find_north_room_door)
	room_door.y = ceili(player.position.y)
	var door_local_pos = grid_map.map_to_local(room_door)
	player.position = Vector3(door_local_pos.x,player.position.y, door_local_pos.z) + Vector3.FORWARD
	print("Moving to north room: %s" % player.position)
	

func _move_to_south_room():
	var curr_room = _get_current_room(player)
	var find_south_room_door = func(vec: Vector3i): 
		# Find the door in the north region of the south room
		return grid_map.get_cell_item(vec) && vec.z == curr_room.south_room.start_position.z
	var room_door: Vector3i = AceArrayUtil.findFirst(curr_room.south_room.tiles, find_south_room_door)
	room_door.y = ceili(player.position.y)
	var door_local_pos = grid_map.map_to_local(room_door)
	player.position = Vector3(door_local_pos.x,player.position.y, door_local_pos.z) + Vector3.BACK
	print("Moving to south room: %s" % player.position)

func _move_to_east_room():
	var curr_room = _get_current_room(player)
	var find_east_room_door = func(vec: Vector3i): 
		# Find the door in the west region of the east room
		return grid_map.get_cell_item(vec) && vec.x == curr_room.east_room.start_position.x
	var room_door: Vector3i = AceArrayUtil.findFirst(curr_room.east_room.tiles, find_east_room_door)
	var door_local_pos = grid_map.map_to_local(room_door)
	player.position = Vector3(door_local_pos.x,player.position.y, door_local_pos.z) + Vector3.RIGHT
	print("Moving to east room: %s" % player.position)

func _move_to_west_room():
	var curr_room = _get_current_room(player)
	var find_west_room_door = func(vec: Vector3i): 
		# Find the door in the east region of the west room
		return grid_map.get_cell_item(vec) && vec.x == curr_room.west_room.end_position.x
	var room_door: Vector3i = AceArrayUtil.findFirst(curr_room.west_room.tiles, find_west_room_door)
	room_door.y = ceili(player.position.y)
	var door_local_pos = grid_map.map_to_local(room_door)
	player.position = Vector3(door_local_pos.x,player.position.y, door_local_pos.z) + Vector3.LEFT
	print("Moving to west room: %s" % player.position)
