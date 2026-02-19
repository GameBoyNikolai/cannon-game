extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

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
			DoodadState.pressure_valve -= 1
		if Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_up"):
			print("up")
			DoodadState.pressure_valve += 1
			
	DoodadState.pressure_valve = clamp(DoodadState.pressure_valve, -max, max)
	
	arrow_root.rotation.y = base_rot - (angular_spread / (2 * max + 1)) * DoodadState.pressure_valve
	

func highlight():
	if not highlighted:
		Game.hud.set_target("Pressure Valve", "Adjust Pressure")
		highlighted = true
		#scale *= 2.0
		
		for o in objects:
			o.material_overlay.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		Game.hud.set_target()
		highlighted = false
		#scale = Vector3.ONE
		
		for o in objects:
			o.material_overlay.set_shader(null)
	
func start_interaction():
	InteractionManager.start_modal_interaction(self)
	
func stop_interaction():
	pass
