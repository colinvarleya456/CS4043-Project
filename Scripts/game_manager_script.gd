extends Node

@export var targetToKill : Node3D
@export var exits : Array[Node3D]
@export var winCondition : bool = false

signal exited

func _ready() -> void:
	connect("exited",exitedFunc)
	for child in get_children():
		exits.append(child)

func _process(delta: float) -> void:
	if targetToKill == null:
		winCondition = true
		for i in exits:
			i.active = true
		

@onready var timer: Control = $"../Timer"
@onready var intermediate_menu: Control = $"../IntermediateMenu"
@onready var main_menu: Control = $"../MainMenu"
@onready var times: VBoxContainer = $"../MainMenu/times"

@export var runCount : int = 0
@onready var player: player_class = $"../3D/Player"

func exitedFunc():
	main_menu.visible = true
	for i in intermediate_menu.activateOnStart:
		i.active = false
	timer.active = false
	timer.visible = false
	player.global_position = player.startPosition
	
	runCount += 1
	var t = RichTextLabel.new()
	t.fit_content = true
	t.add_theme_font_size_override("normal",40)
	t.text = str("Run: ",runCount, " Minutes: ", timer.mins, " Seconds: ",timer.secs)
	times.add_child(t)
