extends Node3D

@export var indicator: Node3D = null

var shell: Shell = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if indicator:
		if DoodadState.missile_load_type != Shell.Type.None:
			indicator.on()
		else:
			indicator.off()
			
	if shell and DoodadState.missile_load_type == Shell.Type.None:
		shell.queue_free()
		shell = null
	
func target_text():
	var held_object = InteractionManager.held_object
		
	var action = ""
	if held_object == null and DoodadState.missile_load_type != Shell.Type.None:
		action = "Clear Shell"
	elif held_object is Shell:
		if DoodadState.missile_load_type == Shell.Type.None:
			action = "Load Shell"
		elif DoodadState.missile_load_type != Shell.Type.None:
			action = "Clear and Load Shell"
	
	Game.hud.set_target("Shell Loader", action)

func start_interaction():
	var held_object = InteractionManager.held_object
	if held_object is Shell:
		var type = held_object.type
		InteractionManager.take_held_object().queue_free()
		# or place it on display
		DoodadState.missile_load_type = type
		shell = held_object
	elif held_object == null:
		DoodadState.missile_load_type = Shell.Type.None
