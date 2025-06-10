@tool
class_name RegionEditor extends Node

signal editor_updated(editor:RegionEditor)

## Width of map in regions 
@export var mapWidth:int :
	set(p_cols):
		if p_cols != mapWidth:
			mapWidth = p_cols
			update_configuration_warnings()
			_on_value_updated()
## Height of map in regions
@export var mapHeight:int :
	set(p_height):
		if p_height != mapHeight:
			mapHeight = p_height
			update_configuration_warnings()
			_on_value_updated()
## Offset from the edge of a region. This is the area spaces are placed in a region excluding connecting spaces between regions
@export var subRegionOffset:int :
	set(p_subRegionOffset):
		if p_subRegionOffset != subRegionOffset:
			subRegionOffset = p_subRegionOffset
			update_configuration_warnings()
			_on_value_updated()
@export_subgroup("Region List")
## List of regions for the game board
@export var regions: Array[Region]:
	set(p_regions):
		if p_regions != regions:
			regions = p_regions
			update_configuration_warnings()
			_attach_resource_signal(regions)
			_on_value_updated()
			
## Regions mapped by desired rows and cols
var regionMap: Array[Array] =[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_build_region_map()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if mapWidth == 0:
		warnings.append("Region Columns not defined")
	
	if mapHeight == 0:
		warnings.append("Region Rows not defined")
		
	if regions.size() == 0:
		warnings.append("No Regions are defined")
	
	if regions.size() != mapWidth * mapHeight:
		warnings.append("%d Regions not enough to fill out rows (%d) and columns (%d) selected. Expected Regions %d " % [regions.size(), mapHeight, mapWidth, mapHeight*mapWidth])
	
	else:
		for i in regions.size():
			if regions[i].environmentSpace == null:
				warnings.append("[%d] Region does not have environment space defined" % i)
			if regions[i].propList.size() > 0:
				for p in regions[i].propList:
					if regions[i].propList[p].image == null:
						warnings.append("Region [%d] Prop [%d] does not have image defined" % [i, p])
	
	return warnings

func _build_region_map():
	
	#Clear Region Map
	regionMap.clear()
	
	#Add regions to region map double array
	var temp_regions: Array[Region] = regions.duplicate()
	
	#clear the regions array. We will be adding the regions back with updated range info
	regions.clear()
	
	## Row of regions
	var regionRow: Array[Region] = []
	while temp_regions.size() > 0:
		var region: Region = temp_regions.pop_front()

		if regionRow.size() < mapWidth:
			#Assign ranges to region
			#region.region_width_range = Vector2i(regionRow.size() * region.width, (regionRow.size() * region.width) + region.width - 1 )
			#region.region_height_range = Vector2i(regionMap.size() * region.height, (regionMap.size() * region.height) + region.height - 1 )
			region.region_width_range = Vector2i(regionMap.size() * region.height, (regionMap.size() * region.height) + region.height - 1 )
			region.region_height_range = Vector2i(regionRow.size() * region.width, (regionRow.size() * region.width) + region.width - 1 )
			
			#Assign space ranges to region
			region.space_width_range = Vector2i(region.region_width_range.x + subRegionOffset, region.region_width_range.y - subRegionOffset)
			region.space_height_range = Vector2i(region.region_height_range.x + subRegionOffset, region.region_height_range.y - subRegionOffset)
			
			#add region to region row
			regionRow.append(region)
			
			#add region to region list
			regions.append(region)
		else:
			#add region row to region map
			regionMap.append(regionRow.duplicate())
			
			#clear region row
			regionRow.clear()
			
			#Assign ranges to region
			#region.region_width_range = Vector2i(regionRow.size() * region.width, (regionRow.size() * region.width) + region.width - 1 )
			#region.region_height_range = Vector2i(regionMap.size() * region.height, (regionMap.size() * region.height) + region.height - 1 )
			region.region_width_range = Vector2i(regionMap.size() * region.height, (regionMap.size() * region.height) + region.height - 1 )
			region.region_height_range = Vector2i(regionRow.size() * region.width, (regionRow.size() * region.width) + region.width - 1 )
			
			#Assign space ranges to region
			region.space_width_range = Vector2i(region.region_width_range.x + subRegionOffset, region.region_width_range.y - subRegionOffset)
			region.space_height_range = Vector2i(region.region_height_range.x + subRegionOffset, region.region_height_range.y - subRegionOffset)
			
			#append region to empty region row
			regionRow.append(region)
			
			#add region to region list
			regions.append(region)
	
	if regionRow.size() > 0:
		#add remaining region row to region map
		regionMap.append(regionRow.duplicate())

func _attach_resource_signal(regArr: Array[Region]):
	for reg in regArr:
		if reg != null && reg.changed.is_connected(_on_value_updated):
			reg.changed.disconnect(_on_value_updated)
		reg.changed.connect(_on_value_updated)

func _on_value_updated():
	_build_region_map()
	editor_updated.emit(self)
