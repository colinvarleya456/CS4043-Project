class_name TaskNPC

extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D

@export var tasks: Array[Marker3D]
var current_task = 0
var manager: NPCManager
var current_path: Vector3

const SPEED = 5.0
const THINK_TICK = 1

signal hit(damage)
signal eventHeard(type : int)

func _ready() -> void:
	connect("hit", hitFunc)#
	connect("eventHeard", eventHeardFunc)
	agent.target_position = tasks[current_task].position
	agent.velocity_computed.connect(Callable(_on_velocity_computed))
	

func _physics_process(delta: float) -> void:
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished() or position.distance_to(agent.target_position) < agent.path_desired_distance:
		current_task += 1
		if (current_task >= tasks.size()):
			manager.npc_array.erase(self)
			queue_free()
			return
		agent.target_position = tasks[current_task].position
		return
	
	current_path = agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(current_path) * SPEED
	if agent.avoidance_enabled:
		agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func hitFunc(damage):
	print(damage)
	queue_free()


#testing
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
const RED_MATERIAL = preload("uid://dc4qss36a8qse")

func eventHeardFunc(type):
	mesh_instance_3d.set_surface_override_material(0, RED_MATERIAL)
	#queue_free()
