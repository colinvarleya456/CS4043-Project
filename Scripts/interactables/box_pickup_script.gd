extends RigidBody3D

signal interact(player)

func _ready() -> void:
	connect("interact", interactFunc)


@export var playerNode : CharacterBody3D


func interactFunc(player):
	print("interact called : ", player)
	playerNode = player
	isHeld = !isHeld
	isThrown = false
	

@export var isHeld : bool = false
@export var isThrown : bool = false

#Keeps box at the center of the screen once box is interacted with
func _physics_process(delta: float) -> void:
	if isHeld:
		global_position = playerNode.held_object_position.global_position

#If box is being held, press T to throw
func _input(event: InputEvent) -> void:
	if isHeld:
		if Input.is_action_just_pressed("t"):
			isHeld = false
			isThrown = true
			apply_central_impulse(-playerNode.player_cam.global_transform.basis.z * playerNode.throwStrength)


@export_enum("Grenade", "Flashbang", "Water", "Oil", "Glass Shatter") var throwEffect = 0

@export var grenadeFuze : float = 1
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var world: Node = get_tree().get_root().get_node("World")

#Once box is thrown, waits a second then removes and explodes box
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
		
