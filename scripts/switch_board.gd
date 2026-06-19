class_name SwitchBoard
extends Node3D

@export var camera_dest: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

func _extra_highlight():
	for s in $Board.get_children():
		s.highlight_all()
		
func _extra_unhighlight():
	for s in $Board.get_children():
		s.unhighlight_all()
