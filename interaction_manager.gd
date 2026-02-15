extends Node

var modal_interactor : Node3D = null
var held_object : Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if modal_interactor:
			modal_interactor.stop_interaction()
			modal_interactor = null
	
func start_modal_interaction(obj: Node3D):
	modal_interactor = obj
	print(modal_interactor)

func is_input_captured(obj = null):
	return (obj == null && modal_interactor != null) || (obj != null && obj == modal_interactor)
