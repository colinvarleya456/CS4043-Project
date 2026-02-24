extends Control

@onready var console: RichTextLabel = $console

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_exit"):
		get_tree().quit()

func log(message: String) -> void:
	console.add_text(message)
