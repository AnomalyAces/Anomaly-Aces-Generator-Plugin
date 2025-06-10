@tool
@icon("res://addons/anomalyAcesGenerator/BoardGenerator/AceBoardGenerator.svg")
class_name AceBoardGenerator extends Node3D

@export var generate:bool = false : set = set_generate
@export_group("Mesh Library")
##Mesh Library Containing All the Spaces, Buildings and Props
@export var meshLibrary: MeshLibrary = null :
	set(p_meshLib):
		if p_meshLib != meshLibrary:
			meshLibrary = p_meshLib
			update_configuration_warnings()
@export_group("Editors")
## Configures Spaces and Buildings
@export var spaceEditor: SpaceEditor
@export var regionEditor: RegionEditor : 
	set(p_regionEditor):
		print("Region Editor updated")
		#if regionEditor != null && regionEditor.editor_updated.is_connected(_region_editor_updated):
			#regionEditor.editor_updated.disconnect(_region_editor_updated)
		regionEditor = p_regionEditor
		#regionEditor.editor_updated.connect(_region_editor_updated)
@export var buildingEditor: BuildingEditor :
	set(p_buildingEditor):
		print("Building Editor updated")
		buildingEditor = p_buildingEditor
		


## Navigation Controller
@onready var navigation: BoardNavigationController = $Navigation

## GridMap
@onready var gridMap: GridMap = $GridMap

## Player
##TODO: This will need to be updated to handle all players
@onready var character: BoardDemoCharacter = $BoardDemoCharacter

#Obstacles Parent
@onready var obstacles: Node3D = $Obstacles


#Setters
func set_generate(_val:bool)->void:
	if Engine.is_editor_hint():
		generate = false
		gridMap.clear()
		for node in obstacles.get_children():
			if node is BoardNavigationObstacle:
				node.queue_free()
		gridMap.mesh_library = meshLibrary
		generate_board()
		navigation.build_navigation()

#Signals
func _region_editor_updated(editor: RegionEditor):
	print("Ace Generator Updating Region Editor...")
	regionEditor = editor

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if meshLibrary == null:
		warnings.append("Mesh Library Not Defined")
	
	return warnings

func _ready() -> void:
	#TODO: Set this position to the position of the DivinerHQ Space
	character.position = Vector3(2,1,2) + character.tileMapOffset
	self.set_editable_instance(spaceEditor, true)
	gridMap.clear()
	for node in obstacles.get_children():
			if node is BoardNavigationObstacle:
				node.queue_free()
	gridMap.mesh_library = meshLibrary
	if Engine.is_editor_hint():
		return
	generate_board()
	navigation.build_navigation()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var map_loc: Vector3i = gridMap.local_to_map(character.position)
		var region: Region = _find_region(regionEditor.regions, map_loc.x, map_loc.z)
		var random_cell:= Vector3i.ZERO
		
		while gridMap.get_cell_item(random_cell) != gridMap.mesh_library.find_item_by_name(spaceEditor.normalSpace.name):
			random_cell.x = randi_range(region.space_height_range.x, region.space_height_range.y)
			random_cell.z = randi_range(region.space_width_range.x, region.space_width_range.y)
		
		
		print("Character starting Pos: %s" % character.position)
		print("Chosen cell: %s" % random_cell)
		
		#var cell_loc = gridMap.map_to_local(random_cell)
		#print("Local cell location: %s" % cell_loc)
		var path: Array[Vector3i] = navigation.find_path(random_cell)
		print("path(%d): %s " % [path.size(),JSON.stringify(path)] )
		character.update_path(path)
		print("navigation done")
	
	if event.is_action_pressed("roll"):
		var count: int = randi_range(2, 12)
		print("Path by count dictionary | count %d " % count)
		var count_dict: Dictionary[int, BoardNavigationController.CountPathDictionaryObject] = navigation.find_paths_by_count(count)
		
		print(JSON.stringify(count_dict, "\t"))
	
	if event.is_action_pressed("obstacle"):
		var space: Vector3i = Vector3i(4,0,2)
		#Hard code an obstable to see if it get avoided
		if navigation.has_obstacle(space):
			navigation.remove_obstacle(space)
		else:
			navigation.add_obstacle(space)
		
		

