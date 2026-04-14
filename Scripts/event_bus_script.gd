extends Node

class_name event_bus

@onready var v_box_container: VBoxContainer = $VBoxContainer

signal addEvent(data)

@export var events : Dictionary[int,Array] = {}

# Dictionary is [type, global position, loudness]

#type : int 
enum EVENT_TYPE { SHOT_FIRED, GRENADE_EXPLOSION }
#0-shot fired
#1-grenade explosion

#global position : Vector3

#loudness : float
#the distance this should be heard from, radius of a sphere cast from global position


func _ready() -> void:
	connect("addEvent", addEventFunc)
	TEMPupdateUI()

@export var dictPosition : int = 0

@onready var npc_manager: NPCManager = $"../3D/Whitebox2/NPC Manager"

func addEventFunc(data):
	events.get_or_add(dictPosition, data)
	dictPosition += 1
	
	notifyNPCS(data)

func TEMPupdateUI():
	for child in v_box_container.get_children():
		child.queue_free()
	
	for i in len(events):
		var t = RichTextLabel.new()
		t.fit_content = true
		t.text = "event " + str(events[i])
		
		v_box_container.add_child(t)
	
	await get_tree().create_timer(.2).timeout
	TEMPupdateUI()

func notifyNPCS(data): # type, pos, loudness
	for child in npc_manager.get_children():
		var eventType : int = data[0]
		var eventPos : Vector3 = data[1]
		var eventLoudness : float = data[2]
		
		if eventPos.distance_to(child.global_position) < eventLoudness:
			child.emit_signal("eventHeard", eventType, eventPos)
















pass
