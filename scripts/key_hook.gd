extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

var has_key := true

@export var color := Color.GREEN
@export var id := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.material_overlay = ShaderMaterial.new()
	$MeshInstance3D.material_overlay.render_priority = 1
	
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
		Game.hud.set_target()
		highlighted = false
		$MeshInstance3D.material_overlay.set_shader(null)
		
		if has_key:
			$attach/Key.unhighlight()

func target_text():
	if has_key:
		Game.hud.set_target($attach/Key.color_name() + " Ignition Key", "Pick up")
	else:
		Game.hud.set_target("Key Hook", "")
		if InteractionManager.held_object is Key:
			if InteractionManager.held_object.id == id:
				Game.hud.set_target("Key Hook", "Place Ignition Key")

func start_interaction():
	if has_key and InteractionManager.can_pick_up():
		self.unhighlight()
		has_key = false
		InteractionManager.pick_up_object($attach/Key)
		$sound.play()
	elif not has_key and InteractionManager.held_object is Key:
		if InteractionManager.held_object.id == id:
			var key = InteractionManager.take_held_object()
			key.position = Vector3.ZERO
			key.rotation = Vector3.ZERO
			
			has_key = true
			$sound.play()
