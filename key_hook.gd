extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

var has_key := true

@export var color := Color.GREEN
@export var id := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.material_overlay = ShaderMaterial.new()
	
	$attach/Key.set_key_type(color, id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func highlight():
	if not highlighted:
		highlighted = true
		$MeshInstance3D.material_overlay.set_shader(shader)
		
		if has_key:
			$attach/Key.highlight()
	
func unhighlight():
	if highlighted:
		highlighted = false
		$MeshInstance3D.material_overlay.set_shader(null)
		
		if has_key:
			$attach/Key.unhighlight()

func start_interaction():
	if has_key and InteractionManager.can_pick_up():
		self.unhighlight()
		has_key = false
		InteractionManager.pick_up_object($attach/Key)
	elif not has_key and InteractionManager.held_object is Key:
		if InteractionManager.held_object.id == id:
			var key = InteractionManager.take_held_object()
			key.position = Vector3.ZERO
			key.rotation = Vector3.ZERO
			
			has_key = true
			
