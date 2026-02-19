extends Area3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")
@onready var shader_mat: ShaderMaterial = ShaderMaterial.new()

@export var interactor: Node = null
@export var highlight_objects: Array[GeometryInstance3D] = []
@export var additional_objects: Array[GeometryInstance3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_collision_layer_value(2, true)
	
	for o in highlight_objects:
		o.material_overlay = shader_mat

func highlight():
	if not highlighted:
		highlighted = true
		
		for o in additional_objects:
			o.material_overlay = shader_mat
		
		shader_mat.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		highlighted = false
		shader_mat.set_shader(null)
		
func start_interaction():
	interactor.start_interaction()
