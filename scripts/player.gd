extends CharacterBody3D

@onready var camera := $CamParent/Cam
@onready var pointer := $CamParent/Cam/RayCast3D

@export var speed := 3.5

@onready var noise: FastNoiseLite = load("res://scenes/player.tscn::FastNoiseLite_tuyoq")

var current_object = null

var walk_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.use_accumulated_input = false
	
	pointer.collide_with_areas = true
	pointer.collide_with_bodies = true

	InteractionManager.set_player(self)
	InteractionManager.set_player_attach($CamParent/Cam/attach)
	InteractionManager.set_player_camera($CamParent/Cam)
	
	_CameraShake3D._init_camera_shake($CamParent)
	

func _physics_process(delta: float):
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if InteractionManager.is_input_captured():
		input_dir = Vector2.ZERO
		direction = Vector3.ZERO
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	noise.offset.z += 30 * delta
	
	if not Game.started:
		return
	
	if velocity.length_squared() > 0.1:
		if walk_time > 0.7:
			$sound.play()
			
			walk_time -= randf_range(0.5, 0.6)
		elif walk_time < 0.01:
			$sound.play()
			
		walk_time += delta
	else:
		walk_time = 0.0

	if current_object:
		current_object.unhighlight()
		Game.hud.set_target("", "")
		current_object = null
	
	if InteractionManager.modal_interactor is not Control:
		_update_camera(delta)
	
	if InteractionManager.is_input_captured():
		if Input.is_action_just_pressed("ui_cancel"):
			InteractionManager.exit_interaction()
		return

	if Input.is_action_just_pressed("ui_cancel") and not InteractionManager.is_debouncing():
		var ui = preload("res://scenes/main_menu.tscn").instantiate()
		get_tree().root.add_child(ui)
		InteractionManager.start_modal_interaction(ui)
		return
		
	#if Input.is_action_just_pressed("interact"):
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	#elif Input.is_action_just_released("interact"):
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(
		$CamParent/Cam.global_transform.origin,
		$CamParent/Cam/CastTo.global_position,
		 0x00000002, []
	)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	var result = space_state.intersect_ray(params)
	
	if "collider" in result and result["collider"]:
		current_object = result["collider"]
		if not current_object.has_method("highlight"):
			current_object = result["collider"].get_parent()
		
		current_object.highlight()
		if current_object.has_method("target_text"):
			current_object.target_text()
		
		if Input.is_action_just_pressed("ui_accept"):
			current_object.start_interaction()
			
	space_state = get_world_3d().direct_space_state
	params = PhysicsRayQueryParameters3D.create(
		$CamParent/Cam.global_transform.origin,
		$CamParent/Cam/CastTo.global_position,
		 0x00000004, []
	)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	result = space_state.intersect_ray(params)
	
	if "collider" in result and result.collider:
		if Input.is_action_just_pressed("ui_accept"):
			result.collider.grab()
	
# camera code
@export var tilt_lower_limit := deg_to_rad(-90.0)
@export var tilt_upper_limit := deg_to_rad(90.0)
@export var mouse_sensitivity : float = 0.5 

var _rotation_input : float
var _tilt_input : float

func _unhandled_input(event):
	var mouse_input = event is InputEventMouseMotion# and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouse_input and not InteractionManager.is_input_captured():
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity

func sign2(v: Vector2):
	return Vector2(sign(v.x), sign(v.y))
	
func _towards_zero(v: Vector2, f: float) -> Vector2:
	return v - sign2(v) * v.abs().min(Vector2(f, f))

func _update_camera(delta):
	if InteractionManager.is_input_captured():
		var cutoff = 0.8
		if InteractionManager.mouse_offset.length_squared() > cutoff * cutoff:
			var amount = _towards_zero(InteractionManager.mouse_offset, cutoff) / ((1 - cutoff) * Vector2.ONE)
			_rotation_input = -2 * amount.x * mouse_sensitivity
			_tilt_input = -2 * amount.y * mouse_sensitivity
	
	camera.rotation.x += _tilt_input * delta
	camera.rotation.x = clamp(camera.rotation.x, tilt_lower_limit, tilt_upper_limit)
	rotation.y += _rotation_input * delta
	
	if InteractionManager.is_input_captured():
		rotation.y = lerp_angle(rotation.y, InteractionManager.original_aim.x, 3.0 * delta)
		camera.rotation.x = lerp(camera.rotation.x, InteractionManager.original_aim.y, 3.0 * delta)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func get_aim() -> Vector2:
	return Vector2(rotation.y, camera.rotation.x)
