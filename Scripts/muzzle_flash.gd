extends GPUParticles3D

@onready var muzzle_flash: GPUParticles3D = $"."
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	muzzle_flash.one_shot = true
	gpu_particles_3d.one_shot = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if emitting == true:
		if get_child(0) != null:
			get_child(0).emitting = true



func _on_finished():
	queue_free()
