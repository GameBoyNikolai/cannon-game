extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

var max := 2

@export var angular_spread := deg_to_rad(220.0)
@onready var arrow_root := $pressure_valve/Plane
@onready var base_rot = arrow_root.rotation.y

@onready var label = $pressure_valve/Plane/Label3D

@export var objects: Array[GeometryInstance3D] = []

var speed := 0.0
var max_speed := 5.0
var ticks : Array[float] = []
var raw_position = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for o in objects:
		o.material_overlay = ShaderMaterial.new()
		
	for i in range(-max, max + 1):
		ticks.append(base_rot - (angular_spread / (2 * max + 1)) * i)
		
	raw_position = base_rot - (angular_spread / (2 * max + 1)) * DoodadState.pressure_valve

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir = 0.0
	if InteractionManager.is_input_captured(self):
		dir = Input.get_axis("ui_right", "ui_left")
	
	if abs(dir) > 0.0:
		speed = lerp(speed, max_speed, delta)
		raw_position += speed * delta * dir
	else:
		speed = 0.0
		
	raw_position = clamp(raw_position, -angular_spread / 2, angular_spread / 2)
		
	var closest = ticks[0]
	var dist = 10000.0
	for i in range(len(ticks)):
		var c = ticks[i]
		var d = abs(c - raw_position)
		if d < dist:
			closest = c
			dist = d
			DoodadState.pressure_valve = -max + i
			
	if speed < 1.0:
		arrow_root.rotation.x = lerp(arrow_root.rotation.x, closest, 0.1)
		raw_position = arrow_root.rotation.x
	else:
		arrow_root.rotation.x = raw_position
			
	label.text = ("+" if DoodadState.pressure_valve > 0 else "") + str(DoodadState.pressure_valve) + " atm"
		

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
	await InteractionManager.lerp_cam_to($CameraDest.global_position, $CameraDest.global_basis)
	$sound.play()
	
func stop_interaction():
	$sound.play()
	InteractionManager.restore_cam().finished
	
