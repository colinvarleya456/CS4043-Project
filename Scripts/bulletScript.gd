extends RigidBody3D

@export var fireRate : float
@export var bulletDamage : float
@export var muzzleVelocity : float
@export var trailColour : Color
@export var timeToDespawn : float = (fireRate * 10) + 5

enum ammoTypes {NORMAL, EXPLOSIVE, HOLLOWPOINT}
@export var ammoType : int

@onready var gpu_trail_3d : GPUTrail3D = $GPUTrail3D
@onready var gpu_particles_3d : GPUParticles3D = $GPUParticles3D
@onready var world : Node = get_tree().get_root().get_node("World")

@onready var shape_cast: ShapeCast3D = $shapeCast


func _ready() -> void:
	despawn()
	visible = true
	gpu_trail_3d.emitting = false
	gpu_trail_3d.color_ramp.gradient.set_color(0, trailColour)




@onready var decal : PackedScene = preload("res://Scenes/bulletDecal.tscn")

func _physics_process(delta: float) -> void:
	if shape_cast.is_colliding():
		print("1")
		if shape_cast.collision_result[0]["collider"] != null:
			print("2")
			if shape_cast.collision_result[0]["collider"] is TaskNPC:
				print("3")
				shape_cast.collision_result[0]["collider"].emit_signal("hit", bulletDamage)
				queue_free()
			
			else:
				var dec = decal.instantiate()
				shape_cast.get_collider(0).add_child(dec)
				dec.global_transform.origin = shape_cast.get_collision_point(0)
				dec.look_at(shape_cast.get_collision_point(0) + shape_cast.get_collision_normal(0), Vector3.UP)
				queue_free()
			
	else:
		position += global_transform.basis * Vector3(0,0,-muzzleVelocity)

func despawn():
	await get_tree().create_timer(.02).timeout
	gpu_trail_3d.emitting = true
	await get_tree().create_timer(timeToDespawn).timeout
	queue_free()
