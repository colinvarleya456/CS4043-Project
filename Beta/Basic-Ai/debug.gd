extends Control

@onready var console: RichTextLabel = $console

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("debug_exit"):
		get_tree().quit()

func log(message: String) -> void:
	console.add_text(message)
