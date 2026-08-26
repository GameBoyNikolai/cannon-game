class_name ToggleLever
extends Node3D

@export var index := 0
@export var light_array: LightArray = null

@onready var handle: DoodadHandle = $Pivot/Cylinder_001/DoodadHandle
var vis: HapticHandle

@onready var light_mat : StandardMaterial3D = $Light.material_override

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vis = HapticHandle.new(0.0, 1.0)\
		.haptics([0.0, 1.0])\
		.haptic_strength(0.6, 50.0)\
		.lerp_speed(30.0)\
		.set_pos(0.0)
		
	vis.trigger_haptic.connect(func(index):
		$haptic.play()
		
		var t = create_tween()
		
		t.tween_property($Pivot, "scale", Vector3.ONE + 0.1 * ($Pivot.basis * Vector3.UP), 0.1).from(Vector3.ONE)
		t.tween_property($Pivot, "scale", Vector3.ONE, 0.1)
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pos
	if handle.dragging:
		var current_pos := handle.current_pos
		
		var top = handle.plane.project($Top.global_position).x
		var bottom = handle.plane.project($Bottom.global_position).x
		
		pos = (clamp(current_pos.x, bottom, top) - bottom) / (top - bottom)
				
	var new_pos = vis.tick(delta, pos)
	$Pivot.position.z = lerp($Bottom.position.z, $Top.position.z, new_pos)
	
	if new_pos >= 0.95:
		if not DoodadState.buttons[index]:
			if light_array:
				light_array.turn_on_lights(index, 3)
		
		light_mat.emission_energy_multiplier = 20.0
		DoodadState.buttons[index] = true
	else:
		if DoodadState.buttons[index]:
			if light_array:
				light_array.turn_off_lights(index)
				
		light_mat.emission_energy_multiplier = 1.0
		DoodadState.buttons[index] = false
		
func start_interaction():
	pass
	
func stop_interaction():	
	pass

func _on_begin_hold(start_pos: Vector2, source: DoodadHandle) -> void:
	InteractionManager.start_modal_interaction(self)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _on_end_hold(source: DoodadHandle) -> void:
	InteractionManager.exit_interaction()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
