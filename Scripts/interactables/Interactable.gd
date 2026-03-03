class_name Interactable_Class extends RigidBody3D


signal interact(player)

func _ready() -> void:
	connect("interact", interactFunc)


@export var playerNode : CharacterBody3D

func interactFunc(player):
	print("interact called : ", player)
	playerNode = player
	if !isPickup:
		isHeld = !isHeld
		isThrown = false
	else:
		match pickupType:
			0:
				player.emit_signal("pickup",0,gunScene)
			1:
				player.emit_signal("pickup",1,grenadeType)
			2:
				player.emit_signal("pickup",2,null)
		queue_free()

@export_category("Pickup")
@export var isPickup : bool = false
@export_enum("Gun", "Grenade", "Silencer") var pickupType : int = 0
@export var gunScene : PackedScene
@export_enum("Frag","Flashbang") var grenadeType : int = 0

@export_category("Throwable")
@export var isThrown : bool = false
@export var isHeld : bool = false


func _physics_process(delta: float) -> void:
	if isHeld:
		global_position = playerNode.held_object_position.global_position

func _input(event: InputEvent) -> void:
	if isHeld:
		if Input.is_action_just_pressed("t"):
			isHeld = false
			isThrown = true
			apply_central_impulse(-playerNode.player_cam.global_transform.basis.z * playerNode.throwStrength)


@export_enum("Frag", "Flashbang", "Water", "Oil", "Glass Shatter") var throwEffect = 0

@export var grenadeFuze : float = 1
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var world: Node = get_tree().get_root().get_node("World")

func _on_body_entered(body: Node) -> void:
	if isThrown:
		match throwEffect:
			0:
				await get_tree().create_timer(grenadeFuze).timeout
				print("grenade explosion")
				gpu_particles_3d.reparent(world)
				gpu_particles_3d.emitting = true
				queue_free()
			1:
				pass
			2:
				pass
			3:
				pass
			4:
				pass
		
