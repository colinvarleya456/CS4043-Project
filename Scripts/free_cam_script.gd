extends Node3D




@export var camSensHorizontal : float = 0.2
@export var camSensVertical : float = 0.2
@export var camMinAngle : int = -90.0
@export var camMaxAngle : int = 90.0
@export var movementSpeed : float = 6
@export var mouse_input : Vector2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: #camera movement
		rotate_y(deg_to_rad(-event.relative.x) * camSensHorizontal)
		get_child(0).rotate_x(deg_to_rad(-event.relative.y) * camSensVertical)
		get_child(0).rotation.x = clamp(get_child(0).rotation.x, deg_to_rad(camMinAngle), deg_to_rad(camMaxAngle))
		mouse_input = event.relative
	
	
	

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var velocity : Vector3 = Vector3.ZERO
	
	if direction:
		velocity.x = direction.x * movementSpeed
		velocity.z = direction.z * movementSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, movementSpeed)
		velocity.z = move_toward(velocity.z, 0, movementSpeed)
	
	position += velocity
	
	if Input.is_action_pressed("shift"):
		position.y += movementSpeed
	if Input.is_action_pressed("control"):
		position.y -= movementSpeed
	
	
	
	
	
	
	
