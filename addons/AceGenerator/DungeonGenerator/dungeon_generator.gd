@tool
extends Node3D

const ROOM_TILE:int = 0
const HALLWAY_TILE:int = 1
const DOOR_TILE:int = 2
const BORDER_TILE:int = 3

@export_group("Dungeon Generator")
@export var start:bool = false : set = set_start
@export var min_room_size: int = 2
@export var max_room_size:int = 4
@export var room_margin: int = 1
@export var custom_seed : String = "" : set = set_seed
@export var border_size: int = 10: set = set_border_size
@export var room_number: int = 4
@export var room_recursion: int = 15
@export_range(0,1) var survival_chance: float = 0.25


@onready var grid_map: GridMap = $GridMap
@onready var dun_mesh: DungeonMesh = $DunMesh
@onready var player: Character = $DemoCharacter

var room_tiles: Array[PackedVector3Array] = []
var room_positions: PackedVector3Array = []

#Incremental Room Vars
var start_room: Vector3
var rooms: Array[Room] = []

func _ready() -> void:
	generate()
	dun_mesh.create_dungeon()


#Setters
func set_start(_val:bool)->void:
	if Engine.is_editor_hint():
		generate()

func set_border_size(val:int)->void:
	border_size = val
	if Engine.is_editor_hint():
		_visualize_border()

func set_seed(val:String)->void:
	custom_seed = val
	seed(val.hash())


#Helper functions
func _visualize_border():
	print("Border Size %s" % border_size)
	grid_map.clear()
	for i in range(-1,border_size+1):
		grid_map.set_cell_item(Vector3i(i, 0, -1), BORDER_TILE) #North
		grid_map.set_cell_item(Vector3i(i, 0, border_size), BORDER_TILE) #South
		grid_map.set_cell_item(Vector3i(border_size, 0, i), BORDER_TILE) #East
		grid_map.set_cell_item(Vector3i(-1, 0, i), BORDER_TILE) #West

func generate():
	print("generating room...")
	room_tiles.clear()
	room_positions.clear()
	if !custom_seed.is_empty():
		set_seed(custom_seed) 
	_visualize_border()
	for i in room_number:
		_generate_all_rooms(room_recursion)
	_create_hallways()

func _generate_all_rooms(rec:int):
	if rec <= 0:
		return
	
	#Select random width and height for room
	var width: int = (randi() % (max_room_size - min_room_size)) + min_room_size
	var height: int = (randi() % (max_room_size - min_room_size)) + min_room_size
	
	#Select starting position
	var start_pos: Vector3i
	#Set x and z axis
	start_pos.x = randi() % (border_size - width + 1) #Random number bewteen border size and selected width
	start_pos.z = randi() % (border_size - height + 1) #Random number bewteen border size and selected height
	
	#check if room is overrlapping another room
	for r in range(-room_margin, height+room_margin):
		for c in range(-room_margin, width+room_margin):
			var pos: Vector3i = start_pos + Vector3i(c,0,r)
			if grid_map.get_cell_item(pos) == ROOM_TILE:
				_generate_all_rooms(rec-1)
				return
	
	var room: PackedVector3Array = []
	for r in height:
		for c in width:
			var pos: Vector3i = start_pos + Vector3i(c,0,r)
			grid_map.set_cell_item(pos, ROOM_TILE)
			room.append(pos)
	room_tiles.append(room)
	
	#calculate room center
	var avg_x : float = start_pos.x + (float(width) / 2)
	var avg_z : float = start_pos.z + (float(height) / 2)
	
	var room_pos: Vector3 = Vector3(avg_x, 0, avg_z)
	room_positions.append(room_pos)

