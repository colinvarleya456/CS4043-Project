extends StaticBody3D
@export var key_type = "Red"
signal interact(player)
signal GotKey(key_type)

func _ready() -> void:
	connect("interact", interactFunc)
	
	
func interactFunc(player):
	print("interact called : ", player)
	emit_signal("GotKey", key_type)
	queue_free()
	
