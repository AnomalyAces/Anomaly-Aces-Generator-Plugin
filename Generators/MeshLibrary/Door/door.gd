class_name GeneratorDoor extends StaticBody3D

signal door_opened


@export var animation_player: AnimationPlayer
@export var door_name: String

var toogle: bool = false
var interactable: bool = true


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
	interactable = true
