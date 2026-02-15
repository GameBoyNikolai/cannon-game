extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

var pressure := 0
var max := 2

@export var angular_spread := deg_to_rad(160.0)
@onready var arrow_root := $valve/MeshInstance3D/Node3D
@onready var base_rot = arrow_root.rotation.y

@export var objects: Array[GeometryInstance3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for o in objects:
		o.material_overlay = ShaderMaterial.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if InteractionManager.is_input_captured(self):
		if Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_down"):
			print("down")
			pressure -= 1
		if Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_up"):
			print("up")
			pressure += 1
			
	pressure = clamp(pressure, -max, max)
	
	arrow_root.rotation.y = base_rot - (angular_spread / (2 * max + 1)) * pressure
	

func highlight():
	if not highlighted:
		highlighted = true
		#scale *= 2.0
		
		for o in objects:
			o.material_overlay.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		highlighted = false
		#scale = Vector3.ONE
		
		self.stop_interaction()
		
		for o in objects:
			o.material_overlay.set_shader(null)
	
func start_interaction():
	print("STARTED INTERACTION")
	InteractionManager.start_modal_interaction(self)
	
func stop_interaction():
	pass
