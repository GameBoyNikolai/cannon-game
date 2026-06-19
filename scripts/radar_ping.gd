extends MeshInstance3D
class_name Ping

@export var duration := 2.0

@onready var shader := self.mesh.material as ShaderMaterial

var doing_ping := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shader.set_shader_parameter("progress", 1.0)

func ping():
	if doing_ping:
		return
		
	doing_ping = true
	await create_tween().tween_method(_ping_progress, 0.0, 1.0, duration).finished
	doing_ping = false
	
func _ping_progress(progress: float):
	shader.set_shader_parameter("progress", progress)
