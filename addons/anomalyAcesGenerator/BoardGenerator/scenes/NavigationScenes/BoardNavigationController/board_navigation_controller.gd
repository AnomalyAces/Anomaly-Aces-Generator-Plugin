@tool
class_name BoardNavigationController extends Node3D

enum CARDINAL { ## Enum for Cardinal Directions
	NORTH, ## North direction
	EAST, ## East direction
	SOUTH, ## South directio
	WEST, ## West direction
	CURR ## Current direction
}


@export var player: AceCharacter3D :
	set(p_player):
		if p_player != player:
			player = p_player
			update_configuration_warnings()
@export var gridMap: GridMap :
	set(p_map):
		if p_map != gridMap:
			gridMap = p_map
			update_configuration_warnings()

@export_group("Editors")
## Configures Spaces and Buildings
@export var spaceEditor: SpaceEditor :
	set(p_spaceEditor):
		if p_spaceEditor != spaceEditor:
			spaceEditor = p_spaceEditor
			update_configuration_warnings()
@export var regionEditor: RegionEditor : 
	set(p_regionEditor):
		if p_regionEditor != regionEditor:
			regionEditor = p_regionEditor
			update_configuration_warnings()
@export_group("Debug")
## Draws a visual representation of the navigation with cubes that denote spaces that have connections
@export var draw_nav_cubes: bool = false



var aStar = AStar3D.new()
var aStar_dict: Dictionary[Vector3i, int] = {}

## Debug Variables
var cube_mesh: BoxMesh = BoxMesh.new()
## Material used to show cube when space has no connections
var no_conn_material = StandardMaterial3D.new()
## Material used to show cube when space has connections
var conn_material = StandardMaterial3D.new()
## Material used to show cube when space has been disabled because of an obstacle
var disabled_material = StandardMaterial3D.new()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if player == null:
		warnings.append("Player of type AceCharacter3D Not Defined")
	if gridMap == null:
		warnings.append("Grid Map of type GridMap AceCameraManager Not Defined")
	if spaceEditor == null:
		warnings.append("Space Editor of type SpaceEditor Not Defined")
	if regionEditor == null:
		warnings.append("Region Editor of type Region Editor Not Defined")
	
	return warnings

## Build A Star Navigaton 
func build_navigation():
	#Set the debug settings
	_set_debug_settings()
	
	aStar.clear()
	aStar_dict.clear()
	var passable_space_indexes: Array[int] = _get_passable_space_indexes()
	var passable_spaces: Array[Vector3i] = []
	
	## Find all the spaces that have passable indexes
	for idx in passable_space_indexes:
		var cell_arr: Array[Vector3i] = gridMap.get_used_cells_by_item(idx)
		passable_spaces.append_array(cell_arr)
		
	## Add all passable spaces to the AStar object and AStar Dictionary
	for space in passable_spaces:
		_add_point(space)
	
	## Connect the points
	for space in passable_spaces:
		_connect_points(space)

func find_path(target: Vector3i) -> Array[Vector3i]:
	## Use the player position as the start and set the y to 0
	var player_pos: Vector3i = gridMap.local_to_map(player.position)
	player_pos.y = 0
	var start_id: int = aStar.get_closest_point(Vector3i(player_pos))
	var end_id: int = aStar.get_closest_point(target)
	var aStar_path: Array[Vector3i] = [] 
	aStar_path.assign( aStar.get_point_path(start_id, end_id) )
	return aStar_path

func find_paths_by_count(target_count_value: int) -> Dictionary[int, CountPathDictionaryObject]:
	## Dictionary that has a key of current count value of CountDictionaryObject which contains a point connection
	## array 
	var count_conn_dict: Dictionary[int, CountConnectionDictionaryObject]
	
	## Dictionary that has a key of path id and a value is a path which is an array of positions
	var count_path_dict: Dictionary[int, CountPathDictionaryObject]
	
	## Use the player position as the start and set the y to 0
	var player_pos: Vector3i = gridMap.local_to_map(player.position)
	player_pos.y = 0
	
	var start_id: int = aStar.get_closest_point(Vector3i(player_pos))
	
	## Get all the connection for each count value up to the target count value
	_get_count_connections(count_conn_dict, 0, target_count_value, start_id)
	
	## After the connection dictionary is built. Get paths from the connected points of the key that matches target
	## count value
	
	## Tracks number of paths that have a length that has the same size that equals target count value 
	var path_count: int = 0
	
	for point in count_conn_dict[target_count_value].point_connections:
		var path: Array[Vector3i] = find_path(aStar_dict.find_key(point))
		## This is target value + 1 because the astar pathing includes the space you are on as the starting space
		if path.size() == target_count_value + 1:
			path_count += 1
			
			if !count_path_dict.has(path_count) :
				count_path_dict[path_count] = CountPathDictionaryObject.new()
			
			count_path_dict[path_count].path.assign(path)
	
	return count_path_dict

