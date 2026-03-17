extends Control

@export var activateOnStart : Array[Node3D]
@onready var ui: Control = $"../UI"
@onready var timer: Control = $"../Timer"

func _ready() -> void:
	visible = false

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	visible = false
	ui.visible = true
	timer.emit_signal("start")
	for i in activateOnStart:
		i.active = true
