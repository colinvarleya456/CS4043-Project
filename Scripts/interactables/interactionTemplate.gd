extends StaticBody3D

signal interact(player)

func _ready() -> void:
	connect("interact", interactFunc)

func interactFunc(player):
	print("interact called : ", player)
