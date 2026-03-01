extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	$VBoxContainer/HBoxContainer/HSlider.value = Game.screenshake


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func exit():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
	
func stop_interaction():
	exit()
	InteractionManager.skip_this_tick = true

func _on_button_pressed(name: String) -> void:
	match name:
		"resume":
			exit()
		"quit":
			get_tree().quit()


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	Game.screenshake = $VBoxContainer/HBoxContainer/HSlider.value
	
