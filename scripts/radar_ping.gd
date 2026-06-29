extends MeshInstance3D
class_name Ping

@export var duration := 2.0

@onready var shader := self.mesh.material as ShaderMaterial

var angle := 0.0
var radius := 0.0
var doing_ping := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shader.set_shader_parameter("progress", 1.0)

func init(t: float, r: float):
	angle = t
	radius = r
	
func _angle_diff(a: float, b: float) -> float:
	return fmod(a - b + 3.0 * PI, 2.0 * PI) - PI
	
func update_visibility(focus_angle: float, extent: float, origin: Vector2):
	visible = abs(_angle_diff(angle, -focus_angle)) < extent / 2.0
	#if visible:
		#scale = 5.0 * Vector3.ONE
	#else:
		#scale = Vector3.ONE
	#
	#visible = true
	
	position = Vector3(radius, 0.01, radius) * Vector3(cos(angle), 1.0, sin(angle))

func ping():
	if doing_ping:
		return
		
	doing_ping = true
	await create_tween().tween_method(_ping_progress, 0.0, 1.0, duration).finished
	doing_ping = false
	
func _ping_progress(progress: float):
	shader.set_shader_parameter("progress", progress)
