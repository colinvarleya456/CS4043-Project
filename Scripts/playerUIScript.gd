extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var player: player_class = $"../../3D/Player"

@export var gun1Text : RichTextLabel
@export var gun2Text : RichTextLabel
@export var gun3Text : RichTextLabel
@export var ammoText : RichTextLabel
@export var grenadeText : RichTextLabel

@export var gun1Texture : TextureRect
@export var gun2Texture : TextureRect
@export var gun3Texture : TextureRect


@export var gun1Name : String = ""
@export var gun2Name : String = ""
@export var gun3Name : String = ""


func _process(delta: float) -> void:
	var currentWeapon : gun_class = player.gun_holder.get_child(0)
	
	gun1Text.text = str("Gun 1: ", gun1Name)
	gun2Text.text = str("Gun 2: ", gun2Name)
	gun3Text.text = str("Gun 3: ", gun3Name)
	
	if currentWeapon:
		ammoText.text = str("Ammo: ",currentWeapon.ammo,"/",currentWeapon.magazineSize,"-",currentWeapon.reserveAmmo)
	
	match player.selectedGrenade:
		0:
			grenadeText.text = str("Frag: ", player.grenadeCounts[0])
		1:
			grenadeText.text = str("Flashbang: ", player.grenadeCounts[1])
	
	
	
	
