class_name TaskNPC

extends CharacterBody3D
@export var health : int = 10

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var debug: Label3D = $DebugInfo

@export var tasks: Array[Marker3D]
var current_task = 0
var manager: NPCManager
var current_path: Vector3

const MASK_MAP = 1 << 0
const MASK_PLAYER = 1 << 2

enum UNIT_TYPE { UNIT_CIVILIAN, UNIT_GUARD, UNIT_HITMAN, UNIT_TARGET }
@export var unit_type: UNIT_TYPE 
@export var repeat_task: bool

enum STATE { STATE_IDLE, STATE_TASK, STATE_FLEEING, STATE_PURSUIT }
var current_state: STATE = STATE.STATE_IDLE
var is_hostile: bool = false
var last_player_pos: Vector3

const SPEED = 5.0

signal hit(damage)
signal eventHeard(type: event_bus.EVENT_TYPE, pos: Vector3)

@onready var animation_player: AnimationPlayer = $CIV1/AnimationPlayer
@onready var body: Node3D = $CIV1
@onready var player: CharacterBody3D = $"3D/Player"

func _ready() -> void:
	connect("hit", hitFunc)
	connect("eventHeard", eventHeardFunc)
	agent.target_position = tasks[current_task].position
	agent.velocity_computed.connect(Callable(_on_velocity_computed))
	setupAnim()

func _process(delta: float) -> void:
	debug.text = "Type: {unit_type}, State: {current_state}, Hostile: {is_hostile}".format({
		"unit_type": unit_type,
		"current_state": current_state,
		"is_hostile": is_hostile
	})
	
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	
	if agent.is_navigation_finished() or position.distance_to(agent.target_position) < agent.path_desired_distance:
		if (think()):
			manager.npc_array.erase(self)
			queue_free()
			return
		return
	
	current_path = agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(current_path) * SPEED
	if current_state == STATE.STATE_FLEEING:
		new_velocity = new_velocity * 2
	
	if agent.avoidance_enabled:
		agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func think() -> bool: #Returns true if you are done
	match current_state:
		STATE.STATE_IDLE:
			agent.target_position = position
		STATE.STATE_TASK:
			current_task += 1
			if (current_task >= tasks.size()):
				return true
			agent.target_position = tasks[current_task].position
		STATE.STATE_FLEEING:
			if (current_task >= tasks.size()):
				return true
			agent.target_position = tasks[tasks.size() - 1].position
		STATE.STATE_PURSUIT:
			agent.target_position = last_player_pos
	return false

func hitFunc(damage):
	health -= damage
	if health <= 0:
		queue_free()

const fov_degrees: float = 60.0
const max_sight: float = 20.0
func canSeePlayer() -> bool:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var forward: Vector3 = -global_transform.basis.z
	var to_player_vec: Vector3 = (player.global_position - global_position)
	var to_player_dir: Vector3 = to_player_vec.normalized()
	var cos_half_fov: float = cos(deg_to_rad(fov_degrees / 2.0))
	
	if forward.dot(to_player_dir) < cos_half_fov:
		return false
	
	if to_player_vec.length() > max_sight:
		return false
	
	var origin: Vector3 = global_position
	var end: Vector3 = player.global_position
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.collision_mask = MASK_MAP | MASK_PLAYER
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	return result and result.collider == player;

func eventHeardFunc(type: event_bus.EVENT_TYPE, pos: Vector3):
	match type:
		event_bus.EVENT_TYPE.SHOT_FIRED:
			dangerSignal(pos)
		event_bus.EVENT_TYPE.GRENADE_EXPLOSION:
			dangerSignal(pos)
	pass

func dangerSignal(pos: Vector3):
	match unit_type:
		UNIT_TYPE.UNIT_CIVILIAN:
			current_state = STATE.STATE_FLEEING
			think()
		UNIT_TYPE.UNIT_GUARD:
			if canSeePlayer():
				is_hostile = true
		UNIT_TYPE.UNIT_HITMAN:
			last_player_pos = pos
			if canSeePlayer():
				is_hostile = true
		UNIT_TYPE.UNIT_TARGET:
			current_state = STATE.STATE_FLEEING
			think()

func setupAnim():
	animation_player.play("Armature|mixamo_com|Layer0")
