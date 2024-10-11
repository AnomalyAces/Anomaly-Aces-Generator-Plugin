class_name GeneratorDoor extends StaticBody3D

enum DOOR_TYPE {
	SWING,
	RISE
}


signal door_opened
signal door_closed

var animation_player: AnimationPlayer
var door_name: String
var door_type: DOOR_TYPE

var toogle: bool = false
var interactable: bool = true

func initialize_door(anim: AnimationPlayer, d_name: String, d_type: DOOR_TYPE):
	animation_player = anim
	door_name = d_name
	door_type = d_type

func interact():
	if interactable == true:
		interactable = false
		animation_player.play(door_name+"_open")
		await animation_player.animation_finished
		door_opened.emit()
		get_tree().create_timer(1.0).connect("timeout", _on_timeout)
		interactable = true


func _on_timeout():
	interactable = false
	animation_player.play(door_name+"_close")
	await animation_player.animation_finished
	door_closed.emit()
	interactable = true
