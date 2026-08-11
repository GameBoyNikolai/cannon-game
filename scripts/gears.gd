class_name Gears
extends Node3D

@onready var groups = [
	[$Gear, $Gear2],
	[$Gear5, $Gear3],
	[$Gear4],
]

var speeds := [2.0, 3.0, 5.0]

var states := [false, false, false]

func _process(delta: float):
	for i in range(len(groups)):
		if states[i]:
			var dir = 1.0
			for g in groups[i]:
				g.rotation.x += dir * speeds[i] * delta
				dir *= -1.0

func set_gears(new_states: Array[bool]):
	states = new_states

func set_gear(index: int, state: bool):
	states[index] = state
