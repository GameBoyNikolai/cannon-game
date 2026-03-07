extends Node3D
class_name Shell

enum Type { Steel, Titanium, Depth, Nuclear, None }

@export var type: Type = Type.None

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_impostor():
	match type:
		Type.Steel:
			return preload("res://scenes/light_shell_impostor.tscn").instantiate()
		Type.Titanium:
			return preload("res://scenes/heavy_shell_impostor.tscn").instantiate()
		Type.Depth:
			return preload("res://scenes/depth_shell_impostor.tscn").instantiate()
		Type.Nuclear:
			return preload("res://scenes/nuclear_shell_impostor.tscn").instantiate()

func start_interaction():
	if InteractionManager.can_pick_up():
		#var dupe = self.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		var dupe = create_impostor()
		get_tree().current_scene.add_child(dupe)
		
		dupe.global_position = self.global_position
		dupe.rotation = Vector3.ZERO
		InteractionManager.pick_up_object(dupe)
		
		$sound.play()
	else:
		var held_object = InteractionManager.held_object
		if held_object is Shell and held_object.type == type:
			InteractionManager.take_held_object()#.queue_free()
			
			$sound.play()

func target_text():
	if InteractionManager.can_pick_up():
		Game.hud.set_target(Game.tasks.shell_names[type], "Pick up")
	else:
		var held_object = InteractionManager.held_object
		if held_object is Shell and held_object.type == type:
			Game.hud.set_target(Game.tasks.shell_names[type], "Put back")
		else:
			Game.hud.set_target(Game.tasks.shell_names[type], "(Hand Full)")
