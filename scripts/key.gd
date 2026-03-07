extends Node3D
class_name Key

var color := Color.GREEN
var id := 0

var highlighted := false
var shader := load("res://outline_shader.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$key/key.material_overlay = ShaderMaterial.new()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_key_type(color, id):
	self.color = color
	self.id = id
	
	$key/key.material_override.albedo_color = color
	
func color_name():
	match id:
		-1: return "Empty"
		0: return "Pink"
		1: return "Blue"
		2: return "Orange"
		4: return "Green"

func highlight():
	if not highlighted:
		highlighted = true
		$key/key.material_overlay.set_shader(shader)
	
func unhighlight():
	if highlighted:
		highlighted = false
		$key/key.material_overlay.set_shader(null)
#
#func start_interaction():
	#if InteractionManager.can_pick_up():
		#self.rotation = Vector3.ZERO
		#$Area3D.visible = false
		#InteractionManager.pick_up_object(self)

func drop():
	pass
