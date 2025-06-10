class_name BoardGeneratorGridUtil extends Object

static func setSpaceByName(grid: GridMap, space: Space, pos: Vector3i, orientation: int = Enum.Orientation3D.ROTATE_Y_0 ) -> bool:
	var idx = grid.mesh_library.find_item_by_name(space.name)
	
	if idx != -1:
		grid.set_cell_item(pos,idx,orientation)
		return true
	else:
		push_warning("Space %s does not match a space name in the mesh library" % space.name)
		return false

static func getIndexByName(grid: GridMap, space: Space) -> int :
	return grid.mesh_library.find_item_by_name(space.name)

static func getSpacesByName(grid: GridMap, space: Space) -> Array[Vector3i]:
	var idx = grid.mesh_library.find_item_by_name(space.name)
	if idx != 1:
		return grid.get_used_cells_by_item(idx)
	else:
		push_warning("Space %s does not match a space name in the mesh library" % space.name)
		return []

static func isLocationDefinedSpace(pos: Vector3, grid: GridMap, spaceEditor:SpaceEditor) -> bool:
	#Set y of position to 0 for grid map discovery
	pos.y = 0
	
	#Get Map Pos from given position
	var map_pos = grid.local_to_map(pos)
	var idx: int = grid.get_cell_item(map_pos)
	
	#compare normal space idx to position idx
	if idx == getIndexByName(grid, spaceEditor.normalSpace):
		return true
	#compare special space idx to position idx
	for specialSpace in spaceEditor.specialSpaceEditor.specialSpaces:
		if idx == getIndexByName(grid, specialSpace):
			return true
	
	return false
	
