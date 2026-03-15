extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_pressed() -> void:
	visible = false


func _on_resolution_box_item_selected(index: int) -> void:
	match index:
		0:
			#get_window().content_scale_size = Vector2(1280, 720)
			DisplayServer.window_set_size(Vector2i(1280, 720))
		1:
			#get_window().content_scale_size = Vector2(1920, 1080)
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2:
			#get_window().content_scale_size = Vector2(2560,1440)
			DisplayServer.window_set_size(Vector2i(2560,1440))
		3:
			#get_window().content_scale_size = Vector2(3840,2160)
			DisplayServer.window_set_size(Vector2i(3840,2160))




func _on_button_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		false:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
