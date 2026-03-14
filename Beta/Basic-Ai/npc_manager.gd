class_name NPCManager

extends Node

@onready var npc_scene: PackedScene = preload("res://Beta/Basic-Ai/task_npc.tscn")

@export var entrances: Array[Marker3D]
@export var exits: Array[Marker3D]
@export var stores: Array[Marker3D]

const npc_amount: int = 100
var npc_array: Array[TaskNPC] = []

const SPAWN_TIMER_TICK = 0.5
var spawn_timer = 0

func _process(delta: float) -> void:
	spawn_timer += delta
	if (spawn_timer > SPAWN_TIMER_TICK):
		spawn_timer = 0
		if (npc_array.size() <= npc_amount):
			var new_npc: TaskNPC = npc_scene.instantiate()
			var entrance: Marker3D = entrances.pick_random()
			var exit: Marker3D = exits.pick_random()
			new_npc.position = entrance.position
			new_npc.tasks = [stores.pick_random(), exit]
			new_npc.manager = self
			add_child(new_npc)
			npc_array.append(new_npc)
