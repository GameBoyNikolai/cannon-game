extends Node3D

var max := 2

@export var angular_spread := deg_to_rad(220.0)
@onready var arrow_root := $pressure_valve/Plane
@onready var base_rot = arrow_root.rotation.y

@onready var label = $pressure_valve/Plane/Label3D

@onready var handle: DoodadHandle = $pressure_valve/Plane/Area3D

var is_hovered := false

var speed := 0.0
var max_speed := 5.0
var ticks : Array[float] = []
var raw_position = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(-max, max + 1):
		ticks.append(base_rot - (angular_spread / (2 * max + 1)) * i)
		
	raw_position = base_rot - (angular_spread / (2 * max + 1)) * DoodadState.pressure_valve

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Settings.interact_first:
		$Area3D.visible = false
		$Area3D.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		if not handle.dragging:
			$Area3D.visible = true
			$Area3D.process_mode = Node.PROCESS_MODE_INHERIT
			
	if Settings.interact_first and Input.is_action_just_pressed("ui_accept"):
		if handle.can_grab():
			handle.grab()
	
	var angle = arrow_root.rotation.x
	if handle.dragging:
		var current_pos := handle.current_pos
		var center_pos: Vector3 = handle.plane.global_position
			
		var center = handle.plane.project(center_pos)
		angle = (current_pos - center).angle_to(Vector2.RIGHT)
		
		arrow_root.rotation.x = lerp(arrow_root.rotation.x, angle, 0.05)
	
	var closest = ticks[0]
	var dist = INF
	for i in range(len(ticks)):
		var t = ticks[i]
		var d = abs(t - angle)
		if d < dist:
			closest = t
			dist = d 
			
			DoodadState.pressure_valve = -max + i
			
	
	if not handle.dragging:
		arrow_root.rotation.x = lerp(arrow_root.rotation.x, closest, 0.3)
		
	if handle.dragging:
		if abs(arrow_root.rotation.x - closest) < 0.3:
			arrow_root.rotation.x = lerp(arrow_root.rotation.x, closest, 0.3)
			if abs(arrow_root.rotation.x - closest) < 0.1:
				arrow_root.rotation.x = closest
		
	arrow_root.rotation.x = clamp(arrow_root.rotation.x, -angular_spread / 2, angular_spread / 2)
			
	label.text = ("+" if DoodadState.pressure_valve > 0 else "") + str(DoodadState.pressure_valve) + " atm"
			
func target_text():
	if Settings.interact_first:
		Game.hud.set_target("Pressure Valve", "Adjust Pressure")
	
func start_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	if Settings.interact_first:
		InteractionManager.start_modal_interaction(self)
		$Area3D.visible = false
		$sound.play()
		await InteractionManager.lerp_cam_to($CameraDest.global_position, $CameraDest.global_basis)
	
func stop_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Settings.interact_first:
		$sound.play()
		$Area3D.visible = true
		await InteractionManager.restore_cam().finished

func _on_begin_hold(start_pos: Vector2) -> void:
	if not Settings.interact_first:
		InteractionManager.start_modal_interaction(self)
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _on_end_hold() -> void:
	if not Settings.interact_first:
		InteractionManager.exit_interaction()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
