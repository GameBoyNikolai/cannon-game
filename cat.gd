extends Node3D

var active := false
var overheating := false

@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.cat = self
	timer.timeout.connect(_on_overheat)

func activate():
	if not active:
		active = true
		timer.start(randi_range(30, 60))
		
func deactivate():
	active = false
	timer.stop()

func is_good():
	return not overheating
	
func _on_overheat():
	Game.hud.display_messages(Game.story.cat_overheating())
	overheating = true

func start_interaction():
	if active and overheating:
		overheating = false
		timer.start(randi_range(30, 60))
