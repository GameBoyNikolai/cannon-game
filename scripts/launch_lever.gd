extends Node3D

@onready var plane : DragPlane = $DragPlane

var is_dragging: bool = false
var is_pulling: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_good_launch"):
		DoodadState._lever_debug = true
	
	if is_dragging and not is_pulling:
		var current_pos := plane.project(_mouse_pos())
		var ref_pos := plane.project($TopRef.global_position)
		
		var diff := current_pos.y - ref_pos.y
		
		$Cylinder_001.rotation.x = remap(diff, 0.2, -0.05, deg_to_rad(70.9), deg_to_rad(-10))
		$Cylinder_001.rotation.x = clamp($Cylinder_001.rotation.x, deg_to_rad(-10), deg_to_rad(70.9))
		
		if $Cylinder_001.rotation.x < deg_to_rad(20):
			is_pulling = true
			is_dragging = false
			
			_do_pull()
			
		if $Cylinder_001.rotation.x < deg_to_rad(55) and not DoodadState.loaded():
			is_pulling = true
			is_dragging = false
			
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

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not is_dragging:
				is_dragging = true
		else:
			is_dragging = false
			
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false

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

func _on_area_3d_mouse_entered() -> void:
	pass # Replace with function body.


func _on_area_3d_mouse_exited() -> void:
	pass # Replace with function body.
