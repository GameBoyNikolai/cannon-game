extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

var terminal_ui = load("res://info_terminal.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.material_overlay = ShaderMaterial.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func highlight():
	if not highlighted:
		highlighted = true
		$MeshInstance3D.material_overlay.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		highlighted = false
		$MeshInstance3D.material_overlay.set_shader(null)
		
func start_interaction():
	var ui = terminal_ui.instantiate()
	get_tree().root.add_child(ui)
		