func generate_board() -> void:
	#Place Environmetal Tiles
	var rows: int = _calculate_cols()
	var columns: int = _calculate_rows()
	for row in range(0, rows):
		for col in range(0, columns):
			var region: Region = _find_region(regionEditor.regions, row, col)
			if region != null:
				if _is_region_space_border(region, row, col):
					BoardGeneratorGridUtil.setSpaceByName(gridMap, spaceEditor.normalSpace, Vector3i(row, 0, col))
				else:
					BoardGeneratorGridUtil.setSpaceByName(gridMap, region.environmentSpace, Vector3i(row, 0, col))
	#Place Normal Spaces
	_place_normal_spaces()
	
	#Place Special Spaces
	_place_special_spaces()
	
	#Place Buildings
	_place_buildings()
	
	

func _calculate_rows() -> int:
	var maxHeight = 0
	for region in regionEditor.regions:
		if region.height > maxHeight:
			maxHeight = region.height
	
	return maxHeight * regionEditor.mapHeight

func _calculate_cols() -> int:
	var maxWidth = 0
	for region in regionEditor.regions:
		if region.width > maxWidth:
			maxWidth = region.width
	
	return maxWidth * regionEditor.mapWidth

func _is_region_space_border(region: Region, row: int, col: int) -> bool:
	return ((row == region.space_height_range.x  || row == region.space_height_range.y) ||
			(col == region.space_width_range.x || col == region.space_width_range.y)) && \
			_is_in_subregion(region, row, col)

func _is_in_region(region: Region, row: int, col: int) -> bool:
	return region.region_height_range.x <= row \
	&& region.region_height_range.y >= row \
	&& region.region_width_range.x <= col \
	&& region.region_width_range.y >= col

func _is_in_subregion(region: Region, row: int, col: int) -> bool:
	return region.space_height_range.x <= row \
	&& region.space_height_range.y >= row \
	&& region.space_width_range.x <= col \
	&& region.space_width_range.y >= col

func _find_region(regionArr: Array[Region], row: int, col: int ) -> Region:
	var filteredArr: Array[Region] = regionArr.filter(func(reg): return _is_in_region(reg, row, col))
	if filteredArr.size() > 0:
		return filteredArr[0]
	else:
		return null

func _place_normal_spaces():
	for r in range(regionEditor.mapHeight):
		for c in range(regionEditor.mapWidth):
			var region: Region = regionEditor.regionMap[r][c]
			# Right Region exists
			if c+1 < regionEditor.mapWidth:
				var destRegion: Region = regionEditor.regionMap[r][c+1]
				_connect_regions(region, destRegion, Vector2i.RIGHT)
			# South Region exists
			if r+1 < regionEditor.mapHeight:
				var destRegion: Region = regionEditor.regionMap[r+1][c]
				_connect_regions(region, destRegion, Vector2i.DOWN)

func _connect_regions(start: Region, dest: Region, dir: Vector2i):
	if dir == Vector2i.RIGHT:
		var x = start.space_height_range.y
		var y = randi_range(start.space_width_range.x, start.space_width_range.y) 
		var start_space:Vector3i = Vector3i(x, 0, y)
		var dest_space:Vector3i = Vector3i(dest.space_height_range.x, 0,y)
		var target_space:Vector3i = start_space
		while target_space != dest_space:
			target_space = target_space + Vector3i(dir.x,0,dir.y)
			BoardGeneratorGridUtil.setSpaceByName(gridMap, spaceEditor.normalSpace, target_space)
	if dir == Vector2i.DOWN:
		var x = randi_range(start.space_height_range.x, start.space_height_range.y)
		var y = start.space_width_range.y
		var start_space:Vector3i = Vector3i(x, 0, y)
		var dest_space:Vector3i = Vector3i(x, 0,dest.space_width_range.x)
		var target_space:Vector3i = start_space
		while target_space != dest_space:
			target_space = target_space + Vector3i(dir.x,0,dir.y)
			BoardGeneratorGridUtil.setSpaceByName(gridMap, spaceEditor.normalSpace, target_space)

