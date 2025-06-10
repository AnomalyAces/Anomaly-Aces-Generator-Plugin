@tool
class_name BoardDemoCharacter extends AceCharacter3D

## GridMap
# @export var gridMap: GridMap
# @export_group("Editors")
## Space Editor used to track spaces
# @export var spaceEditor: SpaceEditor


@onready var raycast: RayCast3D = $RayCast3D
@onready var camera_3d: Camera3D = $Camera3D



func _ready() -> void:
	pass

func _process(delta: float) -> void:
	#Handle Directional Code
	if Input.is_action_just_pressed("ui_left"):
		raycast.rotation_degrees.y = 90
	if Input.is_action_just_pressed("ui_right"):
		raycast.rotation_degrees.y = -90
	if Input.is_action_just_pressed("ui_up"):
		raycast.rotation_degrees.y = 0
	if Input.is_action_just_pressed("ui_down"):
		raycast.rotation_degrees.y = 180


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# If the current target has not been set yet listen for a new target
	# if curr_path_target == Vector3.INF:
	# 	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
	# 	if !has_diagonal_movement:
	# 		# stop diagonal movement by listening for left/right input then setting y axis to zero
	# 		if Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left"):
	# 			input_dir.y = 0
	# 			var target: Vector3 = position + Vector3(input_dir.x,0,input_dir.y)
	# 			if BoardGeneratorGridUtil.isLocationDefinedSpace(target, gridMap, space_editor):
	# 				curr_path_target = target
	# 		# stop diagonal movement by listening for  up/down input then setting x axis to zero
	# 		elif Input.is_action_pressed("move_up") || Input.is_action_pressed("move_down"):
	# 			input_dir.x = 0
	# 			var target: Vector3 = position + Vector3(input_dir.x,0,input_dir.y)
	# 			if BoardGeneratorGridUtil.isLocationDefinedSpace(target, gridMap, space_editor):
	# 				curr_path_target = target
	# 		else:
	# 			input_dir = Vector2.ZERO
	
	super._physics_process(delta)
