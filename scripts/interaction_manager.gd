extends Node

var modal_interactor : Node = null
var held_object : Node3D = null

var player_attach : RemoteTransform3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if modal_interactor:
			modal_interactor.stop_interaction()
			modal_interactor = null
			
		#if held_object:
			#player_attach.remote_path = NodePath("")
			#held_object.drop()
			#held_object = null
			
func set_player_attach(player_attach):
	self.player_attach = player_attach
	
func start_modal_interaction(obj: Node):
	modal_interactor = obj
	
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
