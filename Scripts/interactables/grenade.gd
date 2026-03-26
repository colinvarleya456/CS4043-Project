extends RigidBody3D
var damage = 50


func _on_body_entered(body):
	linear_damp = 0.3
	angular_damp = 1.5



func _on_fuzetimer_timeout():
	var bodies = $Radius.get_overlapping_bodies()
	for obj in bodies:
		print("Hit:", obj.name)
		var source = self.global_transform.origin
		if obj.is_in_group("Enemy"):
			obj.Enemy_hit(damage)
			var rayParems = PhysicsRayQueryParameters3D.create(global_transform.origin, obj.global_transform.origin)
			var result = get_world_3d().direct_space_state.inteserct_ray(rayParems)
			if result.collider.is_in_group("Enemy"):
				obj.Enemy_hit(damage)
		if obj.is_in_group("Explodable"):
			
			obj.Box_hit(source)
		if obj.is_in_group("Destructible"):
			obj.Wall_hit(source)

			
	queue_free()
