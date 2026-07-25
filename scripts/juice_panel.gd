class_name JuicePanel
extends Node3D

@onready var stabber_handle: DoodadHandle = $Stabber/Center/DoodadHandle
@onready var jiggler_handle: DoodadHandle = $Jiggler/Center/DoodadHandle

var stabber_vis: HapticHandle
var jiggler_vis: HapticHandle

var juice: Node3D = null

var stabbed := false

var gauge_fill: float = 0.0

signal full

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stabber_vis = HapticHandle.new(0.0, 1.0)\
		.haptics([0.0, 1.5])\
		.haptic_strength(0.6, 50.0)\
		.lerp_speed(10.0)\
		.set_pos(1.0)
		
	jiggler_vis = HapticHandle.new(0.0, 1.0)\
		.haptics([0.5])\
		.haptic_strength(0.4, 30.0)\
		.lerp_speed(35.0)\
		.set_pos(0.5)

func set_juice(j):
	juice = j
	gauge_fill = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not juice:
		return
		
	var pos = 1.0
	if stabber_handle.dragging and gauge_fill < 1.0:
		var current_pos := stabber_handle.current_pos
		
		var top = stabber_handle.plane.project($Stabber/Top.global_position).y
		var bottom = stabber_handle.plane.project($Stabber/Bottom.global_position).y
		
		pos = (clamp(current_pos.y, bottom, top) - bottom) / (top - bottom)
				
	var new_pos = stabber_vis.tick(delta, pos)
	$Stabber/Center.position.y = lerp($Stabber/Bottom.position.y, $Stabber/Top.position.y, new_pos)
	
	if not stabbed:
		$"../JuiceRefParent/Tube".position.y = lerp(-0.368, 0.038, 1.0 - stabber_vis._display_position)
	else:
		$"../JuiceRefParent/Tube".position.y = 0.038
	
	if new_pos < 0.1 and not stabbed:
		stabbed = true
		_CameraShake3D._custom_shake(3 / (Game.screenshake / 10.0), Game.screenshake * 0.01)
		gauge_fill = 0.5
	
	if stabbed:
		pos = 0.5
		if jiggler_handle.dragging and gauge_fill < 1.0:
			var current_pos := jiggler_handle.current_pos
			
			var left = jiggler_handle.plane.project($Jiggler/Left.global_position).x
			var right = jiggler_handle.plane.project($Jiggler/Right.global_position).x
			
			pos = (clamp(current_pos.x, left, right) - left) / (right - left)
			
		new_pos = jiggler_vis.tick(delta, pos)
		$Jiggler/Center.position.z = lerp($Jiggler/Left.position.z, $Jiggler/Right.position.z, new_pos)
		
		var goal_rot = lerp(deg_to_rad(16), deg_to_rad(-16), jiggler_vis._display_position)
		$"../JuiceRefParent".rotation.x = lerp($"../JuiceRefParent".rotation.x, goal_rot, 10.0 * delta)
		juice.global_transform = $"../JuiceRefParent/JuiceRef".global_transform
		
		var diff = abs(jiggler_vis.display_t - jiggler_vis.last_display_t)
		gauge_fill += (diff * 10.0) * (diff * 10.0) / 200.0
		
		gauge_fill = clamp(gauge_fill, 0.0, 1.0)
		$Gauge/Center.rotation.z = lerp(deg_to_rad(-28), deg_to_rad(28), gauge_fill)
		
		if gauge_fill >= 1.0:
			full.emit()
			
func reset():
	juice.queue_free()
	juice = null
	stabbed = false
	gauge_fill = 0.0
	
	$Gauge/Center.rotation.z = deg_to_rad(-28)
	$"../JuiceRefParent/Tube".position.y = -0.368
		
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
