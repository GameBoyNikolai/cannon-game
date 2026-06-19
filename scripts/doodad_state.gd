extends Node

var missile_load_type := Shell.Type.None
var juice_load_type := Juice.Type.None

var pressure_valve := 0
var fuel_pump := 0
var buttons : Array[bool] = [false, false, false]
var key_holes : Array[int] = [-1, -1, -1]

var coordinates := Vector2i.ZERO
var height := 0

var target_rotation := 0.0
var target_elevation := 0.0

var _lever_debug := false

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
	missile_load_type = Shell.Type.None
	juice_load_type = Juice.Type.None
	
	pressure_valve = 0
	fuel_pump = 0
	buttons = [false, false, false]
	key_holes = [-1, -1, -1]

func loaded():
	return 	(missile_load_type != Shell.Type.None and juice_load_type != Juice.Type.None) or _lever_debug

func fire():
	_lever_debug = false
	
	missile_load_type = Shell.Type.None
	juice_load_type = Juice.Type.None
