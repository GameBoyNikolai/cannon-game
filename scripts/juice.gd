extends Node3D
class_name Juice

enum Type { AmNitrate, Methane, Kerosene, Hydrazine, None }

@export var type: Type = Type.None

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_interaction():
	if InteractionManager.can_pick_up():
		var dupe = self.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		dupe.rotation = Vector3.ZERO
		get_tree().current_scene.add_child(dupe)
		InteractionManager.pick_up_object(dupe)
		
		$sound.play()
	else:
		var held_object = InteractionManager.held_object
		if held_object is Juice and held_object.type == type:
			InteractionManager.take_held_object().queue_free()
			$sound.play()

func target_text():
	if InteractionManager.can_pick_up():
		Game.hud.set_target(Game.tasks.juice_names[type], "Pick up")
	else:
		var held_object = InteractionManager.held_object
		if held_object is Juice and held_object.type == type:
			Game.hud.set_target(Game.tasks.juice_names[type], "Put back")
		else:
			Game.hud.set_target(Game.tasks.juice_names[type], "(Hand Full)")
			
