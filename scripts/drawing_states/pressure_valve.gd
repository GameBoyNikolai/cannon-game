@tool
extends Camera3D

@export var num_states := 5

func _apply_state(i: int):
	$"../../../Objects/PressureValve2"._override_reading(i - 2)
