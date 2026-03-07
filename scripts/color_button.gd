extends MeshInstance3D

var highlighted := false
var shader := load("res://outline_shader.gdshader")

@export var index := 0

var active := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.material_overlay = ShaderMaterial.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func highlight():
	if not highlighted:
		highlighted = true
		self.material_overlay.set_shader(shader)
			
	
func unhighlight():
	if highlighted:
		highlighted = false
		self.material_overlay.set_shader(null)
		
func target_text():
	Game.hud.set_target("Thruster Control button", "Turn on" if not active else "Turn off")
		
func start_interaction():
	$"../sfx".play()
	active = not active
	if active:
		self.get_active_material(0).emission = self.get_active_material(0).albedo_color * 2
		DoodadState.buttons[index] = true
		position.z -= 0.05
	else:
		self.get_active_material(0).emission = Color.BLACK
		DoodadState.buttons[index] = false
		position.z += 0.05
		
