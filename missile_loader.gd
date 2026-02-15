extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$toilet/Toilet/toilet.material_overlay = ShaderMaterial.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if DoodadState.missile_load_type == 0:
		$Light.get_active_material(0).emission = Color.RED
	else:
		$Light.get_active_material(0).emission = Color.GREEN

func highlight():
	if not highlighted:
		highlighted = true
		$toilet/Toilet/toilet.material_overlay.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		highlighted = false
		$toilet/Toilet/toilet.material_overlay.set_shader(null)
	
func start_interaction():
	var held_object = InteractionManager.held_object
	if held_object is BigBullet:
		InteractionManager.take_held_object().queue_free()
		DoodadState.missile_load_type = 2
	elif held_object == null:
		DoodadState.missile_load_type = 0
	
