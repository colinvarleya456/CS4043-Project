extends StaticBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_3d: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var sliding_door: StaticBody3D = $"."


@export var lock = true
@export var key_path: NodePath
var key_node


@export var door_type = "Red"


var door := false 

#Connects Key script and closes door at beginning
func _ready():
	get_node("Label3D").hide()
	animation_player.play_backwards("Door slide")
	if key_path != NodePath():
		key_node = get_node(key_path)
		key_node.connect("GotKey", _on_key_got)
	else:
		push_warning("Door has no assigned key")
	

#When gained key the lock is released
func _on_key_got(received_key_type):
	if received_key_type == door_type:
		lock = false
		print("Door received key!")
	

	

#When you enter door area it opens or closes based on if its locked or not
func _on_area_3d_body_entered(player):
	if lock == true:
		print("Get the key")
		get_node("Label3D").show()
	else:
		animation_player.play("Door slide")
		print("body entered")

func _on_area_3d_body_exited(player):
	if lock == true:
		print("Get the key")
		get_node("Label3D").hide()
	else:
		animation_player.play_backwards("Door slide")
		print("body exited")
	
	
