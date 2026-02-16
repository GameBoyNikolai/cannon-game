extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.launch.connect(show_launch_text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_launch_text(text):
	$Radio/Text.text = text
