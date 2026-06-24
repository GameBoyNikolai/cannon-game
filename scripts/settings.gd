extends Node

var interact_first := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# for testing the different interact modes
	if Input.is_action_just_pressed("debug_interaction"):
		interact_first = not interact_first
