extends Control

@onready var mouse: Control = $Mouse

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	InteractionManager.mouse_offset = Vector2.ZERO
	if not InteractionManager.is_input_captured():
		mouse.global_position = get_viewport_rect().size / 2
	else:
		var half_size := get_viewport_rect().size / 2
		InteractionManager.mouse_offset = (mouse.global_position - half_size) / half_size    
		
func _input(event):
	if InteractionManager.is_input_captured():
		if event is InputEventMouseMotion:
			mouse.global_position = event.position
		
