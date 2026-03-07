extends Node3D

@export var indicator: Node3D = null

var juice : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if indicator:
		if DoodadState.juice_load_type != Juice.Type.None:
			indicator.on()
		else:
			indicator.off()
			
	if juice and DoodadState.juice_load_type == Juice.Type.None:
		juice = false
	
func target_text():
	var held_object = InteractionManager.held_object
		
	var action = ""
	if held_object == null and DoodadState.juice_load_type != Juice.Type.None:
		action = "Purge Fuel"
	elif held_object is Juice:
		if DoodadState.juice_load_type == Juice.Type.None:
			action = "Load Fuel"
		elif DoodadState.juice_load_type != Juice.Type.None:
			action = "Clear and Load Fuel"
	
	Game.hud.set_target("Fuel Loader", action)

func start_interaction():
	var held_object = InteractionManager.held_object
	if held_object is Juice:
		var type = held_object.type
		InteractionManager.take_held_object().queue_free()
		# or place it on display
		DoodadState.juice_load_type = type
		juice = true
		
		$sound.play()
	elif held_object == null:
		DoodadState.juice_load_type = Juice.Type.None
		
		$sound.play()
