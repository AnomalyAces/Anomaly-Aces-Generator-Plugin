@tool
class_name Building extends Resource
## Building Tile Index from Mesh Library
@export var buildingName: String = ""
## Building Tile Index from Mesh Library
@export var buildingIndex: int = -1
## Space Index from Mesh Library of the associated space that the building represents
@export var spaceIndex: int = -1
@export_group("Transparency")
## Transparency Building Tile Index from Mesh Library
@export var buildingTransparentIndex: int = -1
@export_subgroup("Ranges")
## If a player is east of this building within the listed range, the building will be transparent
@export var eastTransparencyRange: int = 0
## If a player is east of this building within the listed range, the building will be transparent
@export var westTransparencyRange: int = 0
## If a player is east of this building within the listed range, the building will be transparent
@export var northTransparencyRange: int = 0
## If a player is east of this building within the listed range, the building will be transparent
@export var southTransparencyRange: int = 0
