extends StaticBody3D

signal interact(player)

@export var isOpenInwards : bool = false
@export_range(0,1,.1) var moveSpeed : float

@export var startAngle : float
@export var targetRotation : float


func _ready() -> void:
	connect("interact", interactFunc)
	startAngle = rotation_degrees.y
	
	
	targetRotation = startAngle

func interactFunc(player):
	print("interact called : ",player)
	if !isOpenInwards:
		if targetRotation == startAngle + 90:
			targetRotation = startAngle
		elif targetRotation == startAngle:
			targetRotation = startAngle + 90
	
	elif isOpenInwards:
		if targetRotation == startAngle - 90:
			targetRotation = startAngle
		elif targetRotation == startAngle:
			targetRotation = startAngle - 90

func _physics_process(delta: float) -> void:
	rotation_degrees.y = lerp(rotation_degrees.y, targetRotation, moveSpeed)