func add_obstacle(space: Vector3i):
	var point:int = aStar_dict.get(space)
	aStar.set_point_disabled(point, true)
	var point_nav_cube: MeshInstance3D = _find_nav_cube(space)
	if point_nav_cube != null:
		point_nav_cube.material_override = disabled_material

func remove_obstacle(space: Vector3i):
	var point:int = aStar_dict.get(space)
	aStar.set_point_disabled(point, false)
	var point_nav_cube: MeshInstance3D = _find_nav_cube(space)
	if point_nav_cube != null:
		point_nav_cube.material_override = conn_material

func has_obstacle(space: Vector3i) -> bool:
	var point:int = aStar_dict.get(space)
	return aStar.is_point_disabled(point)

func _add_point(point: Vector3i):
	var id = aStar.get_available_point_id()
	aStar.add_point(id, point)
	aStar_dict[point] = id
	_create_nav_cube(point)

func _connect_points(point: Vector3i):
	var east = point + Vector3i(Vector2i.RIGHT.x, 0, Vector2i.RIGHT.y)
	var west = point + Vector3i(Vector2i.LEFT.x, 0, Vector2i.LEFT.y)
	var north = point + Vector3i(Vector2i.UP.x, 0, Vector2i.UP.y)
	var south = point + Vector3i(Vector2i.DOWN.x, 0, Vector2i.DOWN.y)
	
	var dir_array: Array[Vector3i] = [east, west, north, south]
	
	for dir in dir_array:
		if aStar_dict.has(dir):
			var curr_id = aStar_dict[point]
			var neighbor_id = aStar_dict[dir]
			if !aStar.are_points_connected(curr_id, neighbor_id):
				aStar.connect_points(curr_id, neighbor_id)
			_set_nav_cube_connected(point, dir)
			


## Get list of space indexes that are passable by the player
func _get_passable_space_indexes() -> Array[int] :
	return BoardGeneratorGridUtil.get_passable_space_indexes(gridMap, spaceEditor)
	

## Recursive function to find point connections at each count value up until the target count value
func _get_count_connections(count_dict: Dictionary[int, CountConnectionDictionaryObject],curr_count: int, target_count: int, curr_point_id: int):
	
	## Get point connections for the current astar point
	var point_connections: Array[int] 
	point_connections.assign(aStar.get_point_connections(curr_point_id))
	
	## Increase the curr count
	curr_count += 1
	
	if curr_count <= target_count:
		for point in point_connections:
			if !count_dict.has(curr_count) :
				count_dict[curr_count] = CountConnectionDictionaryObject.new()
			
			if !count_dict[curr_count].point_connections.has(point) :
				count_dict[curr_count].point_connections.append(point)
			
			_get_count_connections(count_dict, curr_count, target_count, point)


##### Debug Methods

## Set/Apply the debug colors
func _set_debug_settings():
	
	#Clear previous nav cubes before building new ones
	var nav_cubes: Array[Node] = get_children()
	for node in get_children():
		if node is MeshInstance3D:
				node.free()
	
	no_conn_material.albedo_color = Color.RED
	conn_material.albedo_color = Color.GREEN
	disabled_material.albedo_color = Color.GOLD
	cube_mesh.size = Vector3(0.25, 0.25, 0.25)

## Creates Nav cubes on map for debugging purposes
func _create_nav_cube(pos: Vector3): 
	if draw_nav_cubes:
		var cube: MeshInstance3D = MeshInstance3D.new()
		cube.mesh = cube_mesh
		cube.material_override = no_conn_material
		#Set the transparency so that the sprites will be rendered on top of them
		cube.transparency = 0.25
		add_child(cube)
		#Set the position y to 1 so its on top of the grid
		pos.y = 1
		#Add the offset from the player so that the mesh is centered in the space
		pos += player.tileMapOffset
		cube.global_transform.origin = pos

## Finds the navigation debug cube that corresponds to the position
func _find_nav_cube(pos: Vector3) -> MeshInstance3D:
	var cube_pos: Vector3 = pos + player.tileMapOffset
	for node in get_children():
		if node is MeshInstance3D:
			## if x and z positions match then we know we have found the right nav cube
			if cube_pos.x == node.position.x && cube_pos.z == node.position.z:
				return node
	return null

## Set nav cube to connected
func _set_nav_cube_connected(point: Vector3i, neighbor: Vector3i):
	if draw_nav_cubes:
		## Update 
		var point_nav_cube: MeshInstance3D = _find_nav_cube(point)
		var neighbor_nav_cube: MeshInstance3D = _find_nav_cube(neighbor)
		
		if point_nav_cube != null:
			point_nav_cube.material_override = conn_material
		if neighbor_nav_cube != null:
			neighbor_nav_cube.material_override = conn_material


class CountConnectionDictionaryObject:
	## Astar point connections
	var point_connections: Array[int]
	
	func _init() -> void:
		point_connections = []
	
	func _to_string() -> String:
		return JSON.stringify(point_connections)

class CountPathDictionaryObject:
	## Path of connection point
	var path: Array[Vector3i]
	
	func _init() -> void:
		path = []
	
	func _to_string() -> String:
		return JSON.stringify(path)
