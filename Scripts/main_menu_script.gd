extends Control

@onready var settings: Control = $"../Settings"
@onready var intermediate_menu: Control = $"../IntermediateMenu"

func _ready() -> void:
	visible = true

func _on_start_game_pressed() -> void:
	visible = false
	intermediate_menu.visible = true

func _on_settings_pressed() -> void:
	settings.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()
