extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const THINK_TICK = 1

var timer = 0

func get_next_pos() -> void:
	agent.target_position = $"../Player".position

func _physics_process(delta: float) -> void:
	timer += delta
	if timer > THINK_TICK:
		timer = 0
		get_next_pos()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var next_position = agent.get_next_path_position()
	
	if (position - next_position).y < 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction = position.direction_to(next_position)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
