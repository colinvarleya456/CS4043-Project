extends RigidBody3D

var force = 350

func Box_hit(source):
	apply_central_force((global_transform.origin - source).normalized()* force)
