extends Node



@onready var v_box_container: VBoxContainer = $VBoxContainer

signal addEvent(data)

@export var events : Dictionary[int,Array] = {}

# Dictionary is [type, global position, loudness]

#type : int 
#0-shot fired
#1-grenade explosion

#global position : Vector3

#loudness : float
#the distance this should be heard from, radius of a sphere cast from global position


func _ready() -> void:
	connect("addEvent", addEventFunc)
	TEMPupdateUI()

@export var dictPosition : int = 0

func addEventFunc(data):
	events.get_or_add(dictPosition, data)
	dictPosition += 1

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


# --- ----
#I was thinking of having all NPCS as a child of a node3d called npcHolder or something, when addEventFunc is called,
#it loops over every child of npcHolder and if the distance from the event global position to the npc global position is <= loudness then
#tell the npc there was an event at the position
