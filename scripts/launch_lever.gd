extends Node3D

@onready var handle : DoodadHandle = $Cylinder_001/Area3D

var is_pulling: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_good_launch"):
		DoodadState._lever_debug = true
		
	if Settings.interact_first and Input.is_action_just_pressed("ui_accept"):
		if handle.can_grab():
			handle.grab()
	
	if handle.dragging and not is_pulling:
		var current_pos := handle.current_pos
		var ref_pos := handle.plane.project($TopRef.global_position)
		
		var diff := current_pos.y - ref_pos.y
		
		$Cylinder_001.rotation.x = remap(diff, 0.2, -0.05, deg_to_rad(70.9), deg_to_rad(-10))
		$Cylinder_001.rotation.x = clamp($Cylinder_001.rotation.x, deg_to_rad(-10), deg_to_rad(70.9))
		
		if $Cylinder_001.rotation.x < deg_to_rad(20):
			is_pulling = true
			#handle.release()
			
			# TODO, need to block input and wait to warp mouse until pull is finished
			Input.warp_mouse(handle.start_mouse_pos)
			
			_do_pull()
			
		if $Cylinder_001.rotation.x < deg_to_rad(55) and not DoodadState.loaded():
			is_pulling = true
			#handle.release()
			
			Input.warp_mouse(handle.start_mouse_pos)
			
			_do_bad_pull()
			

func _do_bad_pull():
	var t = create_tween()
	t.tween_property($Cylinder_001, "rotation:x", deg_to_rad(-10), 0.1).as_relative().from_current().set_ease(Tween.EASE_OUT)
	t.tween_property($Cylinder_001, "rotation:x", deg_to_rad(70.9), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	
	await t.finished
	is_pulling = false

func _do_pull():
	var t = create_tween()
	t.tween_property($Cylinder_001, "rotation:x", deg_to_rad(-10), 0.1).from_current().set_ease(Tween.EASE_OUT)
	t.tween_property($Cylinder_001, "rotation:x", deg_to_rad(70.9), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	
	await t.finished
	is_pulling = false
	Game.just_launched = true
	
func start_interaction():
	if Settings.interact_first:
		InteractionManager.start_modal_interaction(self)
	
func stop_interaction():
	pass
	
func target_text():
	pass

func _on_begin_hold(start_pos: Vector2) -> void:
	if not Settings.interact_first:
		InteractionManager.start_modal_interaction(self)
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _on_end_hold() -> void:
	if not Settings.interact_first:
		InteractionManager.exit_interaction()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
