extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

@export var objects: Array[GeometryInstance3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for o in objects:
		o.material_overlay = ShaderMaterial.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func highlight():
	if not highlighted:
		highlighted = true
		for o in objects:
			o.material_overlay.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		highlighted = false
		for o in objects:
			o.material_overlay.set_shader(null)
	
func start_interaction():
	$AnimationPlayer.play("flip")
	
	await $AnimationPlayer.animation_finished
	Game.just_launched = true
	
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play_backwards("flip")
	
