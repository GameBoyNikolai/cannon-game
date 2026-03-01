extends Node3D

@export var text : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/PanelContainer/MarginContainer/Label.text = "Operation Guide: \n\n- " + text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_interaction():
	$Control.show()
	
	$Q.hide()
	
	InteractionManager.start_modal_interaction(self)
	
func stop_interaction():
	$Control.hide()

func target_text():
	Game.hud.set_target("Operational Guide", "View")
