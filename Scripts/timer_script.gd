extends Control

signal start

@export var timeElapsed : float
@onready var rich_text_label: RichTextLabel = $RichTextLabel


func _ready() -> void:
	connect("start",startFunc)
	visible = false

@onready var active : bool = false

func startFunc():
	active = true
	visible = true
	timeElapsed = 0

func _process(delta: float) -> void:
	if active:
		timeElapsed += delta
		rich_text_label.text = timeLayout(int(timeElapsed * 10))

@export var mins : float = 0
@export var secs : float = 0

func timeLayout(input):
	var t = input
	var tArr : Array
	while t > 0:
		tArr.append(t%10)
		t = t/10

	var tArr2 : Array
	
	for i in len(tArr):
		if i == 0:
			tArr2.append(input%60)
		elif i == 1:
			tArr2.append(input/60)
	
	
	
	
	for i in len(tArr2):
		if len(tArr2) == 1:
			secs = tArr2[0]
			return str("Seconds: ",tArr2[0], " Minutes: ", 0)
		elif len(tArr2) == 2:
			secs = tArr2[0]
			mins = tArr2[1]
			return str("Seconds: ",tArr2[0], " Minutes: ", tArr2[1])
	
	if len(tArr2) == 0:
		return "Seconds: 0 Minutes: 0"
