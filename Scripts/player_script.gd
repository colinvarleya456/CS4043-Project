extends CharacterBody3D


@onready var camera_3d: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_category("Camera")
@export var camMaxAngle : float = 90
@export var camMinAngle : float = 0
@export var camSensHorizontal : float = .2
@export var camSensVertical : float = .2

@export_category("Player")
@export var standingHeight : float = 2
@export var crouchHeight : float = 1
@export var proneHeight : float = .5
@export var crouchSpeed : float = .1
@export var proneSpeed : float = 1

@export var movementSpeed = 5.0
@export var jumpVelocity = 4.5

func _ready() -> void:
	assignPlayerInfo()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumpVelocity

	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * movementSpeed
		velocity.z = direction.z * movementSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, movementSpeed)
		velocity.z = move_toward(velocity.z, 0, movementSpeed)

	move_and_slide()

func _process(delta: float) -> void:
	pass

@export var isCrouch : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * camSensHorizontal)
		camera_3d.rotate_x(deg_to_rad(-event.relative.y) * camSensVertical)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(camMinAngle), deg_to_rad(camMaxAngle))

	if Input.is_action_just_pressed("z"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("x"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_pressed("control"):
		if !isCrouch:
			animation_player.play("crouch")
			isCrouch = !isCrouch
		else:
			if crouch_cast.is_colliding() == false:
				animation_player.play_backwards("crouch")
				isCrouch = !isCrouch
	
	#elif Input.is_action_just_released("control"):
	#	




@onready var player_collision: CollisionShape3D = $playerCollision

@onready var crouch_cast: ShapeCast3D = $crouchCast

func assignPlayerInfo():
	player_collision.shape.height = standingHeight
	camera_3d.position = Vector3(0,standingHeight * .875,0)
	
	animation_player.get_animation("crouch").track_set_key_value(0,0, standingHeight)
	animation_player.get_animation("crouch").track_set_key_value(0,1, crouchHeight)
	animation_player.get_animation("crouch").track_set_key_value(1,0, Vector3(0,standingHeight * .875,0))
	animation_player.get_animation("crouch").track_set_key_value(1,1, standingHeight)
	
	animation_player.speed_scale = 1 / crouchSpeed
	
