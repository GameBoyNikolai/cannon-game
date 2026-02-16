extends Node

var pressure_valve := 0
var missile_load_type := 0
var buttons : Array[bool] = [false, false, false]
var key_holes : Array[int] = [-1, -1, -1]

class Recipe:
	var valve = null
	var missile_type = null
	var buttons : Array[bool] = []
	var key_holes : Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func reset():
	pressure_valve = 0
	missile_load_type = 0
	buttons = [false, false, false]
	key_holes = [-1, -1, -1]
