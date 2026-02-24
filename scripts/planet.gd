extends Node3D

@onready var noise: FastNoiseLite = $MeshInstance3D.material_overlay.albedo_texture.noise

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	noise.offset.z += delta * 2.0

	$MeshInstance3D.rotation.y += 0.01 * delta
