extends Node3D

@export var indicator: Node3D = null
@export var handle: DoodadHandle
var closed := false

var display_shell: Node3D = null

@onready var ram : RamLoader = $RamLoader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ram.loaded.connect(func(): indicator.on())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if display_shell and DoodadState.missile_load_type == Shell.Type.None:
		closed = false
		display_shell.queue_free()
		display_shell = null
		
		ram.reset()
		
		indicator.off()
		$missile_loader/Cylinder_001.rotation.z = deg_to_rad(-84.8)
		
	if display_shell:
		$Area3D.process_mode = Node.PROCESS_MODE_DISABLED
		
		if handle.dragging and not closed:
			var top = handle.plane.project($missile_loader/Refs/Top.position)
			var bottom = handle.plane.project($missile_loader/Refs/Bottom.position)
			
			var desired = \
				remap(handle.current_pos.y, top.y, bottom.y, deg_to_rad(-84.8), deg_to_rad(0.0))
			desired = clamp(desired, deg_to_rad(-84.8), deg_to_rad(0.0))	
			
			$missile_loader/Cylinder_001.rotation.z = lerp($missile_loader/Cylinder_001.rotation.z, desired, 5.0 * delta)
			
			var pos = $missile_loader/Cylinder_001.rotation.z
			if abs(rad_to_deg(pos) - 0.0) < 15.0:
				$missile_loader/Cylinder_001.rotation.z = 0.0
				closed = true
				ram.set_active()
		
	else:
		$Area3D.process_mode = Node.PROCESS_MODE_INHERIT
		
	
func target_text():
	var held_object = InteractionManager.held_object
		
	var action = ""
	if held_object == null and DoodadState.missile_load_type != Shell.Type.None:
		action = "Clear Warhead"
	elif held_object is Shell:
		if DoodadState.missile_load_type == Shell.Type.None:
			action = "Load Warhead"
		elif DoodadState.missile_load_type != Shell.Type.None:
			action = "Clear and Load Warhead"
	
	Game.hud.set_target("Warhead Loader", action)

func start_interaction():
	var held_object = InteractionManager.held_object
	if held_object is Shell:
		var type = held_object.type
		display_shell = InteractionManager.take_held_object()
		display_shell.global_transform = $ShellRef.global_transform
		
		# or place it on display
		DoodadState.missile_load_type = type
		
		#var tween = create_tween()
		#tween.tween_property($missile_loader/Cylinder_001, "rotation:z", deg_to_rad(0), 0.3).set_ease(Tween.EASE_OUT)
		
		$sound.play()
	#elif held_object == null:
		#if DoodadState.missile_load_type != Shell.Type.None:
			#DoodadState.missile_load_type = Shell.Type.None
			##var tween = create_tween()
			##tween.tween_property($missile_loader/Cylinder_001, "rotation:z", deg_to_rad(-84.8), 0.3).set_ease(Tween.EASE_OUT)
			#
			#$sound.play()
