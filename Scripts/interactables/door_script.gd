extends StaticBody3D

signal interact(player)

@export var isOpenInwards : bool = false
@export_range(0,1,.1) var moveSpeed : float = 0.1

@export var startAngle : float
@export var targetRotation : float


func _ready() -> void:
	connect("interact", interactFunc)
	startAngle = hingeNode.rotation_degrees.y
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

@export var hingeNode : Node3D #because of importing being weird just assign the node that has the origin set to where the door rotates to this


func _physics_process(delta: float) -> void:
	hingeNode.rotation_degrees.y = lerp(hingeNode.rotation_degrees.y, targetRotation, moveSpeed)
