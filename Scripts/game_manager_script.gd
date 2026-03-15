extends Node

@export var targetToKill : Node3D
@export var exits : Array[Node3D]
@export var winCondition : bool = false

signal exited

func _ready() -> void:
	connect("exited",exitedFunc)
	for child in get_children():
		exits.append(child)

func _process(delta: float) -> void:
	if targetToKill == null:
		winCondition = true
		for i in exits:
			i.active = true
		
@onready var main_menu: Control = $"../MainMenu"

func exitedFunc():
	main_menu.visible = true
	for i in main_menu.activateOnStart:
		i.active = false
