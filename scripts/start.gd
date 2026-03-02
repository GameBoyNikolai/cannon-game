extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$AudioStreamPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed(name: String) -> void:
	$Control/click.play()
	match name:
		"play":
			Game.start()
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		"quit":
			get_tree().quit()
