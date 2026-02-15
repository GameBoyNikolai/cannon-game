extends Node3D
class_name BigBullet

@export var active := false

var initial_xfm = null

var held := false

var highlighted := false
var shader := load("res://outline_shader.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RigidBody3D/MeshInstance3D.material_overlay = ShaderMaterial.new()

	$RigidBody3D.sleeping = true
	$RigidBody3D.freeze = true
	
	initial_xfm = self.transform

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _physics_process(delta: float) -> void:
	#if held:
		#self.transform = initial_xfm

func highlight():
	if not highlighted:
		highlighted = true
		
		$RigidBody3D/MeshInstance3D.material_overlay.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		highlighted = false
		
		$RigidBody3D/MeshInstance3D.material_overlay.set_shader(null)
		
func start_interaction():
	if active:
		if InteractionManager.can_pick_up():
			#$RigidBody3D.sleeping = true
			$RigidBody3D.freeze = true
			#self.position += Vector3(0, 3, 0)
			#self.rotation = Vector3.ZERO
			#self.global_position = Vector3.ZERO
			#self.global_rotation = Vector3.ZERO
			$RigidBody3D.rotation = Vector3.ZERO
			$RigidBody3D.position = Vector3.ZERO
			self.held = true
			$RigidBody3D.linear_velocity = Vector3.ZERO
			$RigidBody3D.angular_velocity = Vector3.ZERO
			InteractionManager.pick_up_object(self)
	else:
		if InteractionManager.can_pick_up():
			var dupe = self.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			dupe.active = true
			dupe.held = true
			get_tree().current_scene.add_child(dupe)
			InteractionManager.pick_up_object(dupe)

func drop():
	#$RigidBody3D.sleeping = false
	self.held = true
	$RigidBody3D.freeze = false