func _place_navigation_obstacles():
	var normal_space_arr: Array[Vector3i] = BoardGeneratorGridUtil.getSpacesByName(gridMap, spaceEditor.normalSpace)
	for space in normal_space_arr:
		var east = space + Vector3i(Vector2i.RIGHT.x, 0, Vector2i.RIGHT.y)
		var west = space + Vector3i(Vector2i.LEFT.x, 0, Vector2i.LEFT.y)
		var north = space + Vector3i(Vector2i.UP.x, 0, Vector2i.UP.y)
		var south = space + Vector3i(Vector2i.DOWN.x, 0, Vector2i.DOWN.y)
		
		var dir_array: Array[Vector3i] = [east, west, north, south]
		
		for dir in dir_array :
			if gridMap.get_cell_item(dir) != gridMap.mesh_library.find_item_by_name(spaceEditor.normalSpace.name):
				var obs_scene = BoardNavigationObstacle.get_obstacle_scene()
				obstacles.add_child(obs_scene)
				obs_scene.position = gridMap.map_to_local(Vector3i(dir.x,1,dir.z))
		


func _place_special_spaces():
	randomize()
	var normal_places_arr: Array[Vector3i] = BoardGeneratorGridUtil.getSpacesByName(gridMap, spaceEditor.normalSpace)
	normal_places_arr.shuffle()
	print("Normal Spaces Placed:  %s" % normal_places_arr.size())
	
	#Place Singletons
	_place_singleton_special_spaces(normal_places_arr)
	print("Normal Spaces After Singleton Spaces:  %s" % normal_places_arr.size())
	
	#Place Regionals
	_place_regional_special_spaces(normal_places_arr)
	print("Normal Spaces After Regional Spaces:  %s" % normal_places_arr.size())
	
	

func _place_singleton_special_spaces(normal_spaces: Array[Vector3i]):
	for singleton in spaceEditor.specialSpaceEditor.singletonSpecialSpaces:
		#Select Space for Singleton
		var target_space: Vector3i = normal_spaces.pop_back()
		BoardGeneratorGridUtil.setSpaceByName(gridMap, singleton, target_space, Enum.Orientation3D.ROTATE_Y_0)

func _place_regional_special_spaces(normal_spaces: Array[Vector3i]):
	
	var regional_spaces: Array[SpecialSpace] = spaceEditor.specialSpaceEditor.regionSpecialSpaces.duplicate(true)
	var region_dict: Dictionary[int, Variant] = {}
	var regions: Array[Region] = regionEditor.regions.duplicate()
	
	print("Regional Spaces: %s" % JSON.stringify(regional_spaces, "\t"))
	
	var spaces_to_return: Array[Vector3i] = []
	
	#Find Valid spaces for each regional space in each region
	while regions.size() > 0:
		var target_space: Vector3i = normal_spaces.pop_back()
		var space_added: bool = false
	
		#Loop through regions and find which region contains target space
		for region in regions:
			if _is_in_region(region, target_space.x, target_space.z):
				print("Region UID: %d  Region Environment Space %s" % [region.id, region.environmentSpace.name])
				var region_space_arr: Array[Vector3i]
				if region_dict.has(region.id):
					region_space_arr = region_dict.get(region.id) as Array[Vector3i]
					region_space_arr.push_back(target_space)
				else:
					region_dict[region.id] = [] as Array[Vector3i]
					region_space_arr = region_dict.get(region.id) as Array[Vector3i]
					region_space_arr.push_back(target_space)
				space_added = true
				break
		
		if !space_added:
			spaces_to_return.append(target_space)
		
		#Loop through region dict and remove any region that has all regional spaces
		for region_id in region_dict:
			if region_dict.get(region_id).size() == regional_spaces.size():
				var region_to_remove: Region =  AceArrayUtil.findFirst(regions, func(region:Region): return region.id == region_id)
				if region_to_remove != null:
					print("Removing Region UID: %d  Region Environment Space %s" % [region_to_remove.id, region_to_remove.environmentSpace.name])
					regions.erase(region_to_remove)
	
	
	#Now that the spaces have been found. Assign a regional space to each
	for region_id in region_dict:
		regional_spaces.shuffle()
		for i in range(regional_spaces.size()):
			BoardGeneratorGridUtil.setSpaceByName(gridMap, regional_spaces[i], region_dict.get(region_id)[i], Enum.Orientation3D.ROTATE_Y_0)
	
	
	#Return all unused spaces to the normal array
	normal_spaces.append_array(spaces_to_return)


