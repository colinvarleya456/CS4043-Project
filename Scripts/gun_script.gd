extends Node3D

@export var adsCam : Camera3D
@export var adsNode : Node3D

@export var canShoot : bool = true
@export var reloading : bool = false

enum weaponTypes {PISTOL, RIFLE, SMG, SNIPER, LMG}
@export var weaponType : int 
@export var weaponName : String
@export var modelID : int

@onready var ammo : int = magazineSize
@export var magazineSize : int
@export var reserveAmmo : int
@export var automatic : bool
@export var fireRate : float
@export var damage : float
@export var speed : float
@export var trailColour : Color
@export var timeToDespawn : float
@export var vRecoil : float
@export var hRecoil : float
@export var gunSound : int


@onready var end_of_barrel: Node3D = $Armature/Skeleton3D/a/end_of_barrel
@onready var end_of_barrel_look_at: Node3D = $Armature/Skeleton3D/a/end_of_barrel_look_at

@onready var world: Node = get_tree().get_root().get_node("World")
@onready var gun_audio: AudioStreamPlayer3D = $gun_audio

@export var gunSFX1 : AudioStreamWAV = preload("res://Snake's Authentic Gun Sounds/Full Sound/5.56/WAV/556 Single WAV.wav")
@export var gunSFX2 : AudioStreamWAV = preload("res://Snake's Authentic Gun Sounds/Full Sound/7.62x39/WAV/762x39 Single WAV.wav")
@export var gunSFX3 : AudioStreamWAV = preload("res://Snake's Authentic Gun Sounds/Full Sound/7.62x54R/WAV/762x54r Single WAV.wav")

@export var muzzle_point: Node3D
#@export var side_point: Node3D
@export var sight_point: Node3D
#@export var stock_point: Node3D
#@export var underbarrel_point: Node3D

signal addAttachment(PackedScene)

signal shoot
signal stop_shooting
signal ADS
signal unADS

func _ready():
	connect("shoot", Callable(self, "start_shoot"))
	connect("stop_shooting", Callable(self, "stop_shoot"))
	connect("ADS", Callable(self, "ads"))
	connect("unADS", Callable(self, "un_ads"))
	
	add_user_signal("addAttachment")
	connect("addAttachment", Callable(self, "try_add_attachment"))
	fire()
	assignFireSound()
	updateAmmoUI()

func _input(event):
	if event.is_action_pressed("r"):
		reload()

func start_shoot():
	print("start")
	if ammo == 0:
		reload()
		print("if")
	else:
		print("else")
		canShoot = true
		fire()

func stop_shoot():
	canShoot = false

func fire() -> void:
	print("fire")
	if ammo >= 1 and canShoot == true and reloading == false:
		var bullet = load("res://Scenes/bullet.tscn")
		var bulletInstance = bullet.instantiate()
		world.add_child.call_deferred(bulletInstance)
		bulletInstance.look_at_from_position(end_of_barrel.global_position,end_of_barrel_look_at.global_position)
		bulletInstance.position = end_of_barrel.global_position
		bulletInstance.speed = speed 
		bulletInstance.trailColour = trailColour
		bulletInstance.damage = damage
		bulletInstance.timeToDespawn = timeToDespawn
		gun_audio.play()
		ammo -= 1
		
		var muzzleflashins = load("res://Scenes/muzzle_flash.tscn")
		muzzleflashins = muzzleflashins.instantiate()
		muzzleflashins.emitting = true
		end_of_barrel.add_child(muzzleflashins)
		updateAmmoUI()
		recoil()
		
		if automatic == true:
			await get_tree().create_timer(fireRate).timeout
			fire()
	else:
		await get_tree().create_timer(.01).timeout
		fire()
	
func reload():
	reloading = true
	await get_tree().create_timer(1).timeout
	reserveAmmo += ammo
	if reserveAmmo >= magazineSize:
		reserveAmmo -= magazineSize
		ammo = magazineSize
	
	elif reserveAmmo < magazineSize:
		ammo = reserveAmmo
		reserveAmmo = 0
	updateAmmoUI()
	reloading = false

func updateAmmoUI():
	pass

func recoil():
	pass
	#get_parent().get_parent().get_parent().rotation_degrees.x += vRecoil
	#get_parent().get_parent().get_parent().get_parent().rotation_degrees.y += randi_range(-1,1) * hRecoil

@onready var aiming : bool = false
@onready var adsPlayer: AnimationPlayer = $ads

func ads():
	aiming = true
	adsPlayer.get_animation("ads").track_set_key_value(0,1,Vector3(-0.175, .05,0))
	adsPlayer.play("ads")

func un_ads():
	aiming = false
	adsPlayer.play_backwards("ads")

#enum attachmentTypes {SIGHT, UNDERBARREL, SIDE, MUZZLE, STOCK}

func aimSight():
	if aiming == true:
		if sight_point.get_child_count() > 0:
			sight_point.get_child(0).aimCam.make_current()

func try_add_attachment(model):
	match model.attachmentType:
		0:
			if sight_point.get_child_count() > 0:
				sight_point.get_child(0).queue_free()
			sight_point.add_child(model)
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass

func assignFireSound():
	match gunSound:
		0:
			gun_audio.stream = gunSFX1
		1:
			gun_audio.stream = gunSFX2
		2:
			gun_audio.stream = gunSFX3
