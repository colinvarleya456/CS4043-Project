extends Node3D

@onready var anim: AnimationPlayer = $anim

func _ready() -> void:
	anim.play("bullet hole fade")
