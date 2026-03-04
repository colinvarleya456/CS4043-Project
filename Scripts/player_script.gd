class_name player_class extends CharacterBody3D


@export var player_cam : Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_collision: CollisionShape3D = $playerCollision
@onready var interact_cast: RayCast3D = $Camera3D/interactCast
@onready var crouch_cast: ShapeCast3D = $crouchCast
@export var gun_holder: Node3D 
@export var heldObject : Node3D
@export var held_object_position : Node3D


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




@export var throwStrength : float = 25

@export var cam_speed : float = 5
@export var cam_rotation_amount : float = 1

@export var weapon_sway_amount : float = 5
@export var weapon_rotation_amount : float = 1
@export var invert_weapon_sway : bool = false

var mouse_input : Vector2


@export var aiming : bool = false


signal pickup(type, data, gunName)


func _ready() -> void:
	assignPlayerInfo()
	connect("pickup", pickupFunc)

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
		if gun_holder.get_child_count() > 0:
			gun_holder.get_child(0).canShoot = true

	elif !Input.is_action_pressed("lmb"):
		if gun_holder.get_child_count() > 0:
			gun_holder.get_child(0).canShoot = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: #camera movement
		rotate_y(deg_to_rad(-event.relative.x) * camSensHorizontal)
		player_cam.rotate_x(deg_to_rad(-event.relative.y) * camSensVertical)
		player_cam.rotation.x = clamp(player_cam.rotation.x, deg_to_rad(camMinAngle), deg_to_rad(camMaxAngle))
		mouse_input = event.relative

	if Input.is_action_just_pressed("z"): #show mouse
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("x"): #hide mouse
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_pressed("control"): #crouch
		if !isCrouch:
			animation_player.play("crouch")
			isCrouch = !isCrouch
		else:
			if crouch_cast.is_colliding() == false:
				animation_player.play_backwards("crouch")
				isCrouch = !isCrouch
	
	if Input.is_action_just_pressed("f"): #interact
		interactFunc()
	
	if event.is_action_pressed("rmb"): #aim in
		if gun_holder.get_child_count() > 0:
			print("try fire")
			gun_holder.get_child(0).emit_signal("ADS")
			aiming = true

	if event.is_action_released("rmb"): #aim out
		if gun_holder.get_child_count() > 0:
			gun_holder.get_child(0).emit_signal("unADS")
			aiming = false
	
	if event.is_action_pressed("1"):
		changeWeapon(0, null, null)
		selectedWeapon = 0
	if event.is_action_pressed("2"):
		changeWeapon(1, null, null)
		selectedWeapon = 1
	if event.is_action_pressed("3"):
		changeWeapon(2, null, null)
		selectedWeapon = 2
	
	if event.is_action_pressed("4"):
		if selectedGrenade == grenadeTypes:
			selectedGrenade = 0
		else:
			selectedGrenade += 1
	
	if event.is_action_pressed("g"):
		throwGrenade()

func assignPlayerInfo(): #Crouching is handled by an animation so this is here to edit the animation with picked values for height etc
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

func cam_tilt(input_x, delta): #Cam leaning left/right when moving left/right
	if player_cam:
		player_cam.rotation.z = lerp(player_cam.rotation.z, -input_x * cam_rotation_amount, 10 * delta)

func weapon_tilt(input_x, delta): #Weapon leaning left/right when moving left/right
	if gun_holder.get_child_count() > 0:
		if aiming == true:
			gun_holder.rotation.z = lerp(gun_holder.rotation.z, 0.0, .1)
		else:
			gun_holder.rotation.z = lerp(gun_holder.rotation.z, -input_x * weapon_rotation_amount * 10, 10 * delta)

func weapon_sway(delta): #Weapon moving when mouse moves
	if gun_holder.get_child_count() > 0:
		mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
		gun_holder.rotation.x = lerp(gun_holder.rotation.x, mouse_input.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)
		gun_holder.rotation.y = lerp(gun_holder.rotation.y, mouse_input.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)	

#var def_weapon_holder_pos : Vector3
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

#@export var gunScenes : Array[PackedScene]
@export var heldGuns : Array[PackedScene]
@export var heldGunsNames : Array[String]
@export var selectedWeapon : int = 0


@onready var stowed_weapons: Node3D = $Camera3D/stowedWeapons


func changeWeapon(picked_weapon : int, weapon_scene : PackedScene, gunName): #0 = 1st weapon
	
	if gun_holder.get_child_count() > 0:
		if gun_holder.get_child(0).heldPosition != picked_weapon:
			gun_holder.get_child(0).reparent(stowed_weapons)
	
	
	for child in stowed_weapons.get_children():
		if child.heldPosition == picked_weapon:
			child.reparent(gun_holder)
			child.rotation = Vector3.ZERO
			return
	
	
	if weapon_scene:

		var takenPositions : Array[int]

		for i in gun_holder.get_children():
			takenPositions.append(i.heldPosition)
		for i in stowed_weapons.get_children():
			takenPositions.append(i.heldPosition)
		
		var pos : int = 0
		
		for i in takenPositions:
			if pos == i:
				pos += 1
			else:
				break
		
		match pos:
			0:
				playerUI.gun1Name = gunName
				playerUI.gun1Texture.texture = gun_ui_image_taker.takeImage(load("res://Blender/Fn Fal.blend"))
			1:
				playerUI.gun2Name = gunName
				playerUI.gun2Texture.texture = gun_ui_image_taker.takeImage(load("res://Blender/Fn Fal.blend"))
			2:
				playerUI.gun3Name = gunName
				playerUI.gun3Texture.texture = gun_ui_image_taker.takeImage(load("res://Blender/Fn Fal.blend"))
		
		
		
		var t = weapon_scene.instantiate()
		t.heldPosition = pos

		if gun_holder.get_child_count() > 0:
			gun_holder.get_child(0).reparent(stowed_weapons)
		gun_holder.add_child(t)
		t.gunName = gunName
		t.rotation = Vector3.ZERO
	
	
	
	#gun_holder.add_child(heldGuns[picked_weapon].instantiate())
	#gun_holder.get_child(0).heldPosition = picked_weapon

@export_enum("Frag", "Flashbang") var grenadeTypes : int 
@export var grenadeCounts : Array[int] = [5,5]
@export var selectedGrenade : int = 0

@onready var interactable : PackedScene = load("res://Scenes/Interactable.tscn")

@onready var world: Node = get_tree().get_root().get_node("World")

func throwGrenade():
	if grenadeCounts[selectedGrenade] > 0:
		grenadeCounts[selectedGrenade] -= 1
		var grenade : Interactable_Class = interactable.instantiate()
		grenade.throwEffect = 0
		grenade.isThrown = true
		grenade.isHeld = false
		grenade.position = held_object_position.global_position
		world.add_child(grenade)
		grenade.apply_central_impulse(-player_cam.global_transform.basis.z * throwStrength)
		
		
	else:
		pass

@onready var playerUI : Control = $"../../UI/Player"
@onready var gun_ui_image_taker: Node3D = $"../GunUIImageTaker"

func pickupFunc(type : int, data, gunName : String):
	print("Type : ",type, " Data : ",data, " GUN NAME ",gunName)
	changeWeapon(0, data, gunName)
	
	
	
	
	

pass
