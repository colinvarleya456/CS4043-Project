extends RigidBody3D

@export var timeToDespawn : float
#@export var scaleBullet : Vector3

func _ready() -> void:
	#set_collision_layer_value(1, false)
	despawn()
	

func despawn():
	await get_tree().create_timer(timeToDespawn).timeout
	queue_free()
