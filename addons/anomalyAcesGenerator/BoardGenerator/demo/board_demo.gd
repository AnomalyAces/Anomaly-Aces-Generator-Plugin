extends Node3D

@onready var aceBoardGenerator: AceBoardGenerator = $AceBoardGenerator
@onready var player: BoardDemoCharacter = $BoardDemoCharacter


func _ready() -> void:
	aceBoardGenerator.board_generated.connect(_on_board_generated)
	aceBoardGenerator.viewport_changed.connect(_on_viewport_changed)
	aceBoardGenerator.camera_mode_changed.connect(_on_camera_mode_changed)
	pass



func _on_board_generated() -> void:
	print("Board Generated")

func _on_viewport_changed(spaces_in_view: Array[BoardGeneratorGridUtil.GridPOI]) -> void:
	print("Spaces in View: %s" % JSON.stringify(spaces_in_view, "\t"))

func _on_camera_mode_changed(cameraMode: AceCameraManager.CAMERA_MODE) -> void:
	print("--- CAMERA MODE CHANGE ---")
	print("Camera Mode: %s" % AceCameraManager.CAMERA_MODE.keys()[cameraMode])

	## Enable / Disable the inputs for the camera dolly, select character, and the player depending on camera mode and turn player

	##TODO: Check for players turn
	##TODO: Add Check for Select Character
	if cameraMode == AceCameraManager.CAMERA_MODE.PLAYER:
		_set_character_input(player, true)
		_set_camera_dolly_input(false)
	elif cameraMode == AceCameraManager.CAMERA_MODE.MAP:
		_set_character_input(player, false)
		_set_camera_dolly_input(true)

func _set_character_input(character: AceCharacter3D, enabled: bool) -> void:
	character.enableInput = enabled

func _set_camera_dolly_input(enabled: bool) -> void:
	aceBoardGenerator.set_camera_dolly_input(enabled)