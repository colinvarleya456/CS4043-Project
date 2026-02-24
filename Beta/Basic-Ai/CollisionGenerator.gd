extends NavigationRegion3D

#
# WARNING
#
#	THIS SCRIPT SHOULD NOT BE USED IN THE FINAL PRODUCT.
#	IT IS ONLY TO BE USED IN SKETCHING AND WHITEBOXING
#

func _ready() -> void:
	generate_collisions(self)

func generate_collisions(node: Node) -> void:
	if (node is MeshInstance3D):
		node.create_trimesh_collision()
	for child in node.get_children():
		generate_collisions(child)
