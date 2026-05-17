extends Node3D

@export var hole_index := 0

var highlighted := false
var shader := load("res://outline_shader.gdshader")

var has_key := false
var key : Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$keyhole/Cylinder.material_overlay = ShaderMaterial.new()
	$keyhole/Cylinder.material_overlay.render_priority = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func highlight():
	if not highlighted:
		highlighted = true
		$keyhole/Cylinder.material_overlay.set_shader(shader)
		
		if has_key:
			key.highlight()
	
func unhighlight():
	if highlighted:
		highlighted = false
		$keyhole/Cylinder.material_overlay.set_shader(null)
		
		if has_key:
			key.unhighlight()
			
func target_text():
	Game.hud.set_target("Key Slot", "")
	if has_key and InteractionManager.can_pick_up():
		Game.hud.set_target(key.color_name() + " Ignition Key", "Pick up")
	elif not has_key and InteractionManager.held_object is Key:
		Game.hud.set_target("Key Slot", "Place Ignition Key")
			
func start_interaction():
	if has_key and InteractionManager.can_pick_up():
		self.unhighlight()

		InteractionManager.pick_up_object(key)
		
		has_key = false
		key = null
		
		if hole_index == 4:
			Game.cat.can_overheat = true
			Game.cat.timer.start(randi_range(30, 60))
		else:
			DoodadState.key_holes[hole_index] = -1
			
		$sound.play()
	elif not has_key and InteractionManager.held_object is Key:
		#if InteractionManager.held_object.id == id:
		key = InteractionManager.take_held_object()
		key.global_position = $attach.global_position
		key.global_rotation = $attach.global_rotation
		has_key = true
		
		if hole_index == 4:
			if key.id == 4:
				Game.cat.can_overheat = false
				Game.cat.lights_off()
		else:
			DoodadState.key_holes[hole_index] = key.id
			
		$sound.play()
