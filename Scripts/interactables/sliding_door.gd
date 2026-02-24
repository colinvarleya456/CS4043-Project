extends StaticBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


signal interact(player)
var door := false

func _ready() -> void:
	connect("interact", interactFunc)
	
	
func interactFunc(player):
	print("interact called : ", player)
	if door == false:
		animation_player.play("Door slide")
		door = true
	elif door == true:
		animation_player.play_backwards("Door slide")
		door = false
