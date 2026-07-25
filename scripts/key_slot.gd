extends Node3D

@onready var handle: DoodadHandle = $Pivot/Handle/DoodadHandle
var vis: HapticHandle

var key: Key

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vis = HapticHandle.new(0, PI / 2)\
		.haptics([0.0, PI / 2])\
		.haptic_strength(PI / 8, 30.0)\
		.lerp_speed(10.0)\
		.set_pos(0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Pivot/Area3D.process_mode = Node.PROCESS_MODE_DISABLED if key else Node.PROCESS_MODE_INHERIT

	if key:
		key.global_transform = $Pivot/KeyRef.global_transform
		
		var angle
		if handle.dragging:
			var current_pos := handle.current_pos
			var center = handle.plane.project($Pivot.global_position)
			
			angle = (current_pos - center).angle_to(handle.plane.project($DragPlane/Start.global_position) - center)
					
		var new_angle = vis.tick(delta, angle)
		$Pivot.rotation.y = -new_angle
	
func start_interaction():
	if not key and InteractionManager.held_object is Key:
		key = InteractionManager.take_held_object()
		key.current_holder = self
		
func remove_key(k: Key):
	key = null
	
func stop_interaction():	
	pass
	
func target_text():
	pass

func _on_begin_hold(start_pos: Vector2) -> void:
	InteractionManager.start_modal_interaction(handle)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _on_end_hold() -> void:
	InteractionManager.exit_interaction()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
