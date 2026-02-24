class_name TaskNPC

extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D

@export var tasks: Array[Marker3D]
var current_task = 0
var manager: NPCManager

const SPEED = 5.0
const THINK_TICK = 1

func _ready() -> void:
	set_movement_target(tasks[current_task].position)
	agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	agent.target_position = movement_target

func _physics_process(delta: float) -> void:
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished():
		current_task += 1
		if (current_task >= tasks.size()):
			manager.npc_array.erase(self)
			queue_free()
			return
		set_movement_target(tasks[current_task].position)
	
	var next_path_position: Vector3 = agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * SPEED
	if agent.avoidance_enabled:
		agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
