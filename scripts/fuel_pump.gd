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
@onready var pump_handle : DoodadHandle = $pump/handle/Area3D
var last_pos := Vector3.ZERO
@onready var pump_base_y : float = $pump/handle.position.y
var clicked_y := 0.0

# release
@onready var release_handle : DoodadHandle = $pump/release/Area3D
@onready var button_base : Vector3 = $pump/release/MeshInstance3D.position

var is_hovered := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(max):
		ticks.append(base_z - i * (spread / float(max - 1)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Settings.interact_first:
		$Area3D.visible = false
		$Area3D.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		if not pump_handle.dragging and not release_handle.dragging:
			$Area3D.visible = true
			$Area3D.process_mode = Node.PROCESS_MODE_INHERIT
			
	if Settings.interact_first and Input.is_action_just_pressed("ui_accept"):
		if pump_handle.can_grab():
			pump_handle.grab()
			
		if release_handle.can_grab():
			release_handle.grab()
	
	speed = 0.0
	if pump_handle.dragging:
		var current_pos = pump_handle.current_pos
		#var diff_y = plane.project(last_pos).y - plane.project(current_pos).y
		
		var old_y = $pump/handle.position.y
		var goal_y = clicked_y + pump_handle.start_pos.y - pump_handle.current_pos.y
		if goal_y > 0.0:
			$pump/handle.position.y = lerp($pump/handle.position.y, goal_y, 8.0 * delta)
		else:
			$pump/handle.position.y = lerp($pump/handle.position.y, goal_y, 2.0 * delta)
				
		$pump/handle.position.y = clamp($pump/handle.position.y, pump_base_y - 0.1, pump_base_y + 0.3)
		
		speed = 1.5 * max(old_y - $pump/handle.position.y, 0.0)
		
		raw_position -= speed
		
	if release_handle.dragging:
		speed = 1.5
		raw_position += speed * delta
		
		$pump/release/MeshInstance3D.position = button_base - $pump/release/MeshInstance3D.basis * Vector3.UP * 0.04
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
	
	if not pump_handle.dragging and not release_handle.dragging:
		raw_position = lerp(raw_position, closest, 1.0 * delta)
	
	arrow.position.z = raw_position
		
	label.text = str(DoodadState.fuel_pump * 10 + 30) + "%"
	
func start_interaction():
	if Settings.interact_first:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		InteractionManager.start_modal_interaction(self)
		$Area3D.visible = false
		$sound.play()
		await InteractionManager.lerp_cam_to($CameraDest.global_position, $CameraDest.global_basis).finished
	
func stop_interaction():
	if Settings.interact_first:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$Area3D.visible = true
		$sound.play()
		await InteractionManager.restore_cam().finished

func target_text():
	if Settings.interact_first:
		Game.hud.set_target("Fuel Pump", "Adjust Fuel Richness")

#func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, source: CollisionObject3D) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			#if source == $pump/handle/Area3D:
				#if not is_dragging:
					#is_dragging = true
					#last_pos = _mouse_pos()
					#clicked_y = $pump/handle.position.y
					## un-highlight
					##_unhighlight_handle()
			#elif source == $pump/release/Area3D:
				#if not is_pressing:
					#is_pressing = true
					#last_pos = _mouse_pos()
		#else:
			#if source == $pump/handle/Area3D:
				#is_dragging = false
			#elif source == $pump/release/Area3D:
				#is_pressing = false
			#
			### re-highlight
			##if is_hovered:
				##_highlight_handle()
			#
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if not event.pressed:
			#is_dragging = false
			#is_pressing = false
			#
			### re-highlight
			##if is_hovered:
				##_highlight_handle()

func _on_begin_hold(start_pos: Vector2, source: DoodadHandle) -> void:
	if source == pump_handle:
		clicked_y = $pump/handle.position.y
	elif source == release_handle:
		pass
		
	if not Settings.interact_first:
		InteractionManager.start_modal_interaction(self)
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _on_end_hold(source: DoodadHandle) -> void:
	if not Settings.interact_first:
		InteractionManager.exit_interaction()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
