extends CharacterBody3D

@onready var camera_3d: Camera3D = $CameraHolder/Camera3D


@export var camMaxAngle : float = 90
@export var camMinAngle : float = 0
@export var camSensHorizontal : float = .2
@export var camSensVertical : float = .2

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * camSensHorizontal)
		camera_3d.get_parent().rotate_x(deg_to_rad(-event.relative.y) * camSensVertical)
		camera_3d.get_parent().rotation.x = clamp(camera_3d.get_parent().rotation.x, deg_to_rad(camMinAngle), deg_to_rad(camMaxAngle))

	if Input.is_action_just_pressed("z"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("x"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
