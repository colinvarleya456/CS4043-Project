extends StaticBody3D

signal interact

func _ready() -> void:
	connect("interact", interactFunc)

func interactFunc():
	print("interact called")
