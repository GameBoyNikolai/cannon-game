extends Node3D

@onready var plane: DragPlane = $DragPlane

@onready var rot_wheel: DoodadHandle = $RotateWheel/Area3D
@onready var elev_wheel: DoodadHandle = $ElevationWheel/Area3D
@onready var rot_lever: DoodadHandle = $RotationLever/Center/Area3D

var rot_target := 0.3
var elev_target := 0.0

@export var radar : Radar = null
var rot_nodes : Array[float] = []
var elev_nodes : Array[float] = []

@export var camera_dest: Node3D = null

func _ready() -> void:
	rot_nodes = radar.sector_nodes()
	elev_nodes = radar.range_nodes()
	
func _normalized_angle(a: float) -> float:
	return fmod(a + 2.0 * PI, 2.0 * PI)
	
func _angle_diff(a: float, b: float) -> float:
	return fmod(a - b + 3.0 * PI, 2.0 * PI) - PI

func _process(delta: float) -> void:
	if not visible:
		return
	
	if not Settings.interact_first:
		$Area3D.visible = false
		$Area3D.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		if not elev_wheel.dragging and not rot_wheel.dragging:
			$Area3D.visible = true
			$Area3D.process_mode = Node.PROCESS_MODE_INHERIT
			
	if Settings.interact_first and Input.is_action_just_pressed("ui_accept"):
		if elev_wheel.can_grab():
			elev_wheel.grab()
			
		if rot_wheel.can_grab():
			rot_wheel.grab()
		
	if elev_wheel.dragging:
		var center = plane.project($ElevationWheel.global_position)
		var angle_diff := (elev_wheel.current_pos - center).angle_to(elev_wheel.last_pos - center)
		
		elev_target += -angle_diff / 150.0
		$ElevationWheel.rotate(($ElevationWheel.basis * Vector3.UP).normalized(), angle_diff)
		
	if rot_wheel.dragging:
		var center = plane.project($RotateWheel.global_position)
		var angle_diff := (rot_wheel.current_pos - center).angle_to(rot_wheel.last_pos - center)
		
		rot_target += -angle_diff / 50.0
		$RotateWheel.rotate(($RotateWheel.basis * Vector3.UP).normalized(), angle_diff)
		
		# reset lever
		$RotationLever/Center.rotation.z = 0
		
	# to make this work better, I think I need:
	# - the desired angle (mouse)
	# - the phantom angle, which is lerped towards the desired angle, with no snapping
	# - the physical angle, which follows phantom angle (exactly?) except when snapping
	var rot_lever_angle = $RotationLever/Center.rotation.z
	if rot_lever.dragging:
		var current_pos := rot_lever.current_pos
		var center_pos: Vector3 = rot_lever.plane.global_position
			
		var center = rot_lever.plane.project(center_pos)
		rot_lever_angle = (current_pos - center).angle_to(Vector2.RIGHT)
		
		$RotationLever/Center.rotation.z = lerp($RotationLever/Center.rotation.z, rot_lever_angle, 33 * delta)
		$RotationLever/Center.rotation.z = clamp($RotationLever/Center.rotation.z, -PI / 8.0, PI / 8.0)
	
		if abs($RotationLever/Center.rotation.z - 0.0) < 0.1:
			$RotationLever/Center.rotation.z = lerp($RotationLever/Center.rotation.z, 0.0, 1.7 * delta)
			if abs($RotationLever/Center.rotation.z - 0.0) < 0.05:
				$RotationLever/Center.rotation.z = 0.0
				
	#if abs($RotationLever/Center.rotation.pz) < 0.1:
		#var weight = 0.5
		#if rot_lever.dragging:
			#weight = 0.05
			#
		#$RotationLever/Center.rotation.z = lerp($RotationLever/Center.rotation.z, 0.0, weight)
	
	if abs($RotationLever/Center.rotation.z) > 0.2:
		rot_target += -sign($RotationLever/Center.rotation.z) * remap(abs($RotationLever/Center.rotation.z), 0.0, PI / 8.0, 0.0, 0.8 * delta)
		
	rot_target = _normalized_angle(rot_target)
	
	elev_target = clamp(elev_target, elev_nodes.front(), elev_nodes.back())
	
	#_do_sticky_angle(delta)
	_do_sticky_elevation(delta)
		
	DoodadState.target_rotation = lerp_angle(_normalized_angle(DoodadState.target_rotation), rot_target, 5.0 * delta)
	DoodadState.target_elevation = lerpf(DoodadState.target_elevation, elev_target, 5.0 * delta)
	
	$RotIndicator/Center.rotation = Vector3(0, -DoodadState.target_rotation, 0)
	$DistIndicator/Arrow.position.x = remap(DoodadState.target_elevation, elev_nodes.front(), elev_nodes.back(), $DistIndicator/ArrowStart.position.x, $DistIndicator/ArrowEnd.position.x)
	
func _do_sticky_angle(delta: float):
	var dist := INF
	for rot in rot_nodes:
		rot = _normalized_angle(rot)
		var d := _angle_diff(rot, rot_target)
		if absf(d) < absf(dist):
			dist = d
			
	var width = (rot_nodes[1] - rot_nodes[0]) / 2.0
	var strength = 1.0 - absf(dist) / width
	
	var weight := 0.1
	if not rot_wheel.dragging:
		weight = 0.8
	rot_target += strength * signf(dist) * weight * delta
	
func _do_sticky_elevation(delta: float):
	var dist := INF
	for elev in elev_nodes:
		var d := elev - elev_target
		if absf(d) < absf(dist):
			dist = d
			
	var width = (elev_nodes[1] - elev_nodes[0]) / 2.0
	var strength = 1.0 - absf(dist) / width
	
	var weight := 0.01
	if not elev_wheel.dragging:
		weight = 0.6
	elev_target += strength * signf(dist) * weight * delta

func start_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	if Settings.interact_first:
		InteractionManager.start_modal_interaction(self)
		$Area3D.visible = false
		await InteractionManager.lerp_cam_to(camera_dest.global_position, camera_dest.global_basis).finished
	
func stop_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Settings.interact_first:
		$Area3D.visible = true
		await InteractionManager.restore_cam().finished
	
func target_text():
	pass

# TODO
func _on_begin_hold(start_pos: Vector2, source: DoodadHandle) -> void:
	if not Settings.interact_first:
		InteractionManager.start_modal_interaction(self)
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _on_end_hold(source: DoodadHandle) -> void:
	if not Settings.interact_first:
		InteractionManager.exit_interaction()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_move(pos: Vector2, source: DoodadHandle) -> void:
	#_last_pos = _current_pos
	#_current_pos = pos
	pass
