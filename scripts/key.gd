extends Node3D
class_name Key

@export var starting_hook: KeyHook

var current_holder: Node3D = null

@export var color := Color.GREEN
@export var id := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$key/key.material_override.albedo_color = color
	if starting_hook:
		starting_hook.place_key(self)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func color_name():
	match id:
		-1: return "Empty"
		0: return "Pink"
		1: return "Blue"
		2: return "Orange"
		4: return "Green"

func lock():
	$Area3D.process_mode = Node.PROCESS_MODE_DISABLED
	
func unlock():
	$Area3D.process_mode = Node.PROCESS_MODE_INHERIT

func start_interaction():
	if InteractionManager.can_pick_up():
		self.rotation = Vector3.ZERO
		#$Area3D.process_mode = Node.PROCESS_MODE_DISABLED
		InteractionManager.pick_up_object(self)
		
		print(current_holder)
		if current_holder:
			current_holder.remove_key(self)
		
func target_text():
	pass
