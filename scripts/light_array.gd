@tool

class_name LightArray
extends Node3D

@export var energy := 3.0
@export var power_curve: Curve
@export var power_time := 1.0

var lights : Array[MeshInstance3D]

var lights_per_obj : Dictionary[int, Array] = {}

#@export var test: bool = false:
	#set(value):
		#print(value)
		#if value:
			#turn_on_lights(0, 3)
			#
			#await get_tree().create_timer(5.0).timeout
			#turn_off_lights(0)
		#test = false
		
@export_tool_button("Test", "Callable") var test = _test

func _test():
	print("TEST???")
	turn_on_lights(0, 3)
	
	await get_tree().create_timer(5.0).timeout
	turn_off_lights(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for c in get_children():
		#lights.append(c)
	for tower in [$MeshInstance3D9, $MeshInstance3D10]:
		for c in tower.get_children():
			lights.append(c)

func turn_on_lights(obj_id: int, num_lights: int):
	print(num_lights)
	for i in range(num_lights):
		if len(lights) == 0:
			continue
			
		var index = randi_range(0, len(lights) - 1)
		var light = lights[index]
		lights.remove_at(index)
		
		#(light.material_override as StandardMaterial3D).emission_energy_multiplier = energy
		_turn_on_light_async(light.material_override)
		
		if obj_id not in lights_per_obj:
			lights_per_obj[obj_id] = []
			
		lights_per_obj[obj_id].append(light)

func turn_off_lights(obj_id: int):
	if obj_id in lights_per_obj:
		for light in lights_per_obj[obj_id]:
			(light.material_override as StandardMaterial3D).emission_energy_multiplier = 0.0
			lights.append(light)
		lights_per_obj[obj_id] = []

func _turn_on_light_async(light_mat: StandardMaterial3D):
	#light_mat.emission_energy_multiplier = energy
	create_tween().tween_method(func(t: float):
		light_mat.emission_energy_multiplier = lerp(0.0, energy, power_curve.sample(t))
	, 0.0, 1.0, power_time)
