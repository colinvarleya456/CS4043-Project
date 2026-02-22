extends CharacterBody3D


@export var player_cam : Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_collision: CollisionShape3D = $playerCollision
@onready var interact_cast: RayCast3D = $Camera3D/interactCast
@onready var crouch_cast: ShapeCast3D = $crouchCast

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
@export var isCrouch : bool = false

func _ready() -> void:
	assignPlayerInfo()

func _physics_process(delta: float) -> void:
	

	
	
	
	
	
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
	
	cam_tilt(input_dir.x, delta)
	weapon_tilt(input_dir.x, delta)
	weapon_sway(delta)
	#weapon_bob(velocity.length(),delta)
	move_and_slide()

func _process(delta: float) -> void:
	if Input.is_action_pressed("lmb"):
		gun_holder.get_child(0).canShoot = true
		aiming = true
			
	elif !Input.is_action_pressed("lmb"):
		gun_holder.get_child(0).canShoot = false
		aiming = false
	
	
	#gun_holder.rotation.x = player_cam.rotation.x

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * camSensHorizontal)
		player_cam.rotate_x(deg_to_rad(-event.relative.y) * camSensVertical)
		player_cam.rotation.x = clamp(player_cam.rotation.x, deg_to_rad(camMinAngle), deg_to_rad(camMaxAngle))
		mouse_input = event.relative

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
	
	if Input.is_action_just_pressed("f"):
		interactFunc()
	
	#if event.is_action_pressed("lmb"):
	#	if gun_holder.get_child_count() > 0:
	#		print("try fire")
	#		gun_holder.get_child(0).emit_signal("shoot")
#
	#if event.is_action_released("lmb"):
	#	if gun_holder.get_child_count() > 0:
	#		gun_holder.get_child(0).emit_signal("stop_shooting")
	#	
	#if event.is_action_pressed("rmb"):
	#	if gun_holder.get_child_count() > 0:
	#		print("try fire")
	#		gun_holder.get_child(0).emit_signal("ADS")
#
	#if event.is_action_released("rmb"):
	#	if gun_holder.get_child_count() > 0:
	#		gun_holder.get_child(0).emit_signal("unADS")
	#	if event.is_action_pressed("rclick"):
	#		if weapon_holder.get_child_count() > 0:
	#			weapon_holder.get_child(0).emit_signal("ADS")
	#			reticle.visible = false
	#			aiming = true
	#		
	#	if event.is_action_released("rclick"):
	#		if weapon_holder.get_child_count() > 0:
	#			weapon_holder.get_child(0).emit_signal("unADS")
	#			cam.make_current()
	#			reticle.visible = true
	#			aiming = false
			
@export var gun_holder: Node3D 

func assignPlayerInfo():
	player_collision.shape.height = standingHeight
	player_cam.position = Vector3(0,standingHeight * .875,0)
	
	animation_player.get_animation("crouch").track_set_key_value(0,0, standingHeight)
	animation_player.get_animation("crouch").track_set_key_value(0,1, crouchHeight)
	animation_player.get_animation("crouch").track_set_key_value(1,0, Vector3(0,standingHeight * .875,0))
	animation_player.get_animation("crouch").track_set_key_value(1,1, standingHeight)
	
	animation_player.speed_scale = 1 / crouchSpeed

func interactFunc():
	interact_cast.force_raycast_update()
	if interact_cast.is_colliding():
		interact_cast.get_collider().emit_signal("interact", self)

@export var heldObject : Node3D

@export var held_object_position : Node3D
@export var throwStrength : float = 25

@export var cam_speed : float = 5
@export var cam_rotation_amount : float = 1


@export var weapon_sway_amount : float = 5
@export var weapon_rotation_amount : float = 1
@export var invert_weapon_sway : bool = false
var def_weapon_holder_pos : Vector3
var mouse_input : Vector2

@export var aiming : bool = false

func cam_tilt(input_x, delta):
	if player_cam:
		if aiming == false:
			player_cam.rotation.z = lerp(player_cam.rotation.z, -input_x * cam_rotation_amount, 10 * delta)
		else:
			player_cam.rotation.x = gun_holder.get_child(0).rotation.x

func weapon_tilt(input_x, delta):
	if gun_holder.get_child_count() > 0:
		gun_holder.rotation.z = lerp(gun_holder.rotation.z, -input_x * weapon_rotation_amount * 10, 10 * delta)

func weapon_sway(delta):
	if gun_holder.get_child_count() > 0:
		mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
		gun_holder.rotation.x = lerp(gun_holder.rotation.x, mouse_input.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)
		gun_holder.rotation.y = lerp(gun_holder.rotation.y, mouse_input.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)	

#func weapon_bob(vel : float, delta):
#	if gun_holder.get_child_count() > 0:
#		if vel > 0 and is_on_floor():
#			var bob_amount : float = 0.01
#			var bob_freq : float = 0.01
#			gun_holder.position.y = lerp(gun_holder.position.y, def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
#			gun_holder.position.x = lerp(gun_holder.position.x, def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, 10 * delta)
#			
#		else:
#			gun_holder.position.y = lerp(gun_holder.position.y, def_weapon_holder_pos.y, 10 * delta)
#			gun_holder.position.x = lerp(gun_holder.position.x, def_weapon_holder_pos.x, 10 * delta)












pass
