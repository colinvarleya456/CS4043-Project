class_name NPCManager

extends Node

@onready var npc_scene: PackedScene = preload("res://Beta/Basic-Ai/task_npc.tscn")

@export var marker_entrance: Marker3D
@export var stores: Array[Marker3D]

const npc_amount: int = 64
var npc_array: Array[TaskNPC] = []

const SPAWN_TIMER_TICK = 2
var spawn_timer = 0

func _process(delta: float) -> void:
	spawn_timer += delta
	if (spawn_timer > SPAWN_TIMER_TICK):
		spawn_timer = 0
		if (npc_array.size() <= npc_amount):
			var new_npc: TaskNPC = npc_scene.instantiate()
			new_npc.position = marker_entrance.position
			new_npc.tasks = [stores.pick_random(), marker_entrance]
			new_npc.manager = self
			add_child(new_npc)
			npc_array.append(new_npc)
