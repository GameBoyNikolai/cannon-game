extends Node3D
class_name TubeLight

@onready var base_light_color = $SpotLight3D.light_color
@onready var lights = [$SpotLight3D, $SpotLight3D2, $SpotLight3D3, $SpotLight3D4]

func _ready():
	pass

func set_light_color(c: Color):
	for l in lights:
		l.light_color = c
