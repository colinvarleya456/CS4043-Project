extends Node


@export var camList : Array[Camera3D]
@export var pos : int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("c"):
		if pos == len(camList) - 1:
			pos = 0
		else:
			pos += 1
		
		camList[pos].make_current()
