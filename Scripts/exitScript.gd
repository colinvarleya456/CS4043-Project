extends Node3D


@export var active := false

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if active:
		visible = true

@onready var world: Node = get_tree().get_root().get_node("World")




func _on_area_3d_body_entered(body: Node3D) -> void:
	if active:
		get_parent().emit_signal("exited")
		print("ex")
