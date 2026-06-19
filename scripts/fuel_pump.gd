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

@onready var plane: DragPlane = $pump/DragPlane
#pump
var is_dragging := false
var last_pos := Vector3.ZERO
@onready var pump_base_y : float = $pump/handle.position.y
var clicked_y := 0.0

# release
var is_pressing := false
@onready var button_base : Vector3 = $pump/release/MeshInstance3D.position

var is_hovered := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(max):
		ticks.append(base_z - i * (spread / float(max - 1)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = 0.0
	if is_dragging:
		var current_pos = _mouse_pos()
		#var diff_y = plane.project(last_pos).y - plane.project(current_pos).y
		
		var old_y = $pump/handle.position.y
		var goal_y = clicked_y + current_pos.y - last_pos.y
		if goal_y > 0.0:
			$pump/handle.position.y = lerp($pump/handle.position.y, goal_y, 8.0 * delta)
		else:
			$pump/handle.position.y = lerp($pump/handle.position.y, goal_y, 2.0 * delta)
				
		$pump/handle.position.y = clamp($pump/handle.position.y, pump_base_y - 0.1, pump_base_y + 0.3)
		
		speed = 1.5 * max(old_y - $pump/handle.position.y, 0.0)
		
		raw_position -= speed
		
		#last_pos = current_pos
		
	if is_pressing:
		speed = 1.5
		raw_position += speed * delta
		
		$pump/release/MeshInstance3D.position = button_base - $pump/release/MeshInstance3D.basis * Vector3.UP * 0.05
	else:
		$pump/release/MeshInstance3D.position = button_base
	
	var dir = 0.0
	if InteractionManager.is_input_captured(self):
		dir = Input.get_axis("ui_right", "ui_left")
		
	if abs(dir) > 0.0:
		speed = lerp(speed, max_speed, delta)
		raw_position += speed * delta * dir
	else:
		#speed = 0.0
		pass
		
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
			
	#if speed < 0.05:
		##arrow.position.z = lerp(arrow.position.z, closest, 1.0 * delta)
		##raw_position = arrow.position.z
		#pass
	#else:
	
	if not is_dragging and not is_pressing:
		raw_position = lerp(raw_position, closest, 1.0 * delta)
	
	arrow.position.z = raw_position
		
	label.text = str(DoodadState.fuel_pump * 10 + 30) + "%"
	
func start_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	InteractionManager.start_modal_interaction(self)
	$Area3D.visible = false
	$sound.play()
	await InteractionManager.lerp_cam_to($CameraDest.global_position, $CameraDest.global_basis).finished
	
func stop_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Area3D.visible = true
	$sound.play()
	await InteractionManager.restore_cam().finished

func target_text():
	Game.hud.set_target("Fuel Pump", "Adjust Fuel Richness")

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, source: CollisionObject3D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if source == $pump/handle/Area3D:
				if not is_dragging:
					is_dragging = true
					last_pos = _mouse_pos()
					clicked_y = $pump/handle.position.y
					# un-highlight
					#_unhighlight_handle()
			elif source == $pump/release/Area3D:
				if not is_pressing:
					is_pressing = true
					last_pos = _mouse_pos()
		else:
			if source == $pump/handle/Area3D:
				is_dragging = false
			elif source == $pump/release/Area3D:
				is_pressing = false
			
			## re-highlight
			#if is_hovered:
				#_highlight_handle()
			
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false
			is_pressing = false
			
			## re-highlight
			#if is_hovered:
				#_highlight_handle()

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
