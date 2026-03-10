extends Node3D








@export var active : bool = true
@export var canShoot : bool = true
@export var idle : bool = false
@export_category("Turret Stats")
@export_range(1, 100, 1) var health : int = 20
@export_range(.05, 10, 0.05) var fireRate : float = .05
@export_range(1, 100, 1) var bulletDamage : float = 1
@export_range(.3, 4, 0.05) var muzzleVelocity : float = .3
@export_range(1, 250, 1) var clipSize : int = 1
@export_range(0, 10, .01) var reloadSpeed : float = 1
@export_range(1, 20, 1) var timeToDespawn : float = 1
@export_range(1, 300, 1) var casingTimeToDespawn : float = 1
@export_range(1, 100, 1) var minDist : float = 10
@export_range(1, 100, 1) var maxDist : float = 100
@export var elevationSpeed : float = 2
@export var rotationSpeed : float = 2
@export var isSalvo : bool = false
@export var doesEject : bool = false
@onready var clipPosition : int = 0
#@export var colourTracer : Color = Color.GOLD

@export_category("Target")
@export var targetNode : Node3D
@export var isPlayerVisible : bool = false
@export var isPlayerInRange : bool = false
@onready var currentTarget : Vector3
@onready var isFiring : bool = false
@onready var onTarget : bool = false

@export var salvoPosition : int = 0
@export var salvoWait : float = 2
@onready var salvoPaused : bool = false
@export var salvoLength : int = 3

@onready var reloading : bool = false

@export_category("Choices")
@export var endBarrelList : Array[Node3D]
@export var turret: MeshInstance3D
@export var barrel: MeshInstance3D
@export var endOfBarrel: Node3D
@export var endOfBarrelLookAt: Node3D

@export var casingEject: Node3D
@export var casingEject2: Node3D
@export var casingEject3: Node3D
@export var casingEject4: Node3D
@export var casingEject5: Node3D
@export var casingEject6: Node3D
@onready var casingEjectList : Array = [casingEject, casingEject2, casingEject3, casingEject4, casingEject5, casingEject6]


@export var animation_player: AnimationPlayer
@export var soundPlayer: AudioStreamPlayer3D

@onready var world: Node = get_tree().get_root().get_node("World")
var bullet = preload("res://Scenes/bullet.tscn")
var casing = preload("res://Scenes/standard_bullet_casing.tscn")

func _ready() -> void:
	shoot()
	scanForPlayer()
	checkPlayerDistance()

func _physics_process(delta: float) -> void:
	if !idle:
		currentTarget = targetNode.global_position + Vector3(0,1,0) # because the player node is at floor hight this + Vec3 corrects
	_rotate(delta)
	_elevate(delta)
	idleFunc()

# --- shooting ---

func shoot():
	if targetNode != null and active == true and isPlayerVisible == true and reloading == false and canShoot == true and isPlayerInRange == true:
		idle = false
		if casingEject != null and doesEject == true: #spawn casings
			for i in len(endBarrelList): #muzzle flash end
				var casingEjectins = load("res://Scenes/standard_bullet_casing.tscn")
				casingEjectins = casingEjectins.instantiate()
				casingEjectins.timeToDespawn = casingTimeToDespawn
				world.add_child(casingEjectins)
				casingEjectins.global_rotation = casingEjectList[i].global_rotation
				casingEjectins.global_position = casingEjectList[i].global_position
		
		for i in len(endBarrelList): #spawn bullets
			var bulletInstance = bullet.instantiate()
			world.add_child.call_deferred(bulletInstance)
			bulletInstance.look_at_from_position(endOfBarrel.global_position, endOfBarrelLookAt.global_position)
			bulletInstance.position = endBarrelList[i].global_position
			bulletInstance.muzzleVelocity = muzzleVelocity
			bulletInstance.bulletDamage = bulletDamage
			bulletInstance.timeToDespawn = timeToDespawn
		
			if soundPlayer != null: #play sound
				soundPlayer.play()
			
			if animation_player != null:
				animation_player.play("Fire")
		
		for i in len(endBarrelList): #muzzle flash end
			var muzzleflashins = load("res://Scenes/muzzle_flash.tscn")
			muzzleflashins = muzzleflashins.instantiate()
			muzzleflashins.emitting = true
			endBarrelList[i].add_child(muzzleflashins)
		
		if isSalvo:
			salvoPosition += 1
			if salvoPosition % salvoLength == 0: # salvo done
				salvoPaused = true
				#salvoPerTargetUpdate(targetNode)
				await get_tree().create_timer(salvoWait).timeout
				salvoPaused = false
				salvoPosition = 0
			
		if clipPosition == clipSize - 1: # empty ammo
			reloading = true
			await get_tree().create_timer(reloadSpeed).timeout
			reloading = false
			salvoPosition = 0
			clipPosition = 0
			shoot()
		
		elif clipPosition < clipSize: # continue ammo
		
			clipPosition += 1
			await get_tree().create_timer(fireRate).timeout
			shoot()
	else:
		idle = true
		await get_tree().create_timer(.01).timeout # re attempt to fire
		shoot()

# --- turret movement ---

func _rotate(delta) -> void:
	var yTarget = getLocalY()
	var finalY = sign(yTarget) * min(rotationSpeed * delta, abs(yTarget))
	turret.rotate_y(finalY)

func _elevate(delta: float) -> void:
	# get displacment
	var xTarget = _get_global_x()
	var xDiff = xTarget - barrel.global_transform.basis.get_euler().x
	var finalX = sign(xDiff) * min(elevationSpeed * delta, abs(xDiff))
	# elevate head
	barrel.rotate_x(finalX)

func getLocalY() -> float:
	var localTarget = turret.to_local(currentTarget)
	var yAngle = Vector3.FORWARD.angle_to(localTarget * Vector3(1, 0, 1))
	return yAngle * -sign(localTarget.x)

func _get_global_x() -> float:
	var localTarget = currentTarget - barrel.global_transform.origin
	return (localTarget * Vector3(1, 0, 1)).angle_to(localTarget) * sign(localTarget.y)

# --- behaviour ---

@export var scanSpeed : float = .1

@onready var vis_cast: RayCast3D = $visCast

func scanForPlayer():
	vis_cast.look_at(targetNode.global_position + Vector3(0,1,0))
	vis_cast.force_raycast_update()
	if vis_cast.is_colliding():
		if vis_cast.get_collider() is player_class:
			isPlayerVisible = true
		else:
			isPlayerVisible = false
	
	await get_tree().create_timer(scanSpeed).timeout
	scanForPlayer()

func checkPlayerDistance():
	var dist = global_position.distance_to(targetNode.global_position)
	if dist > minDist and dist < maxDist:
		isPlayerInRange = true
	else:
		isPlayerInRange = false
	
	await get_tree().create_timer(scanSpeed).timeout
	checkPlayerDistance()

var target := Vector3(1,0,0)

func idleFunc():
	if turret.rotation_degrees.y > 85:
		target = Vector3(-1,0,0)
	
	elif turret.rotation_degrees.y < -85:
		target = Vector3(1,0,0)

	
	if idle:
		currentTarget = global_position + target
