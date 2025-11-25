class_name BoardGeneratorGridUtil extends Object

################################
## Helper Classes and Funcitons
################################

# Vector3iArray
class Vector3iArray:
	var array: Array[Vector3i] = []

## Grid Point of Interest
## 
## Information about a point of interest on the GridMap
class GridPOI:
	var space: Space
	var location: Vector3i

	func _to_string() -> String:
		return "%s: Location %s" % [space.displayName, location]

##################################

static func setSpaceByName(grid: GridMap, space: Space, pos: Vector3i, orientation: int = Enum.Orientation3D.ROTATE_Y_0 ) -> bool:
	var idx = grid.mesh_library.find_item_by_name(space.name)
	
	if idx != -1:
		grid.set_cell_item(pos,idx,orientation)
		return true
	else:
		AceLog.printLog(["Space %s does not match a space name in the mesh library" % space.name], AceLog.LOG_LEVEL.WARN)
		return false

static func getIndexBySpace(grid: GridMap, space: Space) -> int :
	return grid.mesh_library.find_item_by_name(space.name)

static func getSpacesByName(grid: GridMap, space: Space) -> Array[Vector3i]:
	var idx = grid.mesh_library.find_item_by_name(space.name)
	if idx != 1:
		return grid.get_used_cells_by_item(idx)
	else:
		AceLog.printLog(["Space %s does not match a space name in the mesh library" % space.name], AceLog.LOG_LEVEL.WARN)
		return []

static func isLocationDefinedSpace(pos: Vector3, grid: GridMap, spaceEditor:SpaceEditor) -> bool:
	#Set y of position to 0 for grid map discovery
	pos.y = 0
	
	#Get Map Pos from given position
	var map_pos = grid.local_to_map(pos)
	var idx: int = grid.get_cell_item(map_pos)
	
	#compare normal space idx to position idx
	if idx == getIndexBySpace(grid, spaceEditor.normalSpace):
		return true
	#compare special space idx to position idx
	for specialSpace in spaceEditor.specialSpaceEditor.specialSpaces:
		if idx == getIndexBySpace(grid, specialSpace):
			return true
	
	return false

static func get_passable_space_indexes( grid: GridMap, spaceEditor:SpaceEditor) -> Array[int] :
	var passable_spaces: Array[int] = []
	# Add the normal spaces
	passable_spaces.append(BoardGeneratorGridUtil.getIndexBySpace(grid,spaceEditor.normalSpace))
	# Add Special Spaces
	var special_spaces: Array[int] = []
	special_spaces.assign(spaceEditor.specialSpaceEditor.specialSpaces.map(
			func(space:SpecialSpace): return BoardGeneratorGridUtil.getIndexBySpace(grid,space)
		) 
	)
	passable_spaces.append_array(special_spaces)
	
	return passable_spaces

static func add_vector3i_to_space_dict(_space_dict: Dictionary[Space, Vector3iArray], space: Space, vect: Vector3i) -> void:
	if !_space_dict.has(space):
		_space_dict[space] = Vector3iArray.new()
	
	var vect_array: Vector3iArray = _space_dict.get(space) as Vector3iArray
	vect_array.array.append(vect)

	_space_dict[space] = vect_array






	
