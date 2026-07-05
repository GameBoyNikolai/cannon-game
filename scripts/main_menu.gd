extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	$VBoxContainer/HBoxContainer/HSlider.value = Game.screenshake
	
	$VBoxContainer/HBoxContainer2/HSlider.value = 5.0 * AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
	
	$VBoxContainer/HBoxContainer2/HSlider.value = 3.0
	_on_volume_dragged(true)


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
	Game.hud.click_sound()
	match name:
		"resume":
			InteractionManager.exit_interaction()
		"quit":
			get_tree().quit()


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	Game.hud.click_sound()
	Game.screenshake = $VBoxContainer/HBoxContainer/HSlider.value
	


func _on_volume_dragged(value_changed: bool) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), $VBoxContainer/HBoxContainer2/HSlider.value / 5.0)
