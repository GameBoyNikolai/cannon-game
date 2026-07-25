class_name KeyHook
extends Node3D

var has_key := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$MeshInstance3D.material_overlay = ShaderMaterial.new()
	#$MeshInstance3D.material_overlay.render_priority = 1
	#
	#$attach/Key.set_key_type(color, id)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Area3D.process_mode = Node.PROCESS_MODE_DISABLED if has_key else Node.PROCESS_MODE_INHERIT

func target_text():
	if has_key:
		Game.hud.set_target($attach/Key.color_name() + " Ignition Key", "Pick up")
	else:
		Game.hud.set_target("Key Hook", "")
		if InteractionManager.held_object is Key:
			#if InteractionManager.held_object.id == id:
				Game.hud.set_target("Key Hook", "Place Ignition Key") 
				
func place_key(key: Key):
	key.current_holder = self
	key.global_transform = $attach/KeyRef.global_transform
	has_key = true
	
func remove_key(key: Key):
	has_key = false

func start_interaction():
	if has_key and InteractionManager.can_pick_up():
		has_key = false
		InteractionManager.pick_up_object($attach/Key)
		$sound.play()
	elif not has_key and InteractionManager.held_object is Key:
		var key = InteractionManager.take_held_object()
		place_key(key)
		$sound.play()
