class_name SteamPipes
extends Node3D

@onready var vents : Array[GPUParticles3D] = [
	$SmokeEmitter,
	$SmokeEmitter2,
	$SmokeEmitter3,
]

@export var steps : Array[float] = [0.0, 0.2, 1.0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for v in vents:
		v.emitting = true
		v.amount_ratio = 0.0
		
func set_all_vents(powers : Array[int]):
	for index in range(len(powers)):
		set_vent(index, powers[index])

func set_vent(index: int, power: int):
	vents[index].amount_ratio = steps[power]
