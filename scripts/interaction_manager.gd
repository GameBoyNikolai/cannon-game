extends Node

var modal_interactor : Node = null
var held_object : Node3D = null

var player_attach : RemoteTransform3D = null
var player_cam : Camera3D = null

var original_basis : Basis
var original_pos : Vector3

var skip_this_tick = false

@onready var debounce := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debounce.autostart = false
	debounce.one_shot = true
	add_child(debounce)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if skip_this_tick:
		skip_this_tick = false
		return
		
	#if Input.is_action_just_pressed("ui_cancel"):
		#if modal_interactor:
			#modal_interactor.stop_interaction()
			#modal_interactor = null
			#
			#debounce.start(0.2)
			
		#if held_object:
			#player_attach.remote_path = NodePath("")
			#held_object.drop()
			#held_object = null
			
func is_debouncing():
	return not debounce.is_stopped()
			
func set_player_attach(player_attach):
	self.player_attach = player_attach

func set_player_camera(cam):
	self.player_cam = cam
	
func start_modal_interaction(obj: Node):
	modal_interactor = obj
	skip_this_tick = true
	
func exit_interaction():
	assert(modal_interactor)
	await modal_interactor.stop_interaction()
	modal_interactor = null
	
	#debounce.start(0.2)
	
func can_pick_up():
	return not held_object
	
func pick_up_object(obj: Node3D):
	held_object = obj
	#held_object.get_node("attach")	
	obj.global_position = player_attach.global_position
	obj.global_rotation = Vector3.ZERO
	
	player_attach.remote_path = player_attach.get_path_to(obj)
	return true
	
func take_held_object():
	var obj = held_object
	held_object = null
	player_attach.remote_path = NodePath("")
	
	return obj

func is_input_captured(obj = null):
	return (obj == null && modal_interactor != null) || (obj != null && obj == modal_interactor)

func lerp_cam_to(pos: Vector3, xfm: Basis):
	original_basis = player_cam.basis
	original_pos = player_cam.position
	
	create_tween().tween_property(player_cam, "global_basis", xfm, 0.5)
	return create_tween().tween_property(player_cam, "global_position", pos, 0.5)

func restore_cam():
	create_tween().tween_property(player_cam, "basis", original_basis, 0.5)
	return create_tween().tween_property(player_cam, "position", original_pos, 0.5)
