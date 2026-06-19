extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

var max := 2

@export var angular_spread := deg_to_rad(220.0)
@onready var arrow_root := $pressure_valve/Plane
@onready var base_rot = arrow_root.rotation.y

@onready var label = $pressure_valve/Plane/Label3D

@onready var plane: DragPlane = $DragPlane
var is_dragging := false
var last_pos := Vector3.ZERO

var is_hovered := false

@export var objects: Array[GeometryInstance3D] = []

var speed := 0.0
var max_speed := 5.0
var ticks : Array[float] = []
var raw_position = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for o in objects:
		o.material_overlay = ShaderMaterial.new()
		o.material_overlay.render_priority = 1
		
	$pressure_valve/Plane.material_overlay = ShaderMaterial.new()
	$pressure_valve/Plane.material_overlay.render_priority = 1
	$pressure_valve/Plane.material_overlay.set_shader_parameter("density", 2.0)
		
	for i in range(-max, max + 1):
		ticks.append(base_rot - (angular_spread / (2 * max + 1)) * i)
		
	raw_position = base_rot - (angular_spread / (2 * max + 1)) * DoodadState.pressure_valve

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging:
		var current_pos := _mouse_pos()
		var center_pos: Vector3 = plane.global_position
			
		var center = plane.project(center_pos)
		var angle := (plane.project(current_pos) - center).angle_to(Vector2.RIGHT)
		
		arrow_root.rotation.x = lerp(arrow_root.rotation.x, angle, 0.05)
	
	var closest = ticks[0]
	var dist = INF
	for i in range(len(ticks)):
		var t = ticks[i]
		var d = abs(t - arrow_root.rotation.x)
		if d < dist:
			closest = t
			dist = d 
			
			DoodadState.pressure_valve = -max + i
			
	
	if not is_dragging:
		arrow_root.rotation.x = lerp(arrow_root.rotation.x, closest, 0.1)
		
	if is_dragging:
		if abs(arrow_root.rotation.x - closest) < 0.15:
			arrow_root.rotation.x = lerp(arrow_root.rotation.x, closest, 0.1)
		
	arrow_root.rotation.x = clamp(arrow_root.rotation.x, -angular_spread / 2, angular_spread / 2)
	
	#var dir = 0.0
	#if InteractionManager.is_input_captured(self):
		#dir = Input.get_axis("ui_right", "ui_left")
	#
	#if abs(dir) > 0.0:
		#speed = lerp(speed, max_speed, delta)
		#raw_position += speed * delta * dir
	#else:
		#speed = 0.0
		#
	#raw_position = clamp(raw_position, -angular_spread / 2, angular_spread / 2)
		#
	#var closest = ticks[0]
	#var dist = 10000.0
	#for i in range(len(ticks)):
		#var c = ticks[i]
		#var d = abs(c - raw_position)
		#if d < dist:
			#closest = c
			#dist = d
			#DoodadState.pressure_valve = -max + i
			#
	#if speed < 1.0:
		#arrow_root.rotation.x = lerp(arrow_root.rotation.x, closest, 0.1)
		#raw_position = arrow_root.rotation.x
	#else:
		#arrow_root.rotation.x = raw_position
			
	label.text = ("+" if DoodadState.pressure_valve > 0 else "") + str(DoodadState.pressure_valve) + " atm"
		

func highlight():
	if not highlighted:
		Game.hud.set_target("Pressure Valve", "Adjust Pressure")
		highlighted = true
		
		for o in objects:
			o.material_overlay.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		Game.hud.set_target()
		highlighted = false
		
		for o in objects:
			o.material_overlay.set_shader(null)
	
func start_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	InteractionManager.start_modal_interaction(self)
	$Area3D.visible = false
	$sound.play()
	await InteractionManager.lerp_cam_to($CameraDest.global_position, $CameraDest.global_basis)
	
func stop_interaction():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$sound.play()
	$Area3D.visible = true
	await InteractionManager.restore_cam().finished

#region input
func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, source: CollisionObject3D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not is_dragging:
				is_dragging = true
				last_pos = _mouse_pos()
				# un-highlight
				_unhighlight_handle()
		else:
			is_dragging = false
			
			## re-highlight
			if is_hovered:
				_highlight_handle()
			
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false
			## re-highlight
			if is_hovered:
				_highlight_handle()

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
		
		
func _highlight_handle():
	$pressure_valve/Plane.material_overlay.set_shader(shader)
	
func _unhighlight_handle():
	$pressure_valve/Plane.material_overlay.set_shader(null)

func _on_area_3d_mouse_entered() -> void:
	is_hovered = true
	if not is_dragging:
		_highlight_handle()

func _on_area_3d_mouse_exited() -> void:
	is_hovered = false
	_unhighlight_handle()
