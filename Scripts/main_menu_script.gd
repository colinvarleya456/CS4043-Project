extends Control

@onready var settings: Control = $"../Settings"
@export var activateOnStart : Array

func _ready() -> void:
	visible = true
	settings.visible = false

func _on_start_game_pressed() -> void:
	visible = false
	for i in activateOnStart:
		i.active = true


func _on_settings_pressed() -> void:
	settings.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()
