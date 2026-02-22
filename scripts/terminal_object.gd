extends Node3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

@export var text := "> WELCOME"

@onready var label := $SubViewport/Control/CanvasGroup/PanelContainer/Label

#var terminal_ui = load("res://scenes/info_terminal.tscn")
@export var ui_scn: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.material_overlay = ShaderMaterial.new()
	label.text = text

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
	var ui = ui_scn.instantiate()
	get_tree().root.add_child(ui)
		
