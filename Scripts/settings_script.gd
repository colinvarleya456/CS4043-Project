extends Control

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = true


func _on_close_pressed() -> void:
	visible = false

func _on_resolution_box_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		1:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2:
			DisplayServer.window_set_size(Vector2i(2560,1440))
		3:
			DisplayServer.window_set_size(Vector2i(3840,2160))

func _on_button_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		false:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_exit_2_pressed() -> void:
	get_tree().quit()
