extends CharacterBody3D

@onready var camera := $Cam
@onready var pointer: = $Cam/RayCast3D

@export var speed := 3.0

@onready var noise: FastNoiseLite = load("res://aberration.tres::FastNoiseLite_onrkg")

var current_object = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	pointer.collide_with_areas = true
	pointer.collide_with_bodies = true

	InteractionManager.set_player_attach($Cam/attach)


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
	noise.offset.z = float(Time.get_ticks_msec()) / 100.0
	
	if current_object:
		current_object.unhighlight()
		current_object = null
		
	if InteractionManager.is_input_captured():
		return
	
	_update_camera(delta)
	
	pointer.force_raycast_update()
	var collider = pointer.get_collider()
	if collider:
		current_object = collider
		if not current_object.has_method("highlight"):
			current_object = collider.get_parent()
		
		current_object.highlight()
		
		if Input.is_action_just_pressed("ui_accept"):
			current_object.start_interaction()
	
# camera code
@export var tilt_lower_limit := deg_to_rad(-90.0)
@export var tilt_upper_limit := deg_to_rad(90.0)
@export var mouse_sensitivity : float = 0.5 

var _mouse_input : bool = false
var _mouse_rotation : Vector2
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input :
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, tilt_lower_limit, tilt_upper_limit)
	_mouse_rotation.y += _rotation_input * delta
	
	#_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	#_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	#camera.basis = Basis.from_euler(_camera_rotation)
	#camera.rotation.z = 0.0
	
	#global_transform.basis = Basis.from_euler(_player_rotation)
	
	rotation.y = _mouse_rotation.y
	camera.rotation.x = _mouse_rotation.x
	
	_rotation_input = 0.0
	_tilt_input = 0.0
