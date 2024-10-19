class_name DemoCharacter extends Character

@onready var raycast: RayCast3D = $RayCast3D

func _ready() -> void:
	SPEED = 6.0
	JUMP_VELOCITY = 9

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
