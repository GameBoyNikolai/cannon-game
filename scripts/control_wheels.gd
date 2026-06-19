extends Node3D

@onready var plane: DragPlane = $DragPlane

var active_wheel := ""
var is_dragging: bool = false
var last_pos: Vector3 = Vector3.ZERO

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
	return fmod(a, 2.0 * PI)
	
func _angle_diff(a: float, b: float) -> float:
	return fmod(a - b + 3.0 * PI, 2.0 * PI) - PI

func _process(delta: float) -> void:	
	if is_dragging:
		var current_pos := _mouse_pos()
		
		var center_pos: Vector3 = Vector3.ZERO
		if active_wheel == "rotation_wheel":
			center_pos = $RotateWheel.global_position
		else:
			center_pos = $ElevationWheel.global_position
			
		var center = plane.project(center_pos)
		var angle_diff := (plane.project(current_pos) - center).angle_to(plane.project(last_pos) - center)
		
		if active_wheel == "rotation_wheel":
			rot_target += angle_diff / 20.0
			$RotateWheel.rotate(Vector3.UP, angle_diff)
		else:
			elev_target += -angle_diff / 150.0
			$ElevationWheel.rotate(Vector3.UP, angle_diff)
			
		last_pos = current_pos
		
	rot_target = _normalized_angle(rot_target)
	
	elev_target = clamp(elev_target, elev_nodes.front(), elev_nodes.back())
	
	_do_sticky_angle(delta)
	_do_sticky_elevation(delta)
		
	DoodadState.target_rotation = lerp_angle(DoodadState.target_rotation, rot_target, 5.0 * delta)
	DoodadState.target_elevation = lerpf(DoodadState.target_elevation, elev_target, 5.0 * delta)
	
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
	if not is_dragging:
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
	if not is_dragging:
		weight = 0.6
	elev_target += strength * signf(dist) * weight * delta
	
func _mouse_pos() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)

	var val = plane.intersects_ray(ray_origin, ray_dir)
	if not val:
		return plane.center()
	else:
		return val

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, source: CollisionObject3D) -> void:
	print(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not is_dragging:
				active_wheel = "rotation_wheel" if source == $RotateWheel/Grab/Area3D else "elevation_wheel"
				
				is_dragging = true
				last_pos = _mouse_pos()
		else:
			is_dragging = false
			
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false
			
	
func _on_area_3d_mouse_entered(source: CollisionObject3D) -> void:
	pass

func start_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	InteractionManager.start_modal_interaction(self)
	$Area3D.visible = false
	await InteractionManager.lerp_cam_to(camera_dest.global_position, camera_dest.global_basis).finished
	
func stop_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Area3D.visible = true
	await InteractionManager.restore_cam().finished
	
func target_text():
	pass
