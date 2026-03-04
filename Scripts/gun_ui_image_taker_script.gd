@tool
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#takeImage()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



@onready var gun_holder: Node3D = $SubViewport/GunHolder
@onready var camera_3d: Camera3D = $SubViewport/Camera3D
@export_tool_button("Hello", "Callable") var hello_action = takeImage

@onready var sub_viewport: SubViewport = $SubViewport

func takeImage(inputModel):
	
	if gun_holder.get_child_count() > 0:
		gun_holder.get_child(0).queue_free()
	
	gun_holder.add_child(inputModel.instantiate())
	
	#await RenderingServer.frame_post_draw
	camera_3d.get_viewport().get_texture().get_image().save_png("res://Images/GunImages/new.png")
	#await get_tree().create_timer(1).timeout
	var img : CompressedTexture2D = load("res://Images/GunImages/new.png")
	var img2 : Image = img.get_image()
	var img3 = img2.get_region(Rect2i(Vector2(0,130),Vector2(300,60)))
	
	
	img3.save_png("res://Images/GunImages/new2.png")
	return load("res://Images/GunImages/new2.png")
