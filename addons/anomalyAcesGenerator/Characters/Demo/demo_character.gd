class_name DemoCharacter extends AceCharacter3D

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

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	super._physics_process(delta)

	
	
	#camera_3d.position = lerp(camera_3d.position,position,0.15)
	
