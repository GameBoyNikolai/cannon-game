extends Node3D

var max := 4

@export var spread := 0.6
@onready var arrow := $MeshInstance3D/Arrow
@onready var base_z = arrow.position.z

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if InteractionManager.is_input_captured(self):
		if Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_down"):
			DoodadState.fuel_pump -= 1
		if Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_up"):
			DoodadState.fuel_pump += 1
			
	DoodadState.fuel_pump = clamp(DoodadState.fuel_pump, 0, max)
	
	arrow.position.z = base_z - DoodadState.fuel_pump * (spread / float(max))
	
func start_interaction():
	InteractionManager.start_modal_interaction(self)
	
func stop_interaction():
	pass

func target_text():
	Game.hud.set_target("Fuel Pump", "Adjust Fuel Richness")