func _is_south(chosen_space: Vector3i, special_spaces: Array[SpecialSpace]):
	var east = chosen_space + Vector3i(Vector2i.RIGHT.x, 0, Vector2i.RIGHT.y)
	var west = chosen_space + Vector3i(Vector2i.LEFT.x, 0, Vector2i.LEFT.y)
	var north = chosen_space + Vector3i(Vector2i.UP.x, 0, Vector2i.UP.y)
	var south = chosen_space + Vector3i(Vector2i.DOWN.x, 0, Vector2i.DOWN.y)
	
	var special_space_indices: Array = special_spaces.map( func(space: SpecialSpace): return gridMap.mesh_library.find_item_by_name(space.name) )
	
	return gridMap.get_cell_item(east) in special_space_indices \
		&& gridMap.get_cell_item(west) in special_space_indices \
		&& gridMap.get_cell_item(north) in special_space_indices \
		&& gridMap.get_cell_item(south) in special_space_indices
		

func _place_buildings():
	var building_arr: Array[Building] = buildingEditor.buildings
	
	for building in building_arr:
		print("Placing %s building" % building.buildingName)
		var building_spaces: Array[Vector3i] = gridMap.get_used_cells_by_item(building.spaceIndex)
		
		for space in building_spaces:
			_get_building_space(space, building.buildingIndex)


func _get_building_space(target: Vector3i, building_tile_id: int):
	var east = target + Vector3i(Vector2i.RIGHT.x, 0, Vector2i.RIGHT.y)
	var west = target + Vector3i(Vector2i.LEFT.x, 0, Vector2i.LEFT.y)
	var north = target + Vector3i(Vector2i.UP.x, 0, Vector2i.UP.y)
	var south = target + Vector3i(Vector2i.DOWN.x, 0, Vector2i.DOWN.y)
	
	if(gridMap.get_cell_item(north) <= 5 && gridMap.get_cell_item(north) > gridMap.INVALID_CELL_ITEM):
		print("Building Space: %s" % target)
		print("Placing Building: %s" % north)
		gridMap.set_cell_item(Vector3i(north.x, 1, north.z), building_tile_id, Enum.Orientation3D.ROTATE_Y_180)
		return
	if(gridMap.get_cell_item(east)  <= 5 && gridMap.get_cell_item(east) > gridMap.INVALID_CELL_ITEM):
		print("Building Space: %s" % target)
		print("Placing Building: %s" % east)
		gridMap.set_cell_item(Vector3i(east.x, 1, east.z), building_tile_id, Enum.Orientation3D.ROTATE_Y_270)
		return
	if(gridMap.get_cell_item(west) <= 5 && gridMap.get_cell_item(west) > gridMap.INVALID_CELL_ITEM):
		print("Building Space: %s" % target)
		print("Placing Building: %s" % west)
		gridMap.set_cell_item(Vector3i(west.x, 1, west.z), building_tile_id, Enum.Orientation3D.ROTATE_Y_90)
		return
	if(gridMap.get_cell_item(south) <= 5 && gridMap.get_cell_item(south) > gridMap.INVALID_CELL_ITEM):
		print("Building Space: %s" % target)
		print("Placing Building: %s" % south)
		gridMap.set_cell_item(Vector3i(south.x, 1, south.z), building_tile_id, Enum.Orientation3D.ROTATE_Y_0)
		return
	
	return Vector3.ZERO
