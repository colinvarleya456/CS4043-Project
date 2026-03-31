class_name NPCManager

extends Node

@onready var npc_scene: PackedScene = preload("res://Beta/Basic-Ai/task_npc.tscn")

@onready var enterNodes : Marker3D = $"../NavigationRegion3D/mall/enters"
@onready var exitNodes : Marker3D = $"../NavigationRegion3D/mall/exits"
@onready var storeNodes : Marker3D = $"../NavigationRegion3D/mall/shops"


@export var entrances: Array[Marker3D]
@export var exits: Array[Marker3D]
@export var stores: Array[Marker3D]

const npc_amount: int = 100
var npc_array: Array[TaskNPC] = []

const SPAWN_TIMER_TICK = 0.5
var spawn_timer = 0

func _ready() -> void:
	for i in enterNodes.get_children():
		entrances.append(i)
	for i in exitNodes.get_children():
		exits.append(i)
	for i in storeNodes.get_children():
		stores.append(i)

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
			new_npc.set_collision_layer_value(4, true)
			add_child(new_npc)
			npc_array.append(new_npc)
