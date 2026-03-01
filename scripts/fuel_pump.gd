extends Node3D

var max := 5

@export var spread := (3.2 + 3.2)
@onready var arrow := $fuel_pump/Plane
@onready var base_z = arrow.position.z

@onready var label = $fuel_pump/Plane/label

var speed := 0.0
var max_speed := 5.0
var ticks : Array[float] = []
var raw_position = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(max):
		ticks.append(base_z - i * (spread / float(max - 1)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if InteractionManager.is_input_captured(self):
		#if Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_down"):
			#DoodadState.fuel_pump -= 1
		#if Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_up"):
			#DoodadState.fuel_pump += 1
			#
	#DoodadState.fuel_pump = clamp(DoodadState.fuel_pump, 0, max)
	#
	#arrow.position.z = base_z - DoodadState.fuel_pump * (spread / float(max))
	
	var dir = 0.0
	if InteractionManager.is_input_captured(self):
		dir = Input.get_axis("ui_right", "ui_left")
		
	if abs(dir) > 0.0:
		speed = lerp(speed, max_speed, 0.01)
		raw_position += speed * delta * dir
	else:
		speed = 0.0
		
	raw_position = clamp(raw_position, base_z - spread, base_z)
		
	var closest = ticks[0]
	var dist = 10000.0
	for i in range(len(ticks)):
		var c = ticks[i]
		var d = abs(c - raw_position)
		if d < dist:
			closest = c
			dist = d
			DoodadState.fuel_pump = i
			
	if speed < 0.1:
		arrow.position.z = lerp(arrow.position.z, closest, 0.1)
		raw_position = arrow.position.z
	else:
		arrow.position.z = raw_position
		
	label.text = str(DoodadState.fuel_pump * 10 + 30) + "%"
	
func start_interaction():
	InteractionManager.start_modal_interaction(self)
	InteractionManager.lerp_cam_to($CameraDest.global_position, $CameraDest.global_basis)
	
func stop_interaction():
	await InteractionManager.restore_cam().finished
	print(DoodadState.fuel_pump)

func target_text():
	Game.hud.set_target("Fuel Pump", "Adjust Fuel Richness")