@warning_ignore("integer_division")
@warning_ignore("narrowing_conversion")
func _create_hallways():
	#Triangulation of Points
	var rpv2: PackedVector2Array = []
	var del_graph : AStar2D = AStar2D.new()
	#Minimum Spanning Tree
	var mst_graph : AStar2D = AStar2D.new()
	for p in room_positions:
		rpv2.append((Vector2(p.x, p.z)))
		del_graph.add_point(del_graph.get_available_point_id(), Vector2(p.x,p.z))
		mst_graph.add_point(mst_graph.get_available_point_id(), Vector2(p.x,p.z))
		
	var delaunay: Array = Array(Geometry2D.triangulate_delaunay(rpv2))
	
	
	for i in delaunay.size()/3: #Divided by 3 because thats the number of triangles
		var p1: int = delaunay.pop_front()
		var p2: int = delaunay.pop_front()
		var p3: int = delaunay.pop_front()
		del_graph.connect_points(p1,p2)
		del_graph.connect_points(p2,p3)
		del_graph.connect_points(p1,p3)
	
	var visited_points : PackedInt32Array = []
	visited_points.append(randi() % room_positions.size())
	
	while visited_points.size() != mst_graph.get_point_count():
		var possible_connections: Array[PackedInt32Array] = []
		for vp in visited_points:
			for c in del_graph.get_point_connections(vp):
				if !visited_points.has(c):
					var con: PackedInt32Array = [vp, c]
					possible_connections.append(con)
		
		var connection : PackedInt32Array = possible_connections.pick_random()
		for pc in possible_connections:
			if rpv2[pc[0]].distance_squared_to(rpv2[pc[1]]) <  \
			rpv2[connection[0]].distance_squared_to(rpv2[connection[1]]):
				connection = pc
		
		visited_points.append(connection[1])
		mst_graph.connect_points(connection[0], connection[1])
		del_graph.disconnect_points(connection[0], connection[1])
	
	var hallway_graph: AStar2D = mst_graph
	
	for p in del_graph.get_point_ids():
		for c in del_graph.get_point_connections(p):
			if c > p:
				var kill: float = randf()
				if survival_chance > kill:
					hallway_graph.connect_points(p,c)
	
	var hallways: Array[PackedVector3Array] = []
	for p in hallway_graph.get_point_ids():
		for c in hallway_graph.get_point_connections(p):
			if c>p:
				var room_from: PackedVector3Array = room_tiles[p]
				var room_to: PackedVector3Array = room_tiles[c]
				var tile_from: Vector3 = room_from[0]
				var tile_to: Vector3 = room_to[0]
				
				for t in room_from:
					if t.distance_squared_to(room_positions[c]) < \
					tile_from.distance_squared_to(room_positions[c]):
						tile_from = t
				for t in room_to:
					if t.distance_squared_to(room_positions[p]) < \
					tile_to.distance_squared_to(room_positions[p]):
						tile_to = t
				var hallway: PackedVector3Array = [tile_from, tile_to]
				hallways.append(hallway)
				#Set Hallway tiles on Map
				grid_map.set_cell_item(tile_from, DOOR_TILE)
				grid_map.set_cell_item(tile_to, DOOR_TILE)
	
	#Find Path between doors
	var astar: AStarGrid2D = AStarGrid2D.new()
	astar.size = Vector2i.ONE * border_size
	astar.update()
	#Prevent Diagnonals
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	
	#Define Room Tiles for Astar Path finding
	for t in grid_map.get_used_cells_by_item(ROOM_TILE):
		astar.set_point_solid(Vector2i(t.x,t.z))
	
	for h in hallways:
		#Path finding bewteen rooms
		var pos_from : Vector2i = Vector2i(h[0].x,h[0].z)
		var pos_to : Vector2i = Vector2i(h[1].x,h[1].z)
		var hall: PackedVector2Array = astar.get_point_path(pos_from, pos_to)
	
		#Set Hallway Tiles finding bewteen rooms
		for t in hall:
			var pos: Vector3i = Vector3i(t.x,0,t.y)
			if grid_map.get_cell_item(pos) < 0:
				grid_map.set_cell_item(pos,HALLWAY_TILE)
